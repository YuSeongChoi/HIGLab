import SwiftUI
import CoreBluetooth

struct BluetoothStatusView: View {
    @State private var manager = BluetoothManager()
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: manager.bluetoothState.systemImageName)
                .font(.system(size: 60))
                .foregroundStyle(statusColor)
            
            Text(manager.bluetoothState.description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if manager.bluetoothState == .poweredOff {
                Button("설정 열기") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    var statusColor: Color {
        switch manager.bluetoothState {
        case .poweredOn: return .green
        case .poweredOff, .unauthorized, .unsupported: return .red
        default: return .orange
        }
    }
}
