import CloudKit

// CloudKit 구독 타입

// 1. CKQuerySubscription
// - 특정 조건(NSPredicate)을 만족하는 레코드 변경 감지
// - Public/Private Database에서 사용
// - 레코드 생성/수정/삭제 시 알림

// 2. CKRecordZoneSubscription
// - 특정 Zone의 모든 변경 감지
// - Private Database에서만 사용
// - 커스텀 Zone 필요

// 3. CKDatabaseSubscription
// - 데이터베이스 전체 변경 감지
// - Private/Shared Database에서 사용
// - Shared Database의 공유 변경 추적에 유용
