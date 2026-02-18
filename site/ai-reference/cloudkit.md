# CloudKit AI Reference

> iCloud 데이터 동기화 가이드. 이 문서를 읽고 CloudKit 코드를 생성할 수 있습니다.

## 개요

CloudKit은 Apple의 클라우드 데이터베이스 서비스입니다.
사용자의 iCloud 계정을 통해 데이터를 저장하고 기기 간 동기화합니다.

## 필수 Import

```swift
import CloudKit
```

## 프로젝트 설정

1. **Capabilities 추가**: Signing & Capabilities → + CloudKit
2. **Container 선택**: `iCloud.com.yourcompany.appname`
3. **Record Types 정의**: CloudKit Dashboard에서 스키마 생성

## 핵심 구성요소

### 1. Container & Database

```swift
// 기본 컨테이너
let container = CKContainer.default()

// 커스텀 컨테이너
let container = CKContainer(identifier: "iCloud.com.example.app")

// 데이터베이스 종류
let privateDB = container.privateCloudDatabase  // 사용자 개인 데이터
let publicDB = container.publicCloudDatabase    // 모든 사용자 공유
let sharedDB = container.sharedCloudDatabase    // 공유된 데이터
```

### 2. CKRecord (데이터 모델)

```swift
// 레코드 생성
let record = CKRecord(recordType: "Note")
record["title"] = "메모 제목"
record["content"] = "메모 내용"
record["createdAt"] = Date()
record["isPinned"] = false

// 에셋 (파일/이미지)
let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent("image.jpg")
record["image"] = CKAsset(fileURL: imageURL)

// 참조 (관계)
let folderRecordID = CKRecord.ID(recordName: "folder-123")
record["folder"] = CKRecord.Reference(recordID: folderRecordID, action: .deleteSelf)
```

### 3. CRUD 작업

```swift
class CloudKitManager {
    private let database = CKContainer.default().privateCloudDatabase
    
    // CREATE
    func save(_ record: CKRecord) async throws -> CKRecord {
        try await database.save(record)
    }
    
    // READ (단일)
    func fetch(recordID: CKRecord.ID) async throws -> CKRecord {
        try await database.record(for: recordID)
    }
    
    // READ (쿼리)
    func fetchNotes() async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let (results, _) = try await database.records(matching: query)
        return results.compactMap { try? $0.1.get() }
    }
    
    // UPDATE
    func update(_ record: CKRecord) async throws -> CKRecord {
        try await database.save(record)  // save가 update 역할도 함
    }
    
    // DELETE
    func delete(recordID: CKRecord.ID) async throws {
        try await database.deleteRecord(withID: recordID)
    }
}
```

## 전체 작동 예제

```swift
import SwiftUI
import CloudKit

// MARK: - 모델
struct Note: Identifiable {
    let id: CKRecord.ID
    var title: String
    var content: String
    var createdAt: Date
    
    init(record: CKRecord) {
        self.id = record.recordID
        self.title = record["title"] as? String ?? ""
        self.content = record["content"] as? String ?? ""
        self.createdAt = record["createdAt"] as? Date ?? Date()
    }
    
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "Note", recordID: id)
        record["title"] = title
        record["content"] = content
        record["createdAt"] = createdAt
        return record
    }
}

// MARK: - ViewModel
@Observable
class NotesViewModel {
    var notes: [Note] = []
    var isLoading = false
    var error: Error?
    
    private let database = CKContainer.default().privateCloudDatabase
    
    func fetchNotes() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            let (results, _) = try await database.records(matching: query)
            notes = results.compactMap { result in
                guard let record = try? result.1.get() else { return nil }
                return Note(record: record)
            }
        } catch {
            self.error = error
        }
    }
    
    func addNote(title: String, content: String) async {
        let record = CKRecord(recordType: "Note")
        record["title"] = title
        record["content"] = content
        record["createdAt"] = Date()
        
        do {
            let saved = try await database.save(record)
            let note = Note(record: saved)
            notes.insert(note, at: 0)
        } catch {
            self.error = error
        }
    }
    
    func deleteNote(_ note: Note) async {
        do {
            try await database.deleteRecord(withID: note.id)
            notes.removeAll { $0.id == note.id }
        } catch {
            self.error = error
        }
    }
}

// MARK: - View
struct NotesListView: View {
    @State private var viewModel = NotesViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    VStack(alignment: .leading) {
                        Text(note.title).font(.headline)
                        Text(note.content).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        Task { await viewModel.deleteNote(viewModel.notes[index]) }
                    }
                }
            }
            .navigationTitle("메모")
            .toolbar {
                Button("추가", systemImage: "plus") {
                    showingAddSheet = true
                }
            }
            .refreshable {
                await viewModel.fetchNotes()
            }
            .task {
                await viewModel.fetchNotes()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}
```

## 고급 패턴

### 1. 실시간 구독 (Push)

```swift
func subscribeToChanges() async throws {
    let subscription = CKQuerySubscription(
        recordType: "Note",
        predicate: NSPredicate(value: true),
        subscriptionID: "note-changes",
        options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
    )
    
    let notification = CKSubscription.NotificationInfo()
    notification.shouldSendContentAvailable = true  // 백그라운드 알림
    subscription.notificationInfo = notification
    
    try await database.save(subscription)
}

// AppDelegate에서 처리
func application(_ application: UIApplication,
                 didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
    
    if let queryNotification = notification as? CKQueryNotification {
        // 변경된 recordID 가져오기
        if let recordID = queryNotification.recordID {
            // 데이터 새로고침
        }
    }
    return .newData
}
```

### 2. 배치 작업

```swift
func batchSave(records: [CKRecord]) async throws {
    let operation = CKModifyRecordsOperation(recordsToSave: records)
    operation.savePolicy = .changedKeys  // 변경된 키만 저장
    
    try await database.modifyRecords(saving: records, deleting: [])
}

func batchDelete(recordIDs: [CKRecord.ID]) async throws {
    try await database.modifyRecords(saving: [], deleting: recordIDs)
}
```

### 3. Zone 기반 동기화

```swift
// 커스텀 존 생성
let zoneID = CKRecordZone.ID(zoneName: "MyZone", ownerName: CKCurrentUserDefaultName)
let zone = CKRecordZone(zoneID: zoneID)
try await database.save(zone)

// 존 내 레코드 저장
let record = CKRecord(recordType: "Note", recordID: CKRecord.ID(zoneID: zoneID))

// 변경 사항 가져오기 (효율적 동기화)
func fetchChanges(since token: CKServerChangeToken?) async throws {
    let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
    config.previousServerChangeToken = token
    
    let operation = CKFetchRecordZoneChangesOperation(
        recordZoneIDs: [zoneID],
        configurationsByRecordZoneID: [zoneID: config]
    )
    // ... 변경 사항 처리
}
```

### 4. 공유 (Sharing)

```swift
func share(_ record: CKRecord) async throws -> CKShare {
    let share = CKShare(rootRecord: record)
    share.publicPermission = .readOnly
    
    let (savedRecords, _) = try await database.modifyRecords(
        saving: [record, share],
        deleting: []
    )
    
    return savedRecords.first { $0 is CKShare } as! CKShare
}
```

## 주의사항

1. **iCloud 계정 필수**
   - 사용자 로그인 상태 확인 필요
   - `CKContainer.default().accountStatus()` 체크

2. **쿼터 제한**
   - Private DB: 용량 무제한 (사용자 iCloud 용량)
   - Public DB: 앱당 1GB 무료
   - 대용량 파일은 CKAsset 사용

3. **오프라인 처리**
   - CloudKit은 오프라인 캐시 없음
   - Core Data + CloudKit 조합 권장 (NSPersistentCloudKitContainer)

4. **에러 처리**
   ```swift
   do {
       try await database.save(record)
   } catch let error as CKError {
       switch error.code {
       case .networkFailure: // 네트워크 오류
       case .serverRecordChanged: // 충돌
       case .quotaExceeded: // 용량 초과
       default: break
       }
   }
   ```
