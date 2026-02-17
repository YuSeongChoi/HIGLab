//
//  AccessorySettingsView.swift
//  DevicePair
//
//  액세서리 설정 뷰 - 개별 기기의 상세 설정 관리
//

import SwiftUI

// MARK: - 액세서리 설정 뷰

/// 개별 액세서리의 상세 설정을 관리하는 뷰
struct AccessorySettingsView: View {
    
    /// 설정할 액세서리
    let accessory: Accessory
    
    @EnvironmentObject private var sessionManager: AccessorySessionManager
    @Environment(\.dismiss) private var dismiss
    
    /// 편집 중인 설정값들
    @State private var notificationsEnabled: Bool
    @State private var autoConnectEnabled: Bool
    @State private var lowPowerModeEnabled: Bool
    @State private var selectedRoom: String
    @State private var customRoomName: String = ""
    @State private var selectedColor: Color
    @State private var selectedIcon: String
    @State private var priority: Int
    
    /// 사용자 정의 방 이름 입력 표시
    @State private var showingCustomRoomInput = false
    
    /// 미리 정의된 방 이름들
    private let predefinedRooms = ["거실", "침실", "주방", "서재", "욕실", "현관", "베란다", "기타"]
    
    /// 선택 가능한 아이콘들
    private let availableIcons = [
        "hifispeaker.fill", "headphones", "lightbulb.fill", "sensor.fill",
        "camera.fill", "lock.fill", "thermometer.medium", "poweroutlet.type.b.fill",
        "tv.fill", "airplayaudio", "homepodmini.fill", "applewatch"
    ]
    
    // MARK: - 초기화
    
    init(accessory: Accessory) {
        self.accessory = accessory
        
        // 초기값 설정
        _notificationsEnabled = State(initialValue: accessory.settings.notificationsEnabled)
        _autoConnectEnabled = State(initialValue: accessory.settings.autoConnectEnabled)
        _lowPowerModeEnabled = State(initialValue: accessory.settings.lowPowerModeEnabled)
        _selectedRoom = State(initialValue: accessory.settings.roomName ?? "")
        _priority = State(initialValue: accessory.settings.priority)
        
        // 색상 파싱
        if let colorHex = accessory.settings.customColor {
            _selectedColor = State(initialValue: Color(hex: colorHex) ?? .blue)
        } else {
            _selectedColor = State(initialValue: accessory.category.color)
        }
        
        // 아이콘
        _selectedIcon = State(initialValue: accessory.settings.customIcon ?? accessory.category.iconName)
    }
    
    var body: some View {
        List {
            // 알림 설정
            notificationSection
            
            // 연결 설정
            connectionSettingsSection
            
            // 위치 설정
            locationSection
            
            // 외관 설정
            appearanceSection
            
            // 우선순위 설정
            prioritySection
            
            // 고급 설정
            advancedSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("취소") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("저장") {
                    saveSettings()
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .alert("방 이름 입력", isPresented: $showingCustomRoomInput) {
            TextField("방 이름", text: $customRoomName)
            Button("취소", role: .cancel) { }
            Button("확인") {
                if !customRoomName.isEmpty {
                    selectedRoom = customRoomName
                }
            }
        } message: {
            Text("사용자 정의 방 이름을 입력하세요")
        }
    }
    
    // MARK: - 알림 설정 섹션
    
    private var notificationSection: some View {
        Section {
            Toggle(isOn: $notificationsEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("알림 허용")
                        Text("이 기기의 알림을 받습니다")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.blue)
                }
            }
        } header: {
            Text("알림")
        }
    }
    
    // MARK: - 연결 설정 섹션
    
    private var connectionSettingsSection: some View {
        Section {
            Toggle(isOn: $autoConnectEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("자동 연결")
                        Text("범위 내에 들어오면 자동으로 연결합니다")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "wifi")
                        .foregroundStyle(.green)
                }
            }
            
            Toggle(isOn: $lowPowerModeEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("저전력 모드")
                        Text("배터리 수명을 연장하지만 응답이 느려질 수 있습니다")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "battery.75percent")
                        .foregroundStyle(.orange)
                }
            }
        } header: {
            Text("연결")
        }
    }
    
    // MARK: - 위치 설정 섹션
    
    private var locationSection: some View {
        Section {
            // 미리 정의된 방 선택
            ForEach(predefinedRooms, id: \.self) { room in
                Button {
                    selectedRoom = room
                } label: {
                    HStack {
                        Text(room)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selectedRoom == room {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            
            // 사용자 정의 방 이름
            Button {
                showingCustomRoomInput = true
            } label: {
                HStack {
                    Label("직접 입력...", systemImage: "plus.circle")
                    Spacer()
                    if !predefinedRooms.contains(selectedRoom) && !selectedRoom.isEmpty {
                        Text(selectedRoom)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("위치")
        } footer: {
            Text("기기가 위치한 방을 선택하면 찾기가 쉬워집니다")
        }
    }
    
    // MARK: - 외관 설정 섹션
    
    private var appearanceSection: some View {
        Section {
            // 색상 선택
            HStack {
                Label("테마 색상", systemImage: "paintpalette.fill")
                Spacer()
                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
            }
            
            // 아이콘 선택
            VStack(alignment: .leading, spacing: 12) {
                Label("아이콘", systemImage: "square.grid.2x2")
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color(.systemGray6))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedIcon == icon ? selectedColor : .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("외관")
        }
    }
    
    // MARK: - 우선순위 설정 섹션
    
    private var prioritySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("우선순위", systemImage: "arrow.up.arrow.down")
                    Spacer()
                    Text(priorityText)
                        .foregroundStyle(.secondary)
                }
                
                Picker("우선순위", selection: $priority) {
                    Text("높음").tag(0)
                    Text("보통").tag(1)
                    Text("낮음").tag(2)
                }
                .pickerStyle(.segmented)
            }
            .padding(.vertical, 4)
        } header: {
            Text("정렬")
        } footer: {
            Text("높은 우선순위의 기기가 목록에서 먼저 표시됩니다")
        }
    }
    
    private var priorityText: String {
        switch priority {
        case 0: return "높음"
        case 1: return "보통"
        default: return "낮음"
        }
    }
    
    // MARK: - 고급 설정 섹션
    
    private var advancedSection: some View {
        Section {
            // 펌웨어 업데이트 확인
            Button {
                // 펌웨어 업데이트 확인 로직
            } label: {
                HStack {
                    Label("펌웨어 업데이트 확인", systemImage: "arrow.down.circle")
                    Spacer()
                    if let version = accessory.firmwareVersion {
                        Text("현재: \(version)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // 기기 초기화
            Button(role: .destructive) {
                // 기기 초기화 로직
            } label: {
                Label("기기 설정 초기화", systemImage: "arrow.counterclockwise")
            }
        } header: {
            Text("고급")
        }
    }
    
    // MARK: - 설정 저장
    
    private func saveSettings() {
        var settings = AccessorySettings()
        settings.notificationsEnabled = notificationsEnabled
        settings.autoConnectEnabled = autoConnectEnabled
        settings.lowPowerModeEnabled = lowPowerModeEnabled
        settings.roomName = selectedRoom.isEmpty ? nil : selectedRoom
        settings.customColor = selectedColor.toHex()
        settings.customIcon = selectedIcon
        settings.priority = priority
        
        sessionManager.updateAccessorySettings(accessory, settings: settings)
    }
}

// MARK: - Color 확장

extension Color {
    /// Hex 문자열로부터 Color 생성
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
    
    /// Color를 Hex 문자열로 변환
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else {
            return nil
        }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - 미리보기

#Preview {
    NavigationStack {
        AccessorySettingsView(accessory: Accessory.sampleAccessories[0])
            .environmentObject(AccessorySessionManager())
    }
}
