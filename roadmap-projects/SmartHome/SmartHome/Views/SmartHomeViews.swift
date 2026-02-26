import SwiftUI

// MARK: - Devices View
struct DevicesView: View {
    @State private var rooms = ["거실", "침실", "주방"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(rooms, id: \.self) { room in
                        RoomCard(name: room)
                    }
                }
                .padding()
            }
            .navigationTitle("스마트홈")
        }
    }
}

struct RoomCard: View {
    let name: String
    @State private var isOn = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title)
                    .foregroundStyle(isOn ? .yellow : .gray)
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
            
            Text(name)
                .font(.headline)
            
            Text(isOn ? "켜짐" : "꺼짐")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Bluetooth Scan View
struct BluetoothScanView: View {
    @State private var manager = BluetoothManager()
    
    var body: some View {
        NavigationStack {
            Group {
                if !manager.isPoweredOn {
                    ContentUnavailableView(
                        "Bluetooth 꺼짐",
                        systemImage: "bluetooth",
                        description: Text("설정에서 Bluetooth를 켜주세요")
                    )
                } else {
                    List {
                        if let connected = manager.connectedPeripheral {
                            Section("연결됨") {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text(connected.name ?? "Unknown")
                                    Spacer()
                                    Button("연결 해제") {
                                        manager.disconnect()
                                    }
                                    .font(.caption)
                                }
                            }
                        }
                        
                        Section("발견된 기기 (\(manager.discoveredDevices.count))") {
                            ForEach(manager.discoveredDevices) { device in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(device.name)
                                            .font(.headline)
                                        Text("신호: \(device.signalStrength)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button("연결") {
                                        manager.connect(to: device)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("BLE 스캔")
            .toolbar {
                Button {
                    if manager.isScanning {
                        manager.stopScan()
                    } else {
                        manager.startScan()
                    }
                } label: {
                    Image(systemName: manager.isScanning ? "stop.circle" : "antenna.radiowaves.left.and.right")
                }
            }
        }
    }
}

// MARK: - NFC View
struct NFCView: View {
    @State private var manager = NFCManager()
    @State private var writeText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("NFC 읽기") {
                    Button {
                        manager.startReading()
                    } label: {
                        Label("태그 읽기", systemImage: "wave.3.right")
                    }
                    .disabled(!manager.isAvailable)
                    
                    if let message = manager.lastReadMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("읽은 내용:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(message)
                                .font(.body)
                        }
                    }
                }
                
                Section("NFC 쓰기") {
                    TextField("쓸 내용 입력", text: $writeText)
                    
                    Button {
                        manager.write(writeText)
                    } label: {
                        Label("태그에 쓰기", systemImage: "square.and.pencil")
                    }
                    .disabled(writeText.isEmpty || !manager.isAvailable)
                }
                
                if !manager.isAvailable {
                    Section {
                        Text("이 기기는 NFC를 지원하지 않습니다.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("NFC")
        }
    }
}

#Preview {
    ContentView()
}
