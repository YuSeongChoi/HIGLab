import SwiftUI

// MARK: - 다이얼러 뷰
// 전화번호 입력 및 발신을 위한 키패드 화면

/// 다이얼러 뷰
struct DialerView: View {
    @EnvironmentObject var callManager: CallManager
    @EnvironmentObject var contactStore: ContactStore
    
    /// 입력된 전화번호
    @State private var phoneNumber: String = ""
    
    /// 매칭되는 연락처
    @State private var matchingContact: Contact?
    
    /// 키패드 버튼 데이터
    private let keypadButtons: [[KeypadButton]] = [
        [.init(digit: "1", letters: ""), .init(digit: "2", letters: "ABC"), .init(digit: "3", letters: "DEF")],
        [.init(digit: "4", letters: "GHI"), .init(digit: "5", letters: "JKL"), .init(digit: "6", letters: "MNO")],
        [.init(digit: "7", letters: "PQRS"), .init(digit: "8", letters: "TUV"), .init(digit: "9", letters: "WXYZ")],
        [.init(digit: "*", letters: ""), .init(digit: "0", letters: "+"), .init(digit: "#", letters: "")]
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                // 전화번호 표시 영역
                phoneNumberDisplay
                
                // 매칭 연락처 표시
                if let contact = matchingContact {
                    matchingContactView(contact)
                }
                
                Spacer()
                
                // 키패드
                keypadGrid
                
                // 하단 버튼
                bottomButtons
                
                Spacer()
            }
            .padding()
            .navigationTitle("키패드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // 테스트용 수신 전화 버튼
                    Button(action: {
                        callManager.simulateIncomingCall()
                    }) {
                        Image(systemName: "phone.arrow.down.left")
                            .foregroundColor(.orange)
                    }
                }
            }
            .onChange(of: phoneNumber) { _, newValue in
                // 전화번호 변경 시 연락처 검색
                matchingContact = contactStore.findContact(byPhoneNumber: newValue)
            }
        }
    }
    
    // MARK: - 전화번호 표시
    
    /// 전화번호 표시 영역
    private var phoneNumberDisplay: some View {
        Text(formattedPhoneNumber)
            .font(.system(size: 36, weight: .regular, design: .default))
            .foregroundColor(.primary)
            .frame(height: 50)
            .animation(.none, value: phoneNumber)
    }
    
    /// 포맷된 전화번호
    private var formattedPhoneNumber: String {
        guard !phoneNumber.isEmpty else { return "" }
        
        // 한국 전화번호 형식으로 포맷팅
        let digits = phoneNumber
        
        if digits.count <= 3 {
            return digits
        } else if digits.count <= 7 {
            let prefix = digits.prefix(3)
            let middle = digits.dropFirst(3)
            return "\(prefix)-\(middle)"
        } else {
            let prefix = digits.prefix(3)
            let middle = digits.dropFirst(3).prefix(4)
            let suffix = digits.dropFirst(7)
            return "\(prefix)-\(middle)-\(suffix)"
        }
    }
    
    // MARK: - 매칭 연락처
    
    /// 매칭 연락처 표시 뷰
    private func matchingContactView(_ contact: Contact) -> some View {
        HStack(spacing: 12) {
            ContactAvatar(contact: contact, size: 36)
            
            Text(contact.name)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(20)
    }
    
    // MARK: - 키패드
    
    /// 키패드 그리드
    private var keypadGrid: some View {
        VStack(spacing: 16) {
            ForEach(keypadButtons, id: \.self) { row in
                HStack(spacing: 24) {
                    ForEach(row) { button in
                        keypadButtonView(button)
                    }
                }
            }
        }
    }
    
    /// 키패드 버튼 뷰
    private func keypadButtonView(_ button: KeypadButton) -> some View {
        Button(action: {
            // 햅틱 피드백
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            // 숫자 추가
            phoneNumber.append(button.digit)
        }) {
            VStack(spacing: 2) {
                Text(button.digit)
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(.primary)
                
                Text(button.letters)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(height: 12)
            }
            .frame(width: 80, height: 80)
            .background(Color.secondary.opacity(0.1))
            .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 하단 버튼
    
    /// 하단 버튼 영역
    private var bottomButtons: some View {
        HStack(spacing: 40) {
            // 왼쪽 빈 공간
            Color.clear
                .frame(width: 60, height: 60)
            
            // 전화 버튼
            Button(action: {
                if !phoneNumber.isEmpty {
                    callManager.startCall(to: phoneNumber)
                }
            }) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(phoneNumber.isEmpty ? Color.gray : Color.green)
                    .clipShape(Circle())
            }
            .disabled(phoneNumber.isEmpty)
            
            // 삭제 버튼
            Button(action: {
                if !phoneNumber.isEmpty {
                    phoneNumber.removeLast()
                }
            }) {
                Image(systemName: "delete.left")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
                    .frame(width: 60, height: 60)
            }
            .opacity(phoneNumber.isEmpty ? 0 : 1)
        }
    }
}

// MARK: - 키패드 버튼 모델

/// 키패드 버튼 데이터
struct KeypadButton: Identifiable, Hashable {
    let id = UUID()
    let digit: String
    let letters: String
}

// MARK: - 프리뷰

#Preview {
    DialerView()
        .environmentObject(CallManager.shared)
        .environmentObject(ContactStore.shared)
}
