import SwiftUI

struct DialerView: View {
    @State private var phoneNumber = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            // 전화번호 입력
            TextField("전화번호", text: $phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
                .padding()
            
            // 다이얼 패드
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
                ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"], id: \.self) { digit in
                    Button(digit) {
                        phoneNumber += digit
                    }
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
                }
            }
            
            // 전화 걸기 버튼
            Button {
                Task {
                    await startCall()
                }
            } label: {
                Image(systemName: "phone.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 70)
                    .background(Color.green)
                    .clipShape(Circle())
            }
            .disabled(phoneNumber.isEmpty || isLoading)
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }
    
    private func startCall() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await CallManager.shared.startCall(to: phoneNumber)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// CallManager 확장
extension CallManager {
    static let shared = CallManager()
    
    func startCall(to phoneNumber: String, hasVideo: Bool = false) async throws -> UUID {
        // 구현은 04-06 참조
        return UUID()
    }
}

class CallManager: NSObject { }
