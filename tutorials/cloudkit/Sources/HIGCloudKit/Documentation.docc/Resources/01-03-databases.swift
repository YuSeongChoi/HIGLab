import CloudKit
import SwiftUI

// 세 가지 데이터베이스 타입

// 1. Private Database
// - 사용자 개인 데이터 저장
// - 해당 사용자만 접근 가능
// - 사용자의 iCloud 저장 공간 사용
// - 커스텀 Zone 생성 가능

// 2. Public Database
// - 모든 사용자가 접근 가능 (로그인 없이도 읽기 가능)
// - 앱 개발자의 CloudKit 저장 공간 사용
// - 기본 Zone만 사용 (커스텀 Zone 불가)
// - 공개 데이터, 앱 설정 등에 적합

// 3. Shared Database
// - CKShare를 통해 공유받은 데이터 접근
// - 다른 사용자의 Private DB 데이터 참조
// - 읽기/쓰기 권한은 공유 설정에 따름
