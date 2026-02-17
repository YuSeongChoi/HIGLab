import SwiftUI

// MARK: - 통화 중 화면
// 통화가 연결된 후 표시되는 전체 화면 UI

/// 통화 중 뷰
struct ActiveCallView: View {
    @EnvironmentObject var callManager: CallManager
    @EnvironmentObject var contactStore: ContactStore
    
    /// 키패드 표시 여부
    @State private var showKeypad: Bool = false
    
    /// 현재 통화 정보
    private var call: Call? {
        callManager.currentCall
    }
    
    /// 연락처 정보
    private var contact: Contact? {
        guard let phoneNumber = call?.remotePhoneNumber else { return nil }
        return contactStore.findContact(byPhoneNumber: phoneNumber)
    }
    
    var body: some View {
        ZStack {
            // 배경
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 상단 여백
                Spacer()
                    .frame(height: 40)
                
                // 상태 및 시간
                callStatusView
                
                // 상대방 정보
                callerInfo
                
                Spacer()
                
                // 컨트롤 버튼 또는 키패드
                if showKeypad {
                    inCallKeypad
                } else {
                    callControlButtons
                }
                
                // 종료 버튼
                endCallButton
                
                Spacer()
                    .frame(height: 50)
            }
        }
    }
    
    // MARK: - 통화 상태
    
    /// 통화 상태 뷰
    private var callStatusView: some View {
        VStack(spacing: 4) {
            // 상태 텍스트
            Text(call?.state.displayText ?? "")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            // 통화 시간
            if call?.state == .active {
                Text(formattedDuration)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
    }
    
    /// 포맷된 통화 시간
    private var formattedDuration: String {
        let duration = callManager.callDuration
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - 상대방 정보
    
    /// 상대방 정보 뷰
    private var callerInfo: some View {
        VStack(spacing: 16) {
            // 아바타
            if let contact = contact {
                ContactAvatar(contact: contact, size: 100)
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
            }
            
            // 이름
            Text(call?.displayName ?? "알 수 없음")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
            
            // 전화번호
            if contact != nil {
                Text(call?.remotePhoneNumber ?? "")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    // MARK: - 컨트롤 버튼
    
    /// 통화 컨트롤 버튼 그리드
    private var callControlButtons: some View {
        VStack(spacing: 30) {
            // 첫 번째 줄
            HStack(spacing: 50) {
                controlButton(
                    icon: call?.isMuted == true ? "mic.slash.fill" : "mic.fill",
                    label: "음소거",
                    isActive: call?.isMuted == true
                ) {
                    callManager.toggleMute()
                }
                
                controlButton(
                    icon: "circle.grid.3x3",
                    label: "키패드",
                    isActive: false
                ) {
                    withAnimation {
                        showKeypad = true
                    }
                }
                
                controlButton(
                    icon: call?.isSpeakerOn == true ? "speaker.wave.3.fill" : "speaker.fill",
                    label: "스피커",
                    isActive: call?.isSpeakerOn == true
                ) {
                    callManager.toggleSpeaker()
                }
            }
            
            // 두 번째 줄
            HStack(spacing: 50) {
                controlButton(
                    icon: "plus",
                    label: "통화 추가",
                    isActive: false
                ) {
                    // 다자 통화 기능 (미구현)
                }
                
                controlButton(
                    icon: call?.isOnHold == true ? "play.fill" : "pause.fill",
                    label: call?.isOnHold == true ? "재개" : "보류",
                    isActive: call?.isOnHold == true
                ) {
                    callManager.toggleHold()
                }
                
                controlButton(
                    icon: "person.crop.circle.badge.plus",
                    label: "연락처",
                    isActive: false
                ) {
                    // 연락처에 추가 기능 (미구현)
                }
            }
        }
    }
    
    /// 컨트롤 버튼 뷰
    private func controlButton(
        icon: String,
        label: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(isActive ? Color.white : Color.white.opacity(0.2))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(isActive ? .black : .white)
                    )
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    // MARK: - 통화 중 키패드
    
    /// 통화 중 키패드
    private var inCallKeypad: some View {
        VStack(spacing: 16) {
            // 닫기 버튼
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        showKeypad = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                }
            }
            
            // 키패드 그리드
            let buttons = [
                ["1", "2", "3"],
                ["4", "5", "6"],
                ["7", "8", "9"],
                ["*", "0", "#"]
            ]
            
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 30) {
                    ForEach(row, id: \.self) { digit in
                        Button(action: {
                            callManager.sendDTMF(digit: digit)
                        }) {
                            Text(digit)
                                .font(.system(size: 28, weight: .regular))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 종료 버튼
    
    /// 통화 종료 버튼
    private var endCallButton: some View {
        Button(action: {
            callManager.endCall()
        }) {
            Image(systemName: "phone.down.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(Color.red)
                .clipShape(Circle())
        }
    }
}

// MARK: - 프리뷰

#Preview {
    ActiveCallView()
        .environmentObject(CallManager.shared)
        .environmentObject(ContactStore.shared)
}
