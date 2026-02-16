import SwiftUI

struct DeviceRow: View {
    let device: DiscoveredDevice
    let onConnect: () -> Void
    
    var signalStrength: SignalStrength {
        SignalStrength(rssi: device.rssi)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                
                Text("RSSI: \(device.rssi) dBm")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if !device.serviceUUIDs.isEmpty {
                    Text("서비스: \(device.serviceUUIDs.count)개")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            // 신호 세기 표시
            Image(systemName: signalStrength.iconName)
                .foregroundStyle(signalStrength.color)
            
            Button("연결") {
                onConnect()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}
