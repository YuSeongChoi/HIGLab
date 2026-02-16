import SwiftUI

struct CallerInfoView: View {
    let call: CallInfo
    
    var body: some View {
        VStack(spacing: 16) {
            // 프로필 이미지
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.white.opacity(0.9))
            
            // 발신자 이름
            Text(call.callerName ?? "알 수 없음")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            // 전화번호
            Text(formatPhoneNumber(call.handle))
                .font(.title3)
                .foregroundStyle(.white.opacity(0.8))
            
            // 통화 상태
            Text(statusText)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    private var statusText: String {
        switch call.state {
        case .connecting: "연결 중..."
        case .connected: "통화 중"
        case .onHold: "보류 중"
        case .ended: "통화 종료"
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        // 전화번호 포맷팅
        number
    }
}

struct CallInfo {
    let uuid: UUID
    let handle: String
    let callerName: String?
    var state: CallState = .connecting
}

enum CallState {
    case connecting, connected, onHold, ended
}
