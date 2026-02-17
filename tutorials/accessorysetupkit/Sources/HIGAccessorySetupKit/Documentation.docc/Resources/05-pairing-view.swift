import SwiftUI
import AccessorySetupKit

struct PairingView: View {
    @State private var manager = PairingManager()
    
    var body: some View {
        VStack(spacing: 24) {
            // 상태 표시
            StatusIndicator(state: manager.state)
            
            // 페어링된 기기 정보
            if let accessory = manager.pairedAccessory {
                AccessoryInfoCard(accessory: accessory)
            }
            
            // 액션 버튼
            actionButton
        }
        .padding()
        .onAppear {
            manager.startSession()
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch manager.state {
        case .ready:
            Button("기기 추가") {
                manager.showPicker()
            }
            .buttonStyle(.borderedProminent)
            
        case .paired:
            Button("연결 해제", role: .destructive) {
                manager.unpair()
            }
            
        case .failed:
            Button("다시 시도") {
                manager.startSession()
            }
            
        default:
            ProgressView()
        }
    }
}

struct StatusIndicator: View {
    let state: PairingState
    
    var body: some View {
        Label(state.description, systemImage: state.isConnected ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(state.isConnected ? .green : .secondary)
    }
}
