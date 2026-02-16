// CallKit 주요 클래스 개요

import CallKit

// CXProvider: 시스템에 통화 이벤트 보고
// - 수신 전화 표시
// - 통화 상태 업데이트

// CXCallController: 통화 액션 요청
// - 발신 전화 시작
// - 통화 종료, 음소거 등

// CXTransaction: 여러 액션을 묶음
// - 원자적 실행 보장

// CXAction 종류:
// - CXStartCallAction: 발신 전화 시작
// - CXAnswerCallAction: 수신 전화 응답
// - CXEndCallAction: 통화 종료
// - CXSetMutedCallAction: 음소거
// - CXSetHeldCallAction: 보류
// - CXPlayDTMFCallAction: DTMF 톤
