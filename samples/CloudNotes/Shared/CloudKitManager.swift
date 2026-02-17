// CloudKitManager.swift
// CloudNotes - CloudKit 통합 관리자
//
// CKContainer를 래핑하여 CRUD 및 동기화 기능을 제공합니다.

import Foundation
import CloudKit
import Combine

// MARK: - CloudKitManager

/// CloudKit 작업을 관리하는 싱글톤 클래스
/// 노트의 CRUD, 동기화, 공유 기능을 제공합니다.
@MainActor
final class CloudKitManager: ObservableObject {
    
    // MARK: - 싱글톤
    
    static let shared = CloudKitManager()
    
    // MARK: - Published 속성
    
    /// 현재 동기화 상태
    @Published private(set) var syncState: SyncState = .idle
    
    /// 로컬에 캐시된 노트 목록
    @Published private(set) var notes: [Note] = []
    
    /// iCloud 계정 상태
    @Published private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    
    /// 마지막 동기화 시간
    @Published private(set) var lastSyncDate: Date?
    
    // MARK: - 속성
    
    /// CloudKit 컨테이너
    /// Info.plist의 CloudKit Container ID 사용
    private let container: CKContainer
    
    /// 프라이빗 데이터베이스 (개인 노트용)
    private var privateDatabase: CKDatabase {
        container.privateCloudDatabase
    }
    
    /// 공유 데이터베이스 (공유된 노트용)
    private var sharedDatabase: CKDatabase {
        container.sharedCloudDatabase
    }
    
    /// 변경사항 구독 토큰 (증분 동기화용)
    private var subscriptionSaved = false
    
    /// 서버 변경 토큰 (증분 페치용)
    private var serverChangeToken: CKServerChangeToken?
    
    // MARK: - 초기화
    
    private init() {
        // 기본 컨테이너 사용 (entitlements에 설정된 첫 번째 컨테이너)
        self.container = CKContainer.default()
        
        // 계정 상태 확인
        Task {
            await checkAccountStatus()
        }
    }
    
    // MARK: - 계정 관리
    
    /// iCloud 계정 상태 확인
    func checkAccountStatus() async {
        do {
            let status = try await container.accountStatus()
            self.accountStatus = status
            
            switch status {
            case .available:
                print("✅ iCloud 계정 사용 가능")
                await setupSubscription()
            case .noAccount:
                print("⚠️ iCloud 계정 없음")
            case .restricted:
                print("⚠️ iCloud 접근 제한됨")
            case .couldNotDetermine:
                print("⚠️ iCloud 상태 확인 불가")
            case .temporarilyUnavailable:
                print("⚠️ iCloud 일시적으로 사용 불가")
            @unknown default:
                print("⚠️ 알 수 없는 iCloud 상태")
            }
        } catch {
            print("❌ 계정 상태 확인 실패: \(error)")
        }
    }
    
    // MARK: - CRUD 작업
    
    /// 모든 노트 가져오기
    func fetchNotes() async throws {
        syncState = .syncing(message: "노트 불러오는 중...")
        
        do {
            // 쿼리 생성 (수정일 기준 내림차순)
            let query = CKQuery(
                recordType: Note.recordType,
                predicate: NSPredicate(value: true)
            )
            query.sortDescriptors = [
                NSSortDescriptor(key: "modificationDate", ascending: false)
            ]
            
            // 쿼리 실행
            let (results, _) = try await privateDatabase.records(matching: query)
            
            // 결과 변환
            var fetchedNotes: [Note] = []
            for (_, result) in results {
                switch result {
                case .success(let record):
                    if let note = Note(from: record) {
                        fetchedNotes.append(note)
                    }
                case .failure(let error):
                    print("⚠️ 레코드 변환 실패: \(error)")
                }
            }
            
            self.notes = fetchedNotes
            self.lastSyncDate = Date()
            self.syncState = .synced
            
            print("✅ \(fetchedNotes.count)개 노트 로드 완료")
            
        } catch {
            self.syncState = .error(error)
            throw error
        }
    }
    
    /// 노트 저장 (생성 또는 업데이트)
    /// - Parameter note: 저장할 노트
    /// - Returns: 저장된 노트 (recordID 포함)
    @discardableResult
    func save(_ note: Note) async throws -> Note {
        syncState = .syncing(message: "저장 중...")
        
        do {
            var noteToSave = note
            noteToSave.modifiedAt = Date()
            
            let record = noteToSave.toCKRecord()
            let savedRecord = try await privateDatabase.save(record)
            
            guard let savedNote = Note(from: savedRecord) else {
                throw CloudKitError.invalidRecord
            }
            
            // 로컬 캐시 업데이트
            if let index = notes.firstIndex(where: { $0.id == savedNote.id }) {
                notes[index] = savedNote
            } else {
                notes.insert(savedNote, at: 0)
            }
            
            self.syncState = .synced
            print("✅ 노트 저장 완료: \(savedNote.title)")
            
            return savedNote
            
        } catch {
            self.syncState = .error(error)
            throw error
        }
    }
    
    /// 노트 삭제
    /// - Parameter note: 삭제할 노트
    func delete(_ note: Note) async throws {
        syncState = .syncing(message: "삭제 중...")
        
        do {
            guard let recordID = note.recordID else {
                // 로컬에만 있는 노트는 캐시에서만 제거
                notes.removeAll { $0.id == note.id }
                syncState = .synced
                return
            }
            
            try await privateDatabase.deleteRecord(withID: recordID)
            
            // 로컬 캐시에서 제거
            notes.removeAll { $0.id == note.id }
            
            self.syncState = .synced
            print("✅ 노트 삭제 완료: \(note.title)")
            
        } catch {
            self.syncState = .error(error)
            throw error
        }
    }
    
    /// 여러 노트 삭제
    /// - Parameter notes: 삭제할 노트 배열
    func delete(_ notesToDelete: [Note]) async throws {
        syncState = .syncing(message: "삭제 중...")
        
        let recordIDs = notesToDelete.compactMap { $0.recordID }
        
        guard !recordIDs.isEmpty else {
            // 로컬에만 있는 노트들
            for note in notesToDelete {
                notes.removeAll { $0.id == note.id }
            }
            syncState = .synced
            return
        }
        
        do {
            let (_, deleteErrors) = try await privateDatabase.modifyRecords(
                saving: [],
                deleting: recordIDs
            )
            
            // 에러 확인
            for (recordID, error) in deleteErrors {
                print("⚠️ 삭제 실패 \(recordID): \(error)")
            }
            
            // 로컬 캐시에서 제거
            for note in notesToDelete {
                notes.removeAll { $0.id == note.id }
            }
            
            self.syncState = .synced
            
        } catch {
            self.syncState = .error(error)
            throw error
        }
    }
    
    // MARK: - 실시간 동기화
    
    /// 푸시 알림 구독 설정
    private func setupSubscription() async {
        guard !subscriptionSaved else { return }
        
        // 변경사항 구독 생성
        let subscriptionID = "note-changes"
        let subscription = CKQuerySubscription(
            recordType: Note.recordType,
            predicate: NSPredicate(value: true),
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        // 알림 설정
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true  // 백그라운드 갱신
        subscription.notificationInfo = notificationInfo
        
        do {
            try await privateDatabase.save(subscription)
            subscriptionSaved = true
            print("✅ CloudKit 구독 설정 완료")
        } catch let error as CKError where error.code == .serverRejectedRequest {
            // 이미 구독이 존재하는 경우
            subscriptionSaved = true
            print("ℹ️ CloudKit 구독 이미 존재")
        } catch {
            print("❌ 구독 설정 실패: \(error)")
        }
    }
    
    /// 원격 변경사항 처리 (푸시 알림 수신 시 호출)
    func handleRemoteNotification() async {
        do {
            try await fetchNotes()
        } catch {
            print("❌ 원격 변경사항 처리 실패: \(error)")
        }
    }
    
    // MARK: - 공유
    
    /// 노트 공유 설정 생성
    /// - Parameter note: 공유할 노트
    /// - Returns: 공유 컨트롤러용 CKShare
    func createShare(for note: Note) async throws -> CKShare {
        guard let recordID = note.recordID else {
            throw CloudKitError.recordNotSaved
        }
        
        let record = note.toCKRecord()
        
        // CKShare 생성
        let share = CKShare(rootRecord: record)
        share.publicPermission = .readOnly
        share[CKShare.SystemFieldKey.title] = note.title as CKRecordValue
        
        // 레코드와 공유 함께 저장
        let (_, _) = try await privateDatabase.modifyRecords(
            saving: [record, share],
            deleting: []
        )
        
        print("✅ 공유 생성 완료: \(note.title)")
        return share
    }
}

// MARK: - 에러 타입

/// CloudKit 관련 커스텀 에러
enum CloudKitError: LocalizedError {
    case invalidRecord
    case recordNotSaved
    case accountNotAvailable
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidRecord:
            return "유효하지 않은 레코드입니다"
        case .recordNotSaved:
            return "저장되지 않은 레코드입니다"
        case .accountNotAvailable:
            return "iCloud 계정을 사용할 수 없습니다"
        case .networkError:
            return "네트워크 오류가 발생했습니다"
        }
    }
}
