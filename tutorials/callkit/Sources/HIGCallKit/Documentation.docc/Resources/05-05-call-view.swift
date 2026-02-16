import SwiftUI

struct ActiveCallView: View {
    let call: CallInfo
    
    var body: some View {
        ZStack {
            // 배경
            LinearGradient(
                colors: [.blue.opacity(0.8), .blue.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // 발신자 정보
                CallerInfoView(call: call)
                
                Spacer()
                
                // 통화 컨트롤
                CallControlsView(call: call)
                
                Spacer()
                    .frame(height: 60)
            }
        }
    }
}

struct CallInfo {
    let uuid: UUID
    let handle: String
    let callerName: String?
    var state: CallState = .connecting
}

enum CallState {
    case connecting
    case connected
    case onHold
    case ended
}

struct CallerInfoView: View {
    let call: CallInfo
    var body: some View {
        Text(call.callerName ?? call.handle)
    }
}

struct CallControlsView: View {
    let call: CallInfo
    var body: some View {
        Text("Controls")
    }
}
