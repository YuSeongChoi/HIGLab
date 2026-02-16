import CloudKit

// CKShare 구조
// - CKRecord의 특수 서브클래스
// - rootRecord: 공유할 레코드 (또는 Zone 전체)
// - participants: 참여자 목록
// - publicPermission: URL을 통한 기본 접근 권한
// - url: 공유 링크

// 참여자 역할 (CKShare.ParticipantRole)
// - .owner: 공유를 만든 사람
// - .privateUser: 초대받은 사용자
// - .publicUser: URL로 접근한 사용자

// 참여자 권한 (CKShare.ParticipantPermission)
// - .none: 권한 없음
// - .readOnly: 읽기만 가능
// - .readWrite: 읽기/쓰기 가능

// 공개 권한 (CKShare.ParticipantPermission)
// - .none: URL만으로는 접근 불가 (초대 필요)
// - .readOnly: URL로 읽기 가능
// - .readWrite: URL로 읽기/쓰기 가능
