// SettingsView.swift
// PeerChat - MultipeerConnectivity 기반 P2P 채팅
// 설정 화면

import SwiftUI

/// 설정 뷰
struct SettingsView: View {
    @EnvironmentObject var multipeerService: MultipeerService
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName: String = ""
    @State private var autoAcceptInvitations = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                // 프로필 섹션
                profileSection
                
                // 연결 설정 섹션
                connectionSection
                
                // 서비스 정보 섹션
                serviceInfoSection
                
                // 데이터 관리 섹션
                dataManagementSection
                
                // 앱 정보 섹션
                appInfoSection
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSettings()
            }
            .alert("데이터 초기화", isPresented: $showingResetAlert) {
                Button("취소", role: .cancel) {}
                Button("초기화", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("모든 채팅 기록과 설정이 삭제됩니다. 이 작업은 되돌릴 수 없습니다.")
            }
        }
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        Section {
            HStack {
                // 프로필 아이콘
                Image(systemName: deviceIcon)
                    .font(.system(size: 40))
                    .foregroundStyle(.tint)
                    .frame(width: 60, height: 60)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    TextField("표시 이름", text: $displayName)
                        .font(.headline)
                    
                    Text(PeerChatService.currentDeviceType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 8)
            }
            .padding(.vertical, 4)
        } header: {
            Text("프로필")
        } footer: {
            Text("다른 기기에서 이 기기를 식별할 때 사용되는 이름입니다.")
        }
    }
    
    private var deviceIcon: String {
        switch PeerChatService.currentDeviceType {
        case "iPhone":
            return "iphone"
        case "iPad":
            return "ipad"
        case "Mac":
            return "laptopcomputer"
        default:
            return "desktopcomputer"
        }
    }
    
    // MARK: - Connection Section
    
    private var connectionSection: some View {
        Section {
            Toggle("자동으로 광고 시작", isOn: .constant(true))
            
            Toggle("자동으로 탐색 시작", isOn: .constant(true))
            
            Toggle("초대 자동 수락", isOn: $autoAcceptInvitations)
        } header: {
            Text("연결 설정")
        } footer: {
            Text("초대 자동 수락을 켜면 다른 기기의 연결 요청이 자동으로 수락됩니다.")
        }
    }
    
    // MARK: - Service Info Section
    
    private var serviceInfoSection: some View {
        Section {
            InfoRow(title: "서비스 타입", value: PeerChatService.serviceType)
            
            InfoRow(
                title: "광고 상태",
                value: multipeerService.isAdvertising ? "활성" : "비활성",
                valueColor: multipeerService.isAdvertising ? .green : .secondary
            )
            
            InfoRow(
                title: "탐색 상태",
                value: multipeerService.isBrowsing ? "활성" : "비활성",
                valueColor: multipeerService.isBrowsing ? .green : .secondary
            )
            
            InfoRow(
                title: "연결된 기기",
                value: "\(multipeerService.connectedPeers.count)개"
            )
        } header: {
            Text("서비스 정보")
        }
    }
    
    // MARK: - Data Management Section
    
    private var dataManagementSection: some View {
        Section {
            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("모든 데이터 초기화")
                }
            }
        } header: {
            Text("데이터 관리")
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        Section {
            InfoRow(title: "앱 버전", value: PeerChatService.appVersion)
            
            InfoRow(title: "빌드", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-")
            
            Link(destination: URL(string: "https://developer.apple.com/documentation/multipeerconnectivity")!) {
                HStack {
                    Text("MultipeerConnectivity 문서")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("앱 정보")
        } footer: {
            Text("PeerChat은 Apple의 MultipeerConnectivity 프레임워크를 사용하여 근거리 P2P 통신을 구현합니다.")
        }
    }
    
    // MARK: - Actions
    
    private func loadSettings() {
        displayName = multipeerService.localDisplayName
        autoAcceptInvitations = UserDefaults.standard.bool(forKey: "autoAcceptInvitations")
    }
    
    private func saveSettings() {
        // 이름 변경 시 서비스 재시작
        if displayName != multipeerService.localDisplayName {
            multipeerService.localDisplayName = displayName
        }
        
        UserDefaults.standard.set(autoAcceptInvitations, forKey: "autoAcceptInvitations")
    }
    
    private func resetAllData() {
        // 모든 설정 초기화
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "autoAcceptInvitations")
        
        // 서비스 재시작
        multipeerService.restartServices()
    }
}

/// 정보 행 뷰
struct InfoRow: View {
    let title: String
    let value: String
    var valueColor: Color = .secondary
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(valueColor)
        }
    }
}

/// 연결 상태 뷰 (상세)
struct ConnectionStatusDetailView: View {
    @EnvironmentObject var multipeerService: MultipeerService
    
    var body: some View {
        List {
            Section("현재 상태") {
                StatusRow(
                    icon: "antenna.radiowaves.left.and.right",
                    title: "광고",
                    isActive: multipeerService.isAdvertising
                )
                
                StatusRow(
                    icon: "magnifyingglass",
                    title: "탐색",
                    isActive: multipeerService.isBrowsing
                )
            }
            
            Section("통계") {
                HStack {
                    Text("발견된 기기")
                    Spacer()
                    Text("\(multipeerService.discoveredPeers.count)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("연결된 기기")
                    Spacer()
                    Text("\(multipeerService.connectedPeers.count)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("대기 중인 초대")
                    Spacer()
                    Text("\(multipeerService.pendingInvitations.count)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("그룹 세션")
                    Spacer()
                    Text("\(multipeerService.groupSessions.count)")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("연결 상태")
    }
}

/// 상태 행 뷰
struct StatusRow: View {
    let icon: String
    let title: String
    let isActive: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(isActive ? .green : .secondary)
            
            Text(title)
            
            Spacer()
            
            if isActive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text("활성")
                        .foregroundStyle(.green)
                }
                .font(.caption)
            } else {
                Text("비활성")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MultipeerService())
}
