# CloudNotes

CloudKit을 활용한 메모 앱 샘플 프로젝트입니다.

## 📱 주요 기능

- **iCloud 동기화**: 모든 기기에서 실시간으로 노트 동기화
- **오프라인 지원**: 네트워크 없이도 사용 가능, 연결 시 자동 동기화
- **실시간 협업**: iCloud 공유를 통해 다른 사용자와 노트 공유
- **충돌 해결**: 서버/클라이언트 데이터 충돌 처리

## 🏗 프로젝트 구조

```
CloudNotes/
├── Shared/                          # 공유 모델 및 매니저
│   ├── Note.swift                   # CKRecord 매핑 모델
│   ├── CloudKitManager.swift        # CloudKit 통합 관리
│   └── SyncState.swift              # 동기화 상태 관리
│
├── CloudNotesApp/                   # 앱 UI
│   ├── CloudNotesApp.swift          # @main 앱 진입점
│   ├── ContentView.swift            # 메인 노트 리스트
│   ├── NoteEditorView.swift         # 노트 편집 화면
│   ├── SyncStatusView.swift         # 동기화 상태 표시
│   └── ShareView.swift              # 노트 공유 화면
│
└── README.md
```

## 🔧 설정 방법

### 1. CloudKit 컨테이너 설정

1. Apple Developer에서 CloudKit Container 생성
2. Xcode에서 Signing & Capabilities 추가:
   - **iCloud** 활성화
   - **CloudKit** 선택
   - 컨테이너 선택 또는 생성

### 2. 레코드 타입 정의

CloudKit Dashboard에서 `Note` 레코드 타입 생성:

| 필드명 | 타입 | 설명 |
|--------|------|------|
| `title` | String | 노트 제목 |
| `content` | String | 노트 내용 |

> 시스템 필드 (`creationDate`, `modificationDate`, `recordID`)는 자동 생성됩니다.

### 3. Info.plist 설정

```xml
<key>CKContainerIdentifier</key>
<string>iCloud.com.yourcompany.CloudNotes</string>
```

## 💡 핵심 개념

### CKRecord 매핑

```swift
// Note → CKRecord 변환
func toCKRecord(in zoneID: CKRecordZone.ID = .default) -> CKRecord {
    let record = CKRecord(recordType: "Note", recordID: recordID)
    record["title"] = title as CKRecordValue
    record["content"] = content as CKRecordValue
    return record
}

// CKRecord → Note 변환
init?(from record: CKRecord) {
    guard record.recordType == "Note" else { return nil }
    self.id = record.recordID.recordName
    self.title = record["title"] as? String ?? ""
    self.content = record["content"] as? String ?? ""
}
```

### 데이터베이스 유형

| 데이터베이스 | 용도 | 접근 권한 |
|-------------|------|----------|
| `privateCloudDatabase` | 개인 노트 | 사용자 본인만 |
| `sharedCloudDatabase` | 공유받은 노트 | 공유 참여자 |
| `publicCloudDatabase` | 공개 데이터 | 모든 사용자 |

### 실시간 동기화

```swift
// 변경사항 구독 설정
let subscription = CKQuerySubscription(
    recordType: "Note",
    predicate: NSPredicate(value: true),
    options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
)

// 푸시 알림 처리
func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any]
) {
    // CloudKit 변경사항 동기화
}
```

## ✅ Human Interface Guidelines

### 동기화 상태 표시

- 동기화 진행 상태를 명확하게 표시
- 오프라인 상태 안내
- 에러 발생 시 재시도 옵션 제공

### 데이터 보호

- 삭제 전 확인 알림
- 실행 취소 지원 (swipe to delete)
- 중요 데이터는 백업 권장

### 접근성

- VoiceOver 지원
- Dynamic Type 적용
- 충분한 터치 영역

## 📝 HIG 체크리스트

- [x] **동기화 피드백**: 상태 아이콘 + 메시지로 명확하게 표시
- [x] **오프라인 지원**: 로컬 캐시로 오프라인에서도 읽기/쓰기 가능
- [x] **에러 처리**: 사용자 친화적 에러 메시지 + 재시도 옵션
- [x] **Pull to Refresh**: 표준 제스처로 수동 새로고침
- [x] **검색**: Searchable modifier로 노트 검색
- [x] **Swipe Actions**: 삭제/공유 빠른 액션

## 🔗 참고 자료

- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [iCloud Design Guide](https://developer.apple.com/design/human-interface-guidelines/icloud)
- [CKSyncEngine (iOS 17+)](https://developer.apple.com/documentation/cloudkit/cksyncengine)

## ⚠️ 주의사항

1. **시뮬레이터**: CloudKit은 실제 기기에서 테스트 권장
2. **iCloud 계정**: 테스트 시 iCloud 로그인 필요
3. **개발/프로덕션**: Development/Production 환경 분리
4. **쿼리 제한**: 한 번에 가져올 수 있는 레코드 수 제한 있음 (기본 100개)
