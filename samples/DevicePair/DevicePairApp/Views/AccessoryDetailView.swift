//
//  AccessoryDetailView.swift
//  DevicePair
//
//  액세서리 상세 뷰 - 개별 기기의 상세 정보 및 설정
//

import SwiftUI

// MARK: - 액세서리 상세 뷰

/// 선택된 액세서리의 상세 정보를 표시하고 관리하는 뷰
struct AccessoryDetailView: View {
    
    /// 표시할 액세서리
    let accessory: Accessory
    
    @EnvironmentObject private var sessionManager: AccessorySessionManager
    @Environment(\.dismiss) private var dismiss
    
    /// 편집 모드 여부
    @State private var isEditing = false
    
    /// 편집 중인 이름
    @State private var editedName: String = ""
    
    /// 설정 시트 표시 여부
    @State private var showingSettings = false
    
    /// 페어링 해제 확인 알림 표시 여부
    @State private var showingUnpairAlert = false
    
    var body: some View {
        List {
            // 헤더 섹션
            headerSection
            
            // 연결 상태 섹션
            connectionSection
            
            // 기기 정보 섹션
            deviceInfoSection
            
            // 빠른 작업 섹션
            quickActionsSection
            
            // 위험 영역 (페어링 해제)
            dangerZoneSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("기기 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "완료" : "편집") {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }
            }
        }
        .onAppear {
            editedName = accessory.name
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                AccessorySettingsView(accessory: accessory)
            }
        }
        .alert("페어링 해제", isPresented: $showingUnpairAlert) {
            Button("취소", role: .cancel) { }
            Button("해제", role: .destructive) {
                sessionManager.unpairAccessory(accessory)
                dismiss()
            }
        } message: {
            Text("'\(accessory.name)'의 페어링을 해제하시겠습니까? 다시 사용하려면 재페어링이 필요합니다.")
        }
    }
    
    // MARK: - 헤더 섹션
    
    private var headerSection: some View {
        Section {
            VStack(spacing: 16) {
                // 아이콘
                ZStack {
                    Circle()
                        .fill(accessory.category.color.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: accessory.category.iconName)
                        .font(.system(size: 32))
                        .foregroundStyle(accessory.category.color)
                }
                
                // 이름 (편집 가능)
                VStack(spacing: 8) {
                    if isEditing {
                        TextField("기기 이름", text: $editedName)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 250)
                    } else {
                        Text(accessory.name)
                            .font(.title2.bold())
                    }
                    
                    // 카테고리
                    Text(accessory.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // 연결 상태 배지
                HStack(spacing: 6) {
                    Image(systemName: accessory.connectionState.iconName)
                        .font(.caption)
                    Text(accessory.connectionState.rawValue)
                        .font(.caption.weight(.medium))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(connectionStatusColor.opacity(0.15))
                .foregroundStyle(connectionStatusColor)
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .listRowBackground(Color.clear)
    }
    
    private var connectionStatusColor: Color {
        switch accessory.connectionState {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .gray
        case .failed: return .red
        }
    }
    
    // MARK: - 연결 섹션
    
    private var connectionSection: some View {
        Section("연결") {
            // 연결 상태
            HStack {
                Label("상태", systemImage: "wifi")
                Spacer()
                
                if accessory.connectionState == .connecting {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text(accessory.connectionState.rawValue)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 마지막 연결 시간
            if let lastConnected = accessory.lastConnected {
                HStack {
                    Label("마지막 연결", systemImage: "clock")
                    Spacer()
                    Text(lastConnected, style: .relative)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 배터리 (있는 경우)
            if let batteryLevel = accessory.batteryLevel {
                HStack {
                    Label("배터리", systemImage: batteryIcon(for: batteryLevel))
                    Spacer()
                    HStack(spacing: 8) {
                        // 배터리 바
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(batteryColor(for: batteryLevel))
                                    .frame(width: geo.size.width * CGFloat(batteryLevel) / 100)
                            }
                        }
                        .frame(width: 60, height: 16)
                        
                        Text("\(batteryLevel)%")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - 기기 정보 섹션
    
    private var deviceInfoSection: some View {
        Section("기기 정보") {
            // 제조사
            HStack {
                Label("제조사", systemImage: "building.2")
                Spacer()
                Text(accessory.manufacturer)
                    .foregroundStyle(.secondary)
            }
            
            // 모델
            HStack {
                Label("모델", systemImage: "tag")
                Spacer()
                Text(accessory.modelNumber)
                    .foregroundStyle(.secondary)
            }
            
            // 일련번호 (있는 경우)
            if let serialNumber = accessory.serialNumber {
                HStack {
                    Label("일련번호", systemImage: "number")
                    Spacer()
                    Text(serialNumber)
                        .foregroundStyle(.secondary)
                        .font(.system(.body, design: .monospaced))
                }
            }
            
            // 펌웨어 버전 (있는 경우)
            if let firmware = accessory.firmwareVersion {
                HStack {
                    Label("펌웨어", systemImage: "cpu")
                    Spacer()
                    Text(firmware)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 위치 (있는 경우)
            if let room = accessory.settings.roomName {
                HStack {
                    Label("위치", systemImage: "location")
                    Spacer()
                    Text(room)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - 빠른 작업 섹션
    
    private var quickActionsSection: some View {
        Section("빠른 작업") {
            // 연결/연결 해제
            if accessory.connectionState == .connected {
                Button {
                    sessionManager.disconnectAccessory(accessory)
                } label: {
                    Label("연결 해제", systemImage: "wifi.slash")
                        .foregroundStyle(.orange)
                }
            } else if accessory.connectionState == .disconnected {
                Button {
                    sessionManager.reconnectAccessory(accessory)
                } label: {
                    Label("다시 연결", systemImage: "wifi")
                        .foregroundStyle(.blue)
                }
            }
            
            // 설정
            Button {
                showingSettings = true
            } label: {
                Label("기기 설정", systemImage: "gearshape")
            }
            
            // 알림 토글
            Toggle(isOn: Binding(
                get: { accessory.settings.notificationsEnabled },
                set: { newValue in
                    var settings = accessory.settings
                    settings.notificationsEnabled = newValue
                    sessionManager.updateAccessorySettings(accessory, settings: settings)
                }
            )) {
                Label("알림", systemImage: "bell")
            }
        }
    }
    
    // MARK: - 위험 영역 섹션
    
    private var dangerZoneSection: some View {
        Section {
            Button(role: .destructive) {
                showingUnpairAlert = true
            } label: {
                Label("페어링 해제", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
        } footer: {
            Text("페어링을 해제하면 이 기기와의 연결이 완전히 제거됩니다.")
        }
    }
    
    // MARK: - 유틸리티
    
    private func saveChanges() {
        if editedName != accessory.name && !editedName.isEmpty {
            sessionManager.renameAccessory(accessory, to: editedName)
        }
    }
    
    private func batteryIcon(for level: Int) -> String {
        switch level {
        case 0..<20: return "battery.0percent"
        case 20..<50: return "battery.25percent"
        case 50..<75: return "battery.50percent"
        case 75..<100: return "battery.75percent"
        default: return "battery.100percent"
        }
    }
    
    private func batteryColor(for level: Int) -> Color {
        switch level {
        case 0..<20: return .red
        case 20..<50: return .orange
        default: return .green
        }
    }
}

// MARK: - 미리보기

#Preview {
    NavigationStack {
        AccessoryDetailView(accessory: Accessory.sampleAccessories[0])
            .environmentObject(AccessorySessionManager())
    }
}
