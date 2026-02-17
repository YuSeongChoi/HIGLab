//
//  ContentView.swift
//  BLEScanner
//
//  BLE 스캔 목록을 표시하는 메인 뷰
//

import SwiftUI
import CoreBluetooth

/// 메인 컨텐츠 뷰 - BLE 기기 스캔 목록
struct ContentView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    // MARK: - State
    
    /// 설정 시트 표시 여부
    @State private var showingSettings = false
    
    /// 선택된 기기 (상세 화면 이동용)
    @State private var selectedDevice: DiscoveredDevice?
    
    /// 정렬 기준
    @State private var sortOption: SortOption = .rssi
    
    /// 검색 텍스트
    @State private var searchText = ""
    
    // MARK: - 정렬 옵션
    
    enum SortOption: String, CaseIterable {
        case rssi = "신호 강도"
        case name = "이름"
        case lastSeen = "최근 발견"
    }
    
    // MARK: - Computed Properties
    
    /// 필터링 및 정렬된 기기 목록
    var filteredAndSortedDevices: [DiscoveredDevice] {
        var devices = bluetoothManager.discoveredDevices
        
        // 검색 필터 적용
        if !searchText.isEmpty {
            devices = devices.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.id.uuidString.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 정렬 적용
        switch sortOption {
        case .rssi:
            devices.sort { $0.rssi > $1.rssi }
        case .name:
            devices.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .lastSeen:
            devices.sort { $0.lastSeen > $1.lastSeen }
        }
        
        return devices
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상태 배너
                statusBanner
                
                // 기기 목록
                deviceList
            }
            .navigationTitle("BLE Scanner")
            .toolbar {
                toolbarContent
            }
            .searchable(text: $searchText, prompt: "기기 이름 또는 UUID 검색")
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(item: $selectedDevice) { device in
                NavigationStack {
                    DeviceDetailView(device: device)
                }
            }
        }
    }
    
    // MARK: - 상태 배너
    
    @ViewBuilder
    private var statusBanner: some View {
        // Bluetooth 상태에 따른 배너
        if bluetoothManager.state != .poweredOn {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                Text(statusMessage)
                Spacer()
            }
            .padding()
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
        }
        
        // 에러 메시지 배너
        if let error = bluetoothManager.errorMessage {
            HStack {
                Image(systemName: "xmark.circle.fill")
                Text(error)
                Spacer()
                Button("닫기") {
                    bluetoothManager.errorMessage = nil
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color.red.opacity(0.2))
            .foregroundColor(.red)
        }
    }
    
    /// 상태 메시지
    private var statusMessage: String {
        switch bluetoothManager.state {
        case .poweredOff:
            return "Bluetooth가 꺼져 있습니다. 설정에서 켜주세요."
        case .unauthorized:
            return "Bluetooth 권한이 필요합니다."
        case .unsupported:
            return "이 기기는 Bluetooth를 지원하지 않습니다."
        default:
            return "Bluetooth 상태: \(bluetoothManager.stateDescription)"
        }
    }
    
    /// 상태 색상
    private var statusColor: Color {
        switch bluetoothManager.state {
        case .poweredOff, .unauthorized:
            return .orange
        case .unsupported:
            return .red
        default:
            return .gray
        }
    }
    
    // MARK: - 기기 목록
    
    @ViewBuilder
    private var deviceList: some View {
        if filteredAndSortedDevices.isEmpty {
            emptyStateView
        } else {
            List(filteredAndSortedDevices) { device in
                DeviceRowView(device: device)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedDevice = device
                    }
            }
            .listStyle(.plain)
            .refreshable {
                // 새로고침 시 스캔 재시작
                bluetoothManager.stopScanning()
                try? await Task.sleep(nanoseconds: 500_000_000)
                bluetoothManager.startScanning()
            }
        }
    }
    
    /// 빈 상태 뷰
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            if bluetoothManager.isScanning {
                // 스캔 중
                ProgressView()
                    .scaleEffect(1.5)
                Text("BLE 기기 검색 중...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                // 스캔 전
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("BLE 기기 스캔")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("주변의 Bluetooth Low Energy 기기를\n검색하려면 스캔을 시작하세요")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    bluetoothManager.startScanning()
                } label: {
                    Label("스캔 시작", systemImage: "play.fill")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!bluetoothManager.isAvailable)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 왼쪽: 정렬 메뉴
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Picker("정렬", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                Label("정렬", systemImage: "arrow.up.arrow.down")
            }
        }
        
        // 중앙: 기기 수 표시
        ToolbarItem(placement: .principal) {
            if bluetoothManager.isScanning {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("\(filteredAndSortedDevices.count)개 발견")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        
        // 오른쪽: 스캔 버튼 + 설정
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // 스캔 토글 버튼
            Button {
                bluetoothManager.toggleScanning()
            } label: {
                Image(systemName: bluetoothManager.isScanning ? "stop.fill" : "play.fill")
            }
            .disabled(!bluetoothManager.isAvailable)
            
            // 설정 버튼
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(BluetoothManager.shared)
        .environmentObject(DeviceConnection.shared)
}
