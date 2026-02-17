// PeerListView.swift
// DirectShare - Wi-Fi Aware 직접 파일 공유
// 발견된 피어 목록 표시 및 연결 관리

import SwiftUI

/// 발견된 피어 목록 뷰
struct PeerListView: View {
    @Environment(WiFiAwareManager.self) private var wifiManager
    @Environment(FileTransferService.self) private var transferService
    
    /// 피어 선택 콜백
    var onPeerSelected: ((Peer) -> Void)?
    
    /// 파일 전송 콜백
    var onSendFile: ((Peer) -> Void)?
    
    /// 선택된 피어 (상세 정보용)
    @State private var selectedPeer: Peer?
    
    /// 연결 확인 알림 표시
    @State private var showConnectAlert = false
    
    /// 수신 파일 알림 표시
    @State private var showIncomingFileAlert = false
    
    /// 수신 대기 중인 파일
    @State private var incomingFile: TransferFile?
    
    /// 파일 전송자 피어
    @State private var incomingFilePeer: Peer?
    
    var body: some View {
        Group {
            if wifiManager.discoveredPeers.isEmpty {
                emptyStateView
            } else {
                peerListView
            }
        }
        .alert("연결", isPresented: $showConnectAlert) {
            Button("취소", role: .cancel) {}
            Button("연결") {
                if let peer = selectedPeer {
                    wifiManager.connect(to: peer)
                }
            }
        } message: {
            if let peer = selectedPeer {
                Text("\(peer.deviceName)에 연결하시겠습니까?")
            }
        }
        .alert("파일 수신", isPresented: $showIncomingFileAlert) {
            Button("거부", role: .cancel) {
                rejectIncomingFile()
            }
            Button("수락") {
                acceptIncomingFile()
            }
        } message: {
            if let file = incomingFile, let peer = incomingFilePeer {
                Text("\(peer.deviceName)이(가) \(file.fileName) (\(file.formattedSize))을(를) 보내려고 합니다.")
            }
        }
        .onAppear {
            setupFileOfferHandler()
        }
    }
    
    // MARK: - 서브뷰
    
    /// 피어가 없을 때 표시
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("주변 기기 없음", systemImage: "wifi.exclamationmark")
        } description: {
            VStack(spacing: 8) {
                Text("Wi-Fi Aware를 사용하는 기기를 찾고 있습니다")
                
                if !wifiManager.isScanning {
                    Text("스캔이 중지되어 있습니다")
                        .foregroundStyle(.orange)
                }
            }
        } actions: {
            if !wifiManager.isScanning {
                Button("스캔 시작") {
                    wifiManager.startScanning()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    /// 피어 목록
    private var peerListView: some View {
        List {
            // 연결된 피어
            let connectedPeers = wifiManager.discoveredPeers.filter { $0.connectionState.isConnected }
            if !connectedPeers.isEmpty {
                Section("연결됨") {
                    ForEach(connectedPeers) { peer in
                        PeerRow(peer: peer, isConnected: true)
                            .contextMenu {
                                peerContextMenu(for: peer)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("연결 해제", role: .destructive) {
                                    wifiManager.disconnect(from: peer)
                                }
                            }
                    }
                }
            }
            
            // 발견된 피어
            let availablePeers = wifiManager.discoveredPeers.filter { !$0.connectionState.isConnected }
            if !availablePeers.isEmpty {
                Section("주변 기기 (\(availablePeers.count))") {
                    ForEach(availablePeers) { peer in
                        PeerRow(peer: peer, isConnected: false)
                            .onTapGesture {
                                selectedPeer = peer
                                showConnectAlert = true
                            }
                            .contextMenu {
                                peerContextMenu(for: peer)
                            }
                    }
                }
            }
        }
        .refreshable {
            // 새로고침 시 피어 목록 갱신
            wifiManager.cleanupExpiredPeers()
            
            // 잠시 대기 (검색 시간)
            try? await Task.sleep(for: .seconds(1))
        }
    }
    
    /// 피어 컨텍스트 메뉴
    @ViewBuilder
    private func peerContextMenu(for peer: Peer) -> some View {
        if peer.connectionState.isConnected {
            Button {
                onSendFile?(peer)
            } label: {
                Label("파일 보내기", systemImage: "paperplane")
            }
            
            Divider()
            
            Button(role: .destructive) {
                wifiManager.disconnect(from: peer)
            } label: {
                Label("연결 해제", systemImage: "wifi.slash")
            }
        } else if peer.connectionState.canConnect {
            Button {
                wifiManager.connect(to: peer)
            } label: {
                Label("연결", systemImage: "wifi")
            }
        }
        
        Divider()
        
        Button {
            selectedPeer = peer
            onPeerSelected?(peer)
        } label: {
            Label("상세 정보", systemImage: "info.circle")
        }
    }
    
    // MARK: - 파일 수신 처리
    
    /// 파일 제안 핸들러 설정
    private func setupFileOfferHandler() {
        transferService.onFileOfferReceived = { file, peer in
            incomingFile = file
            incomingFilePeer = peer
            showIncomingFileAlert = true
        }
    }
    
    /// 파일 수신 수락
    private func acceptIncomingFile() {
        guard let file = incomingFile, let peer = incomingFilePeer else { return }
        
        Task {
            try? await transferService.acceptFileOffer(file, from: peer)
        }
        
        incomingFile = nil
        incomingFilePeer = nil
    }
    
    /// 파일 수신 거부
    private func rejectIncomingFile() {
        guard let file = incomingFile, let peer = incomingFilePeer else { return }
        
        Task {
            try? await transferService.rejectFileOffer(file, from: peer)
        }
        
        incomingFile = nil
        incomingFilePeer = nil
    }
}

// MARK: - 피어 행

/// 개별 피어 표시 행
struct PeerRow: View {
    let peer: Peer
    let isConnected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 기기 아이콘
            ZStack {
                Circle()
                    .fill(isConnected ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: deviceIcon)
                    .font(.title3)
                    .foregroundStyle(isConnected ? .green : .secondary)
            }
            
            // 기기 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(peer.deviceName)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    if isConnected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                
                HStack(spacing: 6) {
                    if let model = peer.deviceModel {
                        Text(model)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.quaternary)
                    
                    Text(peer.lastSeenRelative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 신호 강도 및 상태
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: peer.connectionState.icon)
                    .font(.body)
                    .foregroundStyle(stateColor)
                
                if peer.signalLevel > 0 {
                    HStack(spacing: 1) {
                        ForEach(0..<4) { index in
                            Rectangle()
                                .fill(index < peer.signalLevel ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 3, height: CGFloat(4 + index * 2))
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    /// 기기 아이콘
    private var deviceIcon: String {
        guard let model = peer.deviceModel?.lowercased() else {
            return "iphone"
        }
        
        if model.contains("ipad") {
            return "ipad"
        } else if model.contains("mac") {
            return "macbook"
        } else {
            return "iphone"
        }
    }
    
    /// 상태 색상
    private var stateColor: Color {
        switch peer.connectionState {
        case .discovered:
            return .secondary
        case .connecting:
            return .orange
        case .connected:
            return .green
        case .disconnected:
            return .gray
        case .failed:
            return .red
        }
    }
}

// MARK: - 피어 상세 뷰

/// 피어 상세 정보 시트
struct PeerDetailView: View {
    let peer: Peer
    @Environment(\.dismiss) private var dismiss
    @Environment(WiFiAwareManager.self) private var wifiManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("기기 정보") {
                    LabeledContent("이름", value: peer.deviceName)
                    
                    if let model = peer.deviceModel {
                        LabeledContent("모델", value: model)
                    }
                    
                    if let os = peer.osVersion {
                        LabeledContent("OS 버전", value: os)
                    }
                    
                    if let app = peer.appVersion {
                        LabeledContent("앱 버전", value: app)
                    }
                }
                
                Section("연결 상태") {
                    LabeledContent("상태", value: peer.connectionState.rawValue)
                    LabeledContent("발견 시간", value: peer.discoveredAt, format: .dateTime)
                    LabeledContent("마지막 확인", value: peer.lastSeenRelative)
                    
                    if let signal = peer.signalStrength {
                        LabeledContent("신호 강도", value: "\(signal) dBm")
                    }
                }
                
                Section {
                    if peer.connectionState.isConnected {
                        Button(role: .destructive) {
                            wifiManager.disconnect(from: peer)
                            dismiss()
                        } label: {
                            Label("연결 해제", systemImage: "wifi.slash")
                        }
                    } else if peer.connectionState.canConnect {
                        Button {
                            wifiManager.connect(to: peer)
                            dismiss()
                        } label: {
                            Label("연결", systemImage: "wifi")
                        }
                    }
                }
            }
            .navigationTitle("기기 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PeerListView()
        .environment(WiFiAwareManager())
        .environment(FileTransferService())
}
