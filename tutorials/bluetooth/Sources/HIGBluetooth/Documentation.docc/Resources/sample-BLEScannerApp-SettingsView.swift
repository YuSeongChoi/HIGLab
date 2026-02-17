//
//  SettingsView.swift
//  BLEScanner
//
//  BLE 스캔 설정 화면
//

import SwiftUI
import CoreBluetooth

/// 스캔 설정 뷰
struct SettingsView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State (로컬 설정값)
    
    /// 중복 허용 설정
    @State private var allowDuplicates: Bool
    
    /// 오래된 기기 제거 시간
    @State private var staleTimeout: Double
    
    /// 서비스 필터 사용 여부
    @State private var useServiceFilter = false
    
    /// 필터링할 서비스 UUID 문자열
    @State private var filterServiceUUID = ""
    
    /// 사전 정의 서비스 필터 선택
    @State private var selectedPredefinedFilters: Set<PredefinedServiceFilter> = []
    
    // MARK: - 초기화
    
    init() {
        // BluetoothManager의 현재 값으로 초기화
        _allowDuplicates = State(initialValue: BluetoothManager.shared.allowDuplicates)
        _staleTimeout = State(initialValue: BluetoothManager.shared.staleDeviceTimeout)
    }
    
    // MARK: - 사전 정의 서비스 필터
    
    enum PredefinedServiceFilter: String, CaseIterable, Identifiable {
        case heartRate = "심박수"
        case battery = "배터리"
        case deviceInfo = "기기 정보"
        case bloodPressure = "혈압"
        case healthThermometer = "체온계"
        
        var id: String { rawValue }
        
        var uuid: CBUUID {
            switch self {
            case .heartRate: return CBUUID(string: "180D")
            case .battery: return CBUUID(string: "180F")
            case .deviceInfo: return CBUUID(string: "180A")
            case .bloodPressure: return CBUUID(string: "1810")
            case .healthThermometer: return CBUUID(string: "1809")
            }
        }
        
        var iconName: String {
            switch self {
            case .heartRate: return "heart.fill"
            case .battery: return "battery.100"
            case .deviceInfo: return "info.circle"
            case .bloodPressure: return "waveform.path.ecg"
            case .healthThermometer: return "thermometer"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                // Bluetooth 상태 섹션
                bluetoothStatusSection
                
                // 스캔 설정 섹션
                scanSettingsSection
                
                // 서비스 필터 섹션
                serviceFilterSection
                
                // 정보 섹션
                infoSection
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        applySettings()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Bluetooth 상태 섹션
    
    private var bluetoothStatusSection: some View {
        Section("Bluetooth 상태") {
            LabeledContent("상태") {
                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                    Text(bluetoothManager.stateDescription)
                }
            }
            
            LabeledContent("스캔 중") {
                Text(bluetoothManager.isScanning ? "예" : "아니오")
                    .foregroundColor(bluetoothManager.isScanning ? .green : .secondary)
            }
            
            LabeledContent("발견된 기기") {
                Text("\(bluetoothManager.discoveredDevices.count)개")
            }
            
            if let connected = bluetoothManager.connectedDevice {
                LabeledContent("연결된 기기") {
                    Text(connected.name)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    /// 상태 색상
    private var statusColor: Color {
        switch bluetoothManager.state {
        case .poweredOn: return .green
        case .poweredOff: return .orange
        default: return .red
        }
    }
    
    // MARK: - 스캔 설정 섹션
    
    private var scanSettingsSection: some View {
        Section {
            // 중복 허용
            Toggle("중복 기기 허용", isOn: $allowDuplicates)
            
            Text("활성화하면 같은 기기가 광고할 때마다 RSSI가 업데이트됩니다. 배터리 소모가 증가할 수 있습니다.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 오래된 기기 제거 시간
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("오래된 기기 제거")
                    Spacer()
                    Text("\(Int(staleTimeout))초")
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $staleTimeout, in: 10...120, step: 10)
            }
            
            Text("이 시간 동안 광고가 감지되지 않는 기기는 목록에서 제거됩니다.")
                .font(.caption)
                .foregroundColor(.secondary)
            
        } header: {
            Text("스캔 설정")
        }
    }
    
    // MARK: - 서비스 필터 섹션
    
    private var serviceFilterSection: some View {
        Section {
            // 필터 사용 토글
            Toggle("서비스 필터 사용", isOn: $useServiceFilter)
            
            if useServiceFilter {
                // 사전 정의 필터
                VStack(alignment: .leading, spacing: 8) {
                    Text("빠른 선택")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(PredefinedServiceFilter.allCases) { filter in
                            Button {
                                if selectedPredefinedFilters.contains(filter) {
                                    selectedPredefinedFilters.remove(filter)
                                } else {
                                    selectedPredefinedFilters.insert(filter)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: filter.iconName)
                                    Text(filter.rawValue)
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    selectedPredefinedFilters.contains(filter)
                                    ? Color.blue.opacity(0.2)
                                    : Color.gray.opacity(0.1)
                                )
                                .foregroundColor(
                                    selectedPredefinedFilters.contains(filter)
                                    ? .blue
                                    : .primary
                                )
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // 커스텀 UUID 입력
                VStack(alignment: .leading, spacing: 4) {
                    TextField("커스텀 UUID (예: 180F)", text: $filterServiceUUID)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                    
                    Text("16비트 또는 128비트 UUID를 입력하세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
        } header: {
            Text("서비스 필터")
        } footer: {
            if useServiceFilter {
                Text("특정 서비스를 광고하는 기기만 스캔합니다. 필터가 없으면 모든 기기를 스캔합니다.")
            }
        }
    }
    
    // MARK: - 정보 섹션
    
    private var infoSection: some View {
        Section("정보") {
            LabeledContent("앱 버전") {
                Text("1.0.0")
            }
            
            LabeledContent("CoreBluetooth") {
                Text("iOS 17.0+")
            }
            
            // 초기화 버튼
            Button(role: .destructive) {
                resetToDefaults()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("기본값으로 초기화")
                }
            }
        }
    }
    
    // MARK: - 액션
    
    /// 설정 적용
    private func applySettings() {
        bluetoothManager.allowDuplicates = allowDuplicates
        bluetoothManager.staleDeviceTimeout = staleTimeout
        
        // 서비스 필터 적용
        if useServiceFilter {
            var filters: [CBUUID] = selectedPredefinedFilters.map { $0.uuid }
            
            // 커스텀 UUID 추가
            if !filterServiceUUID.isEmpty {
                let customUUID = CBUUID(string: filterServiceUUID)
                filters.append(customUUID)
            }
            
            bluetoothManager.serviceUUIDFilter = filters.isEmpty ? nil : filters
        } else {
            bluetoothManager.serviceUUIDFilter = nil
        }
        
        // 스캔 중이면 재시작하여 새 설정 적용
        if bluetoothManager.isScanning {
            bluetoothManager.stopScanning()
            bluetoothManager.startScanning()
        }
    }
    
    /// 기본값으로 초기화
    private func resetToDefaults() {
        allowDuplicates = false
        staleTimeout = 30
        useServiceFilter = false
        filterServiceUUID = ""
        selectedPredefinedFilters = []
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(BluetoothManager.shared)
}
