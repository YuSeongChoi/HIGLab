import SwiftUI

struct CallEndedView: View {
    let call: CallInfo
    let endReason: CallEndReason
    let duration: TimeInterval
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 상태 아이콘
                Image(systemName: iconForReason)
                    .font(.system(size: 60))
                    .foregroundStyle(colorForReason)
                
                // 발신자 정보
                VStack(spacing: 8) {
                    Text(call.callerName ?? "알 수 없음")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text(call.handle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // 종료 상태
                Text(endReason.displayText)
                    .font(.headline)
                    .foregroundStyle(colorForReason)
                
                // 통화 시간
                if duration > 0 {
                    Text(formattedDuration)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 하단 버튼들
                HStack(spacing: 40) {
                    ActionButton(icon: "phone.fill", label: "다시 전화") {
                        // 재통화
                    }
                    
                    ActionButton(icon: "message.fill", label: "메시지") {
                        // 메시지 보내기
                    }
                }
                
                // 닫기 버튼
                Button("닫기") {
                    onDismiss()
                }
                .font(.headline)
                .padding(.top, 20)
            }
            .foregroundStyle(.white)
            .padding()
        }
    }
    
    private var iconForReason: String {
        switch endReason {
        case .normal: "checkmark.circle.fill"
        case .missed: "phone.arrow.down.left"
        case .declined: "xmark.circle.fill"
        case .failed: "exclamationmark.triangle.fill"
        case .remoteEnded: "phone.down.fill"
        case .busy: "phone.badge.waveform.fill"
        }
    }
    
    private var colorForReason: Color {
        switch endReason {
        case .normal: .green
        case .missed, .declined, .failed: .red
        case .remoteEnded: .orange
        case .busy: .yellow
        }
    }
    
    private var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "통화 시간: %d분 %d초", minutes, seconds)
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
                Text(label)
                    .font(.caption)
            }
        }
    }
}

struct CallInfo {
    let uuid: UUID
    let handle: String
    let callerName: String?
}

enum CallEndReason {
    case normal, missed, declined, failed, remoteEnded, busy
    var displayText: String {
        switch self {
        case .normal: "통화 종료"
        case .missed: "부재중 전화"
        case .declined: "거절됨"
        case .failed: "연결 실패"
        case .remoteEnded: "상대방이 종료함"
        case .busy: "통화 중"
        }
    }
}
