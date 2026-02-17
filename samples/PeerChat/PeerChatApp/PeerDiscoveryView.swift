// PeerDiscoveryView.swift
// PeerChat - MultipeerConnectivity 기반 P2P 채팅
// 주변 기기 발견 및 연결 화면

import SwiftUI
import MultipeerConnectivity

/// 피어 발견 뷰
struct PeerDiscoveryView: View {
    @EnvironmentObject var multipeerService: MultipeerService
    @State private var showingInvitations = false
    
    var body: some View {
        List {
            // 서비스 상태 섹션
            serviceStatusSection
            
            // 발견된 피어 섹션
            discoveredPeersSection
            
            // 연결된 피어 섹션
            connectedPeersSection
        }
        .navigationTitle("주변 기기")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                invitationButton
            }
        }
        .sheet(isPresented: $showingInvitations) {
            InvitationListView()
        }
        .refreshable {
            // 새로고침 시 서비스 재시작
            multipeerService.restartServices()
        }
    }
    
    // MARK: - Service Status Section
    
    private var serviceStatusSection: some View {
        Section {
            // 광고 상태
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundStyle(multipeerService.isAdvertising ? .green : .secondary)
                
                Text("기기 광고")
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { multipeerService.isAdvertising },
                    set: { newValue in
                        if newValue {
                            multipeerService.startAdvertising()
                        } else {
                            multipeerService.stopAdvertising()
                        }
                    }
                ))
            }
            
            // 탐색 상태
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(multipeerService.isBrowsing ? .green : .secondary)
                
                Text("주변 기기 탐색")
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { multipeerService.isBrowsing },
                    set: { newValue in
                        if newValue {
                            multipeerService.startBrowsing()
                        } else {
                            multipeerService.stopBrowsing()
                        }
                    }
                ))
            }
        } header: {
            Text("서비스 상태")
        } footer: {
            Text("광고를 켜면 다른 기기에서 이 기기를 발견할 수 있습니다. 탐색을 켜면 주변 기기를 찾습니다.")
        }
    }
    
    // MARK: - Discovered Peers Section
    
    private var discoveredPeersSection: some View {
        Section {
            if multipeerService.discoveredPeers.isEmpty {
                ContentUnavailableView(
                    "주변에 기기 없음",
                    systemImage: "antenna.radiowaves.left.and.right.slash",
                    description: Text("PeerChat이 설치된 다른 기기가 주변에 없습니다")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(multipeerService.discoveredPeers) { peer in
                    DiscoveredPeerRow(peer: peer) {
                        multipeerService.invitePeer(peer)
                    }
                }
            }
        } header: {
            HStack {
                Text("발견된 기기")
                
                Spacer()
                
                if multipeerService.isBrowsing {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
        }
    }
    
    // MARK: - Connected Peers Section
    
    private var connectedPeersSection: some View {
        Section {
            if multipeerService.connectedPeers.isEmpty {
                Text("연결된 기기 없음")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(multipeerService.connectedPeers) { peer in
                    ConnectedPeerRow(peer: peer)
                }
            }
        } header: {
            Text("연결된 기기 (\(multipeerService.connectedPeers.count))")
        }
    }
    
    // MARK: - Invitation Button
    
    private var invitationButton: some View {
        Button {
            showingInvitations = true
        } label: {
            Image(systemName: "bell.badge")
                .symbolRenderingMode(.multicolor)
        }
        .badge(multipeerService.pendingInvitations.count)
        .disabled(multipeerService.pendingInvitations.isEmpty)
    }
}

/// 발견된 피어 행
struct DiscoveredPeerRow: View {
    let peer: DiscoveredPeer
    let onInvite: () -> Void
    
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
                Text(peer.displayName)
                    .font(.headline)
                
                HStack(spacing: 4) {
                    // 상태 표시
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(peer.state.displayText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 초대 버튼
            if peer.state == .notConnected {
                Button("연결") {
                    onInvite()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            } else if peer.state == .connecting {
                ProgressView()
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch peer.state {
        case .notConnected:
            return .gray
        case .connecting:
            return .orange
        case .connected:
            return .green
        }
    }
}

/// 연결된 피어 행
struct ConnectedPeerRow: View {
    let peer: DiscoveredPeer
    @EnvironmentObject var multipeerService: MultipeerService
    
    var body: some View {
        HStack(spacing: 12) {
            // 기기 아이콘
            Image(systemName: peer.deviceIcon)
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 44, height: 44)
                .background(Color.green.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(peer.displayName)
                    .font(.headline)
                
                Text("연결됨")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            
            Spacer()
            
            // 채팅 버튼
            NavigationLink(destination: ChatView(peer: peer)) {
                Image(systemName: "bubble.left.fill")
                    .foregroundStyle(.tint)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                multipeerService.disconnectPeer(peer)
            } label: {
                Label("연결 해제", systemImage: "xmark.circle")
            }
        }
    }
}

/// 초대 목록 뷰
struct InvitationListView: View {
    @EnvironmentObject var multipeerService: MultipeerService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if multipeerService.pendingInvitations.isEmpty {
                    ContentUnavailableView(
                        "대기 중인 초대 없음",
                        systemImage: "bell.slash",
                        description: Text("다른 기기에서 초대가 오면 여기에 표시됩니다")
                    )
                } else {
                    ForEach(multipeerService.pendingInvitations) { invitation in
                        InvitationRow(invitation: invitation)
                    }
                }
            }
            .navigationTitle("연결 요청")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// 초대 행
struct InvitationRow: View {
    let invitation: PeerInvitation
    @EnvironmentObject var multipeerService: MultipeerService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(invitation.peerID.displayName)
                        .font(.headline)
                    
                    Text("연결을 요청합니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 12) {
                Button {
                    multipeerService.declineInvitation(invitation)
                } label: {
                    Text("거절")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button {
                    multipeerService.acceptInvitation(invitation)
                } label: {
                    Text("수락")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        PeerDiscoveryView()
            .environmentObject(MultipeerService())
    }
}
