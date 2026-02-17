import SwiftUI

// MARK: - 수신 전화 뷰
// 전화가 왔을 때 표시되는 전체 화면 UI

/// 수신 전화 뷰
struct IncomingCallView: View {
    @EnvironmentObject var callManager: CallManager
    @EnvironmentObject var contactStore: ContactStore
    
    /// 애니메이션 상태
    @State private var isPulsing: Bool = false
    
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
            // 배경 그라데이션
            LinearGradient(
                colors: [Color.black.opacity(0.9), Color.gray.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 수신 중 레이블
                incomingLabel
                
                // 발신자 정보
                callerInfo
                
                Spacer()
                
                // 퀵 액션 버튼
                quickActions
                
                // 응답/거절 버튼
                callActionButtons
                
                Spacer()
                    .frame(height: 50)
            }
        }
    }
    
    // MARK: - 수신 중 레이블
    
    /// 수신 중 레이블
    private var incomingLabel: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.green)
                .frame(width: 12, height: 12)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .animation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                    value: isPulsing
                )
            
            Text("수신 전화")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
        }
        .onAppear {
            isPulsing = true
        }
    }
    
    // MARK: - 발신자 정보
    
    /// 발신자 정보 뷰
    private var callerInfo: some View {
        VStack(spacing: 20) {
            // 아바타
            callerAvatar
            
            // 이름
            Text(call?.displayName ?? "알 수 없음")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
            
            // 전화번호 (이름이 있는 경우에만 표시)
            if contact != nil {
                Text(call?.remotePhoneNumber ?? "")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    /// 발신자 아바타
    private var callerAvatar: some View {
        ZStack {
            // 펄스 애니메이션 배경
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 140 + CGFloat(index * 20), height: 140 + CGFloat(index * 20))
                    .scaleEffect(isPulsing ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: isPulsing
                    )
            }
            
            // 아바타 또는 기본 아이콘
            if let contact = contact {
                ContactAvatar(contact: contact, size: 120)
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    // MARK: - 퀵 액션
    
    /// 퀵 액션 버튼
    private var quickActions: some View {
        HStack(spacing: 60) {
            // 메시지로 답장
            quickActionButton(
                icon: "message.fill",
                label: "메시지",
                action: {}
            )
            
            // 미리 알림
            quickActionButton(
                icon: "bell.fill",
                label: "미리 알림",
                action: {}
            )
        }
    }
    
    /// 퀵 액션 버튼 뷰
    private func quickActionButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    // MARK: - 응답/거절 버튼
    
    /// 응답/거절 버튼 영역
    private var callActionButtons: some View {
        HStack(spacing: 60) {
            // 거절 버튼
            Button(action: {
                callManager.endCall()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .clipShape(Circle())
                    
                    Text("거절")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // 응답 버튼
            Button(action: {
                callManager.answerCall()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.green)
                        .clipShape(Circle())
                    
                    Text("응답")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

// MARK: - 프리뷰

#Preview {
    IncomingCallView()
        .environmentObject(CallManager.shared)
        .environmentObject(ContactStore.shared)
}
