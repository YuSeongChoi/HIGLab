import LocalAuthentication

let context = LAContext()

// localizedCancelTitle: 취소 버튼 텍스트

// 기본값: "취소" (또는 "Cancel")
context.localizedCancelTitle = nil

// 커스텀 텍스트 설정
context.localizedCancelTitle = "나중에"
context.localizedCancelTitle = "건너뛰기"
context.localizedCancelTitle = "다음에 하기"

// 앱 맥락에 맞게 설정:
// - 온보딩: "나중에 설정"
// - 민감한 작업: "취소" (기본값 유지)
// - 선택적 기능: "건너뛰기"
