import CloudKit

// 충돌 발생 시나리오

// 1. 사용자 A가 메모를 수정 (오프라인)
// 2. 사용자 B가 같은 메모를 수정하고 저장 (온라인)
// 3. 사용자 A가 온라인 되어 저장 시도
// 4. CloudKit이 충돌 감지 → CKError.serverRecordChanged

// 충돌 시 제공되는 레코드
// - ancestorRecord: 마지막으로 동기화된 원본
// - clientRecord: 클라이언트가 저장하려는 버전
// - serverRecord: 현재 서버의 최신 버전

// changeTag
// - 레코드 버전 식별자
// - 저장 시 서버의 changeTag와 비교
// - 불일치 시 충돌 발생
