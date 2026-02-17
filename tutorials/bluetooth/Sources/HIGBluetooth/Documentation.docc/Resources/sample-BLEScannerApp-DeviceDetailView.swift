//
//  DeviceDetailView.swift
//  BLEScanner
//
//  BLE 기기 상세 정보 - 서비스, 특성, 데이터 읽기/쓰기
//

import SwiftUI
import CoreBluetooth

/// 기기 상세 정보 뷰
struct DeviceDetailView: View {
    
    // MARK: - Properties
    
    /// 표시할 기기
    @ObservedObject var device: DiscoveredDevice
    
    // MARK: - Environment
    
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @EnvironmentObject var deviceConnection: DeviceConnection
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    /// 확장된 서비스 UUID 목록
    @State private var expandedServices: Set<CBUUID> = []
    
    /// 쓰기 대상 특성
    @State private var writeTarget: CBCharacteristic?
    
    /// 쓰기할 데이터
    @State private var writeData = ""
    
    /// 쓰기 시트 표시 여부
    @State private var showingWriteSheet = false
    
    // MARK: - Body
    
    var body: some View {
        List {
            // 기기 정보 섹션
            deviceInfoSection
            
            // 연결 섹션
            connectionSection
            
            // 서비스 및 특성 섹션
            if device.connectionState == .connected {
                servicesSection
            }
        }
        .navigationTitle(device.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("닫기") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingWriteSheet) {
            writeDataSheet
        }
    }
    
    // MARK: - 기기 정보 섹션
    
    private var deviceInfoSection: some View {
        Section("기기 정보") {
            // UUID
            LabeledContent("UUID") {
                Text(device.id.uuidString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            }
            
            // 신호 강도
            LabeledContent("신호 강도") {
                HStack {
                    RSSIBarView(rssi: device.rssi)
                        .frame(width: 60)
                    Text("\(device.rssi) dBm")
                        .font(.system(.body, design: .monospaced))
                }
            }
            
            // 신호 품질
            LabeledContent("신호 품질") {
                HStack {
                    Image(systemName: device.signalStrength.symbolName)
                        .foregroundColor(signalColor(for: device.signalStrength))
                    Text(device.signalStrength.rawValue)
                }
            }
            
            // 연결 가능 여부
            LabeledContent("연결 가능") {
                Image(systemName: device.isConnectable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(device.isConnectable ? .green : .red)
            }
            
            // 마지막 발견
            LabeledContent("마지막 발견") {
                Text(device.lastSeen, style: .relative)
            }
            
            // 송신 전력 (있는 경우)
            if let txPower = device.txPowerLevel {
                LabeledContent("송신 전력") {
                    Text("\(txPower) dBm")
                }
            }
            
            // 제조사 데이터 (있는 경우)
            if let manufacturerData = device.manufacturerData {
                LabeledContent("제조사 데이터") {
                    Text(manufacturerData.hexString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - 연결 섹션
    
    private var connectionSection: some View {
        Section("연결") {
            // 연결 상태
            LabeledContent("상태") {
                HStack {
                    connectionStateIcon
                    Text(device.connectionState.rawValue)
                }
            }
            
            // 연결/해제 버튼
            Button {
                if device.connectionState == .connected {
                    bluetoothManager.disconnect(from: device)
                } else {
                    bluetoothManager.connect(to: device)
                }
            } label: {
                HStack {
                    Spacer()
                    
                    if device.connectionState == .connecting ||
                       device.connectionState == .disconnecting {
                        ProgressView()
                            .padding(.trailing, 8)
                    }
                    
                    Text(connectionButtonTitle)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
            }
            .disabled(!device.isConnectable ||
                      device.connectionState == .connecting ||
                      device.connectionState == .disconnecting)
            .foregroundColor(connectionButtonColor)
        }
    }
    
    /// 연결 상태 아이콘
    @ViewBuilder
    private var connectionStateIcon: some View {
        switch device.connectionState {
        case .connected:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .connecting, .disconnecting:
            ProgressView()
                .scaleEffect(0.7)
        case .disconnected:
            Image(systemName: "circle")
                .foregroundColor(.gray)
        }
    }
    
    /// 연결 버튼 제목
    private var connectionButtonTitle: String {
        switch device.connectionState {
        case .connected:
            return "연결 해제"
        case .connecting:
            return "연결 중..."
        case .disconnecting:
            return "해제 중..."
        case .disconnected:
            return "연결"
        }
    }
    
    /// 연결 버튼 색상
    private var connectionButtonColor: Color {
        switch device.connectionState {
        case .connected:
            return .red
        case .disconnected:
            return .blue
        default:
            return .gray
        }
    }
    
    // MARK: - 서비스 섹션
    
    private var servicesSection: some View {
        Section("서비스 (\(device.services.count)개)") {
            if device.services.isEmpty {
                HStack {
                    ProgressView()
                    Text("서비스 검색 중...")
                        .foregroundColor(.secondary)
                }
            } else {
                ForEach(device.services, id: \.uuid) { service in
                    serviceRow(service)
                }
            }
        }
    }
    
    /// 서비스 Row
    @ViewBuilder
    private func serviceRow(_ service: CBService) -> some View {
        let isExpanded = expandedServices.contains(service.uuid)
        let characteristics = device.characteristics[service.uuid] ?? []
        
        VStack(alignment: .leading, spacing: 0) {
            // 서비스 헤더
            Button {
                withAnimation {
                    if isExpanded {
                        expandedServices.remove(service.uuid)
                    } else {
                        expandedServices.insert(service.uuid)
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        // 서비스 이름 또는 UUID
                        Text(serviceName(for: service))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // UUID
                        Text(service.uuid.uuidString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 특성 개수
                    Text("\(characteristics.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                    
                    // 확장 화살표
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)
            
            // 특성 목록 (확장 시)
            if isExpanded {
                ForEach(characteristics, id: \.uuid) { characteristic in
                    characteristicRow(characteristic)
                        .padding(.leading, 16)
                        .padding(.top, 12)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    /// 특성 Row
    @ViewBuilder
    private func characteristicRow(_ characteristic: CBCharacteristic) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 특성 이름
            HStack {
                Text(characteristicName(for: characteristic))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // 알림 활성화 표시
                if deviceConnection.notifyingCharacteristics.contains(characteristic.uuid) {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // UUID
            Text(characteristic.uuid.uuidString)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 속성 표시
            Text("속성: \(characteristic.propertiesDescription)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 값 표시 (있는 경우)
            if let value = deviceConnection.characteristicValues[characteristic.uuid] {
                VStack(alignment: .leading, spacing: 2) {
                    Text("값:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(value.hexString)
                        .font(.system(.caption, design: .monospaced))
                        .padding(6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                    
                    if let utf8 = value.utf8String, !utf8.isEmpty {
                        Text("UTF-8: \(utf8)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // 액션 버튼들
            HStack(spacing: 12) {
                // 읽기 버튼
                if characteristic.properties.contains(.read) {
                    Button {
                        deviceConnection.readValue(
                            from: device.peripheral,
                            characteristic: characteristic
                        )
                    } label: {
                        Label("읽기", systemImage: "arrow.down.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                
                // 쓰기 버튼
                if characteristic.properties.contains(.write) ||
                   characteristic.properties.contains(.writeWithoutResponse) {
                    Button {
                        writeTarget = characteristic
                        writeData = ""
                        showingWriteSheet = true
                    } label: {
                        Label("쓰기", systemImage: "arrow.up.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                
                // 알림 토글 버튼
                if characteristic.properties.contains(.notify) ||
                   characteristic.properties.contains(.indicate) {
                    Button {
                        deviceConnection.toggleNotify(
                            for: device.peripheral,
                            characteristic: characteristic
                        )
                    } label: {
                        let isNotifying = deviceConnection.notifyingCharacteristics.contains(characteristic.uuid)
                        Label(isNotifying ? "알림 끄기" : "알림", systemImage: isNotifying ? "bell.slash" : "bell")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    // MARK: - 쓰기 시트
    
    private var writeDataSheet: some View {
        NavigationStack {
            Form {
                Section("특성") {
                    if let target = writeTarget {
                        Text(characteristicName(for: target))
                        Text(target.uuid.uuidString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("데이터 (16진수)") {
                    TextField("예: 01 02 03", text: $writeData)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Text("공백으로 구분된 16진수 바이트를 입력하세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button("쓰기") {
                        if let target = writeTarget,
                           let data = parseHexString(writeData) {
                            deviceConnection.writeValue(
                                to: device.peripheral,
                                characteristic: target,
                                data: data
                            )
                            showingWriteSheet = false
                        }
                    }
                    .disabled(parseHexString(writeData) == nil)
                }
            }
            .navigationTitle("데이터 쓰기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        showingWriteSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 서비스 이름 가져오기
    private func serviceName(for service: CBService) -> String {
        StandardBLEService.name(for: service.uuid) ?? "서비스"
    }
    
    /// 특성 이름 가져오기
    private func characteristicName(for characteristic: CBCharacteristic) -> String {
        StandardBLECharacteristic.name(for: characteristic.uuid) ?? "특성"
    }
    
    /// 신호 색상
    private func signalColor(for strength: DiscoveredDevice.SignalStrength) -> Color {
        switch strength {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .weak: return .red
        }
    }
    
    /// 16진수 문자열 파싱
    private func parseHexString(_ string: String) -> Data? {
        let hex = string.replacingOccurrences(of: " ", with: "")
        
        guard hex.count % 2 == 0 else { return nil }
        
        var data = Data()
        var index = hex.startIndex
        
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else {
                return nil
            }
            data.append(byte)
            index = nextIndex
        }
        
        return data.isEmpty ? nil : data
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        Text("DeviceDetailView는 실제 기기 연결 시 표시됩니다")
    }
    .environmentObject(BluetoothManager.shared)
    .environmentObject(DeviceConnection.shared)
}
