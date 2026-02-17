// Note.swift
// CloudNotes - CloudKit 레코드 매핑 모델
//
// CKRecord와 Swift 모델 간의 매핑을 담당합니다.

import Foundation
import CloudKit

// MARK: - Note 모델

/// CloudKit에 저장되는 노트 모델
/// CKRecord와 양방향 변환을 지원합니다.
struct Note: Identifiable, Hashable {
    
    // MARK: - 속성
    
    /// 고유 식별자 (CKRecord.ID 기반)
    let id: String
    
    /// 노트 제목
    var title: String
    
    /// 노트 내용
    var content: String
    
    /// 생성 일시
    let createdAt: Date
    
    /// 수정 일시
    var modifiedAt: Date
    
    /// CloudKit 레코드 참조 (업데이트 시 필요)
    var recordID: CKRecord.ID?
    
    // MARK: - 초기화
    
    /// 새 노트 생성
    init(
        id: String = UUID().uuidString,
        title: String = "",
        content: String = "",
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        recordID: CKRecord.ID? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.recordID = recordID
    }
    
    /// CKRecord로부터 노트 생성
    /// - Parameter record: CloudKit 레코드
    init?(from record: CKRecord) {
        // 레코드 타입 검증
        guard record.recordType == Note.recordType else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.title = record[NoteField.title] as? String ?? ""
        self.content = record[NoteField.content] as? String ?? ""
        self.createdAt = record.creationDate ?? Date()
        self.modifiedAt = record.modificationDate ?? Date()
        self.recordID = record.recordID
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - CloudKit 변환

extension Note {
    
    /// CloudKit 레코드 타입 이름
    static let recordType = "Note"
    
    /// 레코드 필드 키
    enum NoteField {
        static let title = "title"
        static let content = "content"
    }
    
    /// CKRecord로 변환
    /// - Parameter zoneID: 저장할 CloudKit Zone ID (기본값: default)
    /// - Returns: 변환된 CKRecord
    func toCKRecord(in zoneID: CKRecordZone.ID = .default) -> CKRecord {
        // 기존 레코드가 있으면 재사용, 없으면 새로 생성
        let record: CKRecord
        if let existingRecordID = recordID {
            record = CKRecord(recordType: Note.recordType, recordID: existingRecordID)
        } else {
            let recordID = CKRecord.ID(recordName: id, zoneID: zoneID)
            record = CKRecord(recordType: Note.recordType, recordID: recordID)
        }
        
        // 필드 설정
        record[NoteField.title] = title as CKRecordValue
        record[NoteField.content] = content as CKRecordValue
        
        return record
    }
}

// MARK: - 미리보기/테스트용 샘플 데이터

extension Note {
    
    /// 샘플 노트 (미리보기용)
    static let sample = Note(
        title: "샘플 노트",
        content: "CloudKit으로 동기화되는 노트입니다.\n\n여러 기기에서 실시간으로 동기화됩니다."
    )
    
    /// 샘플 노트 목록 (미리보기용)
    static let samples: [Note] = [
        Note(title: "회의 메모", content: "오늘 회의 내용 정리..."),
        Note(title: "아이디어 노트", content: "새로운 앱 아이디어:\n- 기능 A\n- 기능 B"),
        Note(title: "할 일 목록", content: "✅ CloudKit 연동\n⬜ UI 개선\n⬜ 테스트 작성"),
        Note(title: "읽을 책", content: "1. Swift Programming\n2. SwiftUI by Example")
    ]
}
