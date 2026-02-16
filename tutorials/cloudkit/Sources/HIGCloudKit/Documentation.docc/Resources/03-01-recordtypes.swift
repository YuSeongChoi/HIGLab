import CloudKit

// CKRecord가 지원하는 데이터 타입

// 기본 타입
// - String: 텍스트 데이터
// - Int64, Double: 숫자 데이터
// - Date: 날짜/시간
// - Data: 바이너리 데이터 (최대 1MB)
// - Bool: (Int64로 저장됨)

// 특수 타입
// - CKAsset: 파일 (이미지, 비디오 등)
// - CLLocation: 위치 좌표
// - CKRecord.Reference: 다른 레코드 참조

// 배열 타입
// - [String], [Int64], [Double], [Date], [Data]
// - [CKRecord.Reference], [CLLocation]

// 지원하지 않는 타입
// - UIImage, NSImage (CKAsset으로 변환 필요)
// - Codable 구조체 (필드별 저장 필요)
// - 커스텀 클래스
