import SwiftUI

struct ScanView: View {
    @State private var manager = BluetoothManager()
    
    var body: some View {
        NavigationStack {
            Group {
                if manager.discoveredDevices.isEmpty {
                    ContentUnavailableView(
                        "기기 검색 중",
                        systemImage: "antenna.radiowaves.left.and.right",
                        description: Text("주변의 BLE 기기를 찾고 있습니다...")
                    )
                } else {
                    List(manager.discoveredDevices) { device in
                        DeviceRow(device: device) {
                            manager.connect(to: device.peripheral)
                        }
                    }
                }
            }
            .navigationTitle("기기 스캔")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if manager.isScanning {
                            manager.stopScanning()
                        } else {
                            manager.startScanning()
                        }
                    } label: {
                        Image(systemName: manager.isScanning ? "stop.fill" : "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            if manager.isBluetoothReady {
                manager.startScanning()
            }
        }
        .onDisappear {
            manager.stopScanning()
        }
    }
}
