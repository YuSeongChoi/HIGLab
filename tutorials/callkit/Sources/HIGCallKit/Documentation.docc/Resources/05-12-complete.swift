import SwiftUI

struct ActiveCallView: View {
    @StateObject private var viewModel: CallViewModel
    
    init(call: CallInfo) {
        _viewModel = StateObject(wrappedValue: CallViewModel(call: call))
    }
    
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: backgroundColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // 발신자 정보
                CallerInfoView(call: viewModel.call)
                
                // 통화 상태 (타이머 등)
                CallStateView(state: viewModel.callState)
                    .padding(.top, 8)
                
                Spacer()
                
                // 통화 중일 때만 컨트롤 표시
                if viewModel.isActive {
                    CallControlsView(viewModel: viewModel)
                }
                
                Spacer()
                    .frame(height: 60)
            }
        }
        .sheet(isPresented: $viewModel.showKeypad) {
            KeypadView(onDigit: viewModel.sendDTMF)
        }
    }
    
    private var backgroundColors: [Color] {
        switch viewModel.callState {
        case .onHold:
            [.orange.opacity(0.8), .orange.opacity(0.4)]
        case .ended:
            [.gray.opacity(0.8), .gray.opacity(0.4)]
        default:
            [.blue.opacity(0.8), .blue.opacity(0.4)]
        }
    }
}

struct KeypadView: View {
    let onDigit: (String) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
            ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"], id: \.self) { digit in
                Button(digit) {
                    onDigit(digit)
                }
                .font(.title)
                .frame(width: 70, height: 70)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
            }
        }
        .padding()
    }
}

@MainActor
class CallViewModel: ObservableObject {
    @Published var call: CallInfo
    @Published var callState: CallState = .connecting
    @Published var isMuted = false
    @Published var isSpeaker = false
    @Published var isOnHold = false
    @Published var showKeypad = false
    
    var isActive: Bool {
        switch callState {
        case .connected, .onHold: true
        default: false
        }
    }
    
    init(call: CallInfo) {
        self.call = call
    }
    
    func toggleMute() { isMuted.toggle() }
    func toggleSpeaker() { isSpeaker.toggle() }
    func toggleHold() { isOnHold.toggle() }
    func endCall() { }
    func sendDTMF(_ digit: String) { }
    func addCall() { }
    func startVideo() { }
}

struct CallInfo {
    let uuid: UUID
    let handle: String
    let callerName: String?
}

enum CallState {
    case connecting, ringing, connected(Date), onHold, ended(CallEndReason)
}

enum CallEndReason {
    case normal, missed, declined, failed, remoteEnded, busy
}

struct CallerInfoView: View {
    let call: CallInfo
    var body: some View { Text(call.callerName ?? call.handle) }
}

struct CallStateView: View {
    let state: CallState
    var body: some View { Text("") }
}

struct CallControlsView: View {
    @ObservedObject var viewModel: CallViewModel
    var body: some View { Text("Controls") }
}
