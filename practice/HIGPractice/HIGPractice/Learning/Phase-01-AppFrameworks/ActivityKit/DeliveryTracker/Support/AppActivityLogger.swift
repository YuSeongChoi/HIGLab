import ActivityKit
import SwiftUI
import os.log

// 이 파일은 앱 타깃의 ActivityKit Lifecycle/Push/Error 로그를 남기는 로깅 유틸리티입니다.
// MARK: - App Activity 로거
struct AppActivityLogger {
    // 카테고리별 로거 분리
    static let lifecycle = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "app",
        category: "Activity.Lifecycle"
    )
    
    static let push = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "app",
        category: "Activity.Push"
    )
    
    static let error = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "app",
        category: "Activity.Error"
    )
    
    // MARK: - Lifecycle 로깅
    
    static func logStart(id: String, attributes: Any) {
        lifecycle.info("🟢 Activity 시작: \(id)")
        lifecycle.debug("Attributes: \(String(describing: attributes))")
    }
    
    static func logUpdate(id: String, state: Any) {
        lifecycle.info("🔄 Activity 업데이트: \(id)")
        lifecycle.debug("New State: \(String(describing: state))")
    }
    
    static func logEnd(id: String, reason: String) {
        lifecycle.info("🔴 Activity 종료: \(id), 사유: \(reason)")
    }
    
    // MARK: - Push 로깅
    
    static func logTokenReceived(_ token: Data) {
        let tokenString = token.map { String(format: "%02x", $0) }.joined()
        push.info("📲 Push Token 수신: \(tokenString.prefix(20))...")
    }
    
    static func logTokenSent(success: Bool) {
        if success {
            push.info("✅ Token 서버 전송 성공")
        } else {
            push.warning("⚠️ Token 서버 전송 실패")
        }
    }
    
    // MARK: - Error 로깅
    
    static func logError(_ error: Error, context: String) {
        Self.error.error("❌ \(context): \(error.localizedDescription)")
    }
}
