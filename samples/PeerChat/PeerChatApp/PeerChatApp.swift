// PeerChatApp.swift
// PeerChat - MultipeerConnectivity 기반 P2P 채팅
// 앱 진입점

import SwiftUI

@main
struct PeerChatApp: App {
    /// 멀티피어 서비스 (앱 전체에서 공유)
    @StateObject private var multipeerService = MultipeerService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(multipeerService)
        }
    }
}

/// 메인 콘텐츠 뷰
struct ContentView: View {
    @EnvironmentObject var multipeerService: MultipeerService
    @State private var selectedTab = 0
    @State private var showingSettings = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 채팅 탭
            NavigationStack {
                ChatListView()
            }
            .tabItem {
                Label("채팅", systemImage: "bubble.left.and.bubble.right")
            }
            .tag(0)
            .badge(multipeerService.totalUnreadCount)
            
            // 피어 발견 탭
            NavigationStack {
                PeerDiscoveryView()
            }
            .tabItem {
                Label("주변 기기", systemImage: "antenna.radiowaves.left.and.right")
            }
            .tag(1)
            .badge(multipeerService.pendingInvitations.count)
            
            // 그룹 세션 탭
            NavigationStack {
                GroupSessionView()
            }
            .tabItem {
                Label("그룹", systemImage: "person.3")
            }
            .tag(2)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    /// 초기 상태 설정
    private func setupInitialState() {
        // 저장된 사용자 이름 로드
        if let savedName = UserDefaults.standard.string(forKey: "userName") {
            multipeerService.localDisplayName = savedName
        }
        
        // 서비스 시작
        multipeerService.startServices()
    }
}

/// 채팅 목록 뷰
struct ChatListView: View {
    @EnvironmentObject var multipeerService: MultipeerService
    
    var body: some View {
        Group {
            if multipeerService.connectedPeers.isEmpty {
                // 연결된 피어가 없을 때
                ContentUnavailableView(
                    "연결된 기기 없음",
                    systemImage: "bubble.left.and.bubble.right.fill",
                    description: Text("주변 기기 탭에서 기기를 찾아 연결하세요")
                )
            } else {
                // 연결된 피어 목록
                List {
                    ForEach(multipeerService.connectedPeers) { peer in
                        NavigationLink(destination: ChatView(peer: peer)) {
                            PeerRowView(peer: peer)
                        }
                    }
                }
            }
        }
        .navigationTitle("채팅")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ConnectionStatusView()
            }
        }
    }
}

/// 피어 행 뷰
struct PeerRowView: View {
    let peer: DiscoveredPeer
    @EnvironmentObject var multipeerService: MultipeerService
    
    var body: some View {
        HStack(spacing: 12) {
            // 기기 아이콘
            Image(systemName: peer.deviceIcon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                // 피어 이름
                Text(peer.displayName)
                    .font(.headline)
                
                // 마지막 메시지 또는 상태
                if let lastMessage = multipeerService.lastMessage(for: peer.id) {
                    Text(lastMessage.content)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(peer.state.displayText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 읽지 않은 메시지 배지
            if let unread = multipeerService.unreadCount(for: peer.id), unread > 0 {
                Text("\(unread)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

/// 연결 상태 표시 뷰
struct ConnectionStatusView: View {
    @EnvironmentObject var multipeerService: MultipeerService
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text("\(multipeerService.connectedPeers.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var statusColor: Color {
        if multipeerService.connectedPeers.isEmpty {
            return .gray
        } else {
            return .green
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MultipeerService())
}
