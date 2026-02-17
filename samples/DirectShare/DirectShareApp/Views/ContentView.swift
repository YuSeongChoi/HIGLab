// ContentView.swift
// DirectShare - Wi-Fi Aware 직접 파일 공유
// 메인 콘텐츠 뷰

import SwiftUI
import UniformTypeIdentifiers

/// 메인 콘텐츠 뷰
struct ContentView: View {
    @Environment(WiFiAwareManager.self) private var wifiManager
    @Environment(FileTransferService.self) private var transferService
    
    /// 현재 선택된 탭
    @State private var selectedTab: Tab = .peers
    
    /// 파일 선택기 표시 여부
    @State private var isShowingFilePicker = false
    
    /// 선택된 피어 (파일 전송 대상)
    @State private var selectedPeer: Peer?
    
    /// 설정 시트 표시 여부
    @State private var isShowingSettings = false
    
    /// 탭 정의
    enum Tab: String, CaseIterable {
        case peers = "주변 기기"
        case transfers = "전송"
        case history = "기록"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 연결 상태 배너
                connectionStatusBanner
                
                // 탭 컨텐츠
                TabView(selection: $selectedTab) {
                    // 피어 목록 탭
                    PeerListView(
                        onPeerSelected: { peer in
                            selectedPeer = peer
                        },
                        onSendFile: { peer in
                            selectedPeer = peer
                            isShowingFilePicker = true
                        }
                    )
                    .tag(Tab.peers)
                    .tabItem {
                        Label("주변 기기", systemImage: "wifi")
                    }
                    
                    // 전송 현황 탭
                    TransferProgressView()
                        .tag(Tab.transfers)
                        .tabItem {
                            Label("전송", systemImage: "arrow.up.arrow.down")
                        }
                    
                    // 전송 기록 탭
                    TransferHistoryView()
                        .tag(Tab.history)
                        .tabItem {
                            Label("기록", systemImage: "clock")
                        }
                }
            }
            .navigationTitle("DirectShare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    networkToggleButton
                }
            }
            .sheet(isPresented: $isShowingFilePicker) {
                DocumentPicker(onFileSelected: handleFileSelected)
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .onAppear {
                // 앱 시작 시 자동으로 스캔 및 광고 시작
                startNetworking()
            }
        }
    }
    
    // MARK: - 서브뷰
    
    /// 연결 상태 배너
    private var connectionStatusBanner: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(wifiManager.connectionState.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            if wifiManager.isScanning {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    /// 상태 표시 색상
    private var statusColor: Color {
        switch wifiManager.connectionState {
        case .idle:
            return .gray
        case .scanning, .advertising, .scanningAndAdvertising:
            return .blue
        case .connecting:
            return .orange
        case .connected, .transferring:
            return .green
        case .error:
            return .red
        }
    }
    
    /// 네트워크 토글 버튼
    private var networkToggleButton: some View {
        Menu {
            Button {
                if wifiManager.isScanning {
                    wifiManager.stopScanning()
                } else {
                    wifiManager.startScanning()
                }
            } label: {
                Label(
                    wifiManager.isScanning ? "스캔 중지" : "스캔 시작",
                    systemImage: wifiManager.isScanning ? "stop.circle" : "magnifyingglass"
                )
            }
            
            Button {
                if wifiManager.isAdvertising {
                    wifiManager.stopAdvertising()
                } else {
                    try? wifiManager.startAdvertising()
                }
            } label: {
                Label(
                    wifiManager.isAdvertising ? "광고 중지" : "광고 시작",
                    systemImage: wifiManager.isAdvertising ? "speaker.slash" : "antenna.radiowaves.left.and.right"
                )
            }
            
            Divider()
            
            Button(role: .destructive) {
                wifiManager.stopAll()
            } label: {
                Label("모두 중지", systemImage: "xmark.circle")
            }
        } label: {
            Image(systemName: networkIconName)
                .foregroundStyle(wifiManager.connectionState.isActive ? .green : .secondary)
        }
    }
    
    /// 네트워크 아이콘 이름
    private var networkIconName: String {
        if wifiManager.isScanning && wifiManager.isAdvertising {
            return "wifi.circle.fill"
        } else if wifiManager.isScanning || wifiManager.isAdvertising {
            return "wifi.circle"
        } else {
            return "wifi.slash"
        }
    }
    
    // MARK: - 액션
    
    /// 네트워킹 시작
    private func startNetworking() {
        if wifiManager.isWiFiAwareAvailable {
            wifiManager.startScanning()
            try? wifiManager.startAdvertising()
        }
    }
    
    /// 파일 선택 처리
    private func handleFileSelected(_ url: URL) {
        guard let peer = selectedPeer else { return }
        
        Task {
            do {
                let file = try TransferFile.from(url: url)
                try await transferService.sendFile(file, to: peer)
                selectedTab = .transfers
            } catch {
                print("❌ 파일 전송 시작 실패: \(error)")
            }
        }
    }
}

// MARK: - 문서 선택기

/// 파일 선택을 위한 Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    let onFileSelected: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onFileSelected: onFileSelected)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFileSelected: (URL) -> Void
        
        init(onFileSelected: @escaping (URL) -> Void) {
            self.onFileSelected = onFileSelected
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // 보안 스코프 접근 시작
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            onFileSelected(url)
        }
    }
}

// MARK: - 설정 뷰

/// 앱 설정 화면
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("기기 정보") {
                    LabeledContent("기기 이름", value: DeviceInfo.deviceName)
                    LabeledContent("모델", value: DeviceInfo.deviceModel)
                    LabeledContent("OS 버전", value: DeviceInfo.osVersion)
                }
                
                Section("앱 정보") {
                    LabeledContent("앱 버전", value: AppConstants.appVersion)
                    LabeledContent("서비스 타입", value: AppConstants.serviceType)
                }
                
                Section("네트워크 설정") {
                    LabeledContent("연결 타임아웃", value: "\(Int(AppConstants.connectionTimeout))초")
                    LabeledContent("청크 크기", value: "\(AppConstants.chunkSize / 1024)KB")
                    LabeledContent("보안 연결", value: AppConstants.useSecureConnection ? "사용" : "사용 안 함")
                }
                
                Section {
                    Link(destination: URL(string: "https://developer.apple.com/documentation/network")!) {
                        Label("Network Framework 문서", systemImage: "book")
                    }
                }
            }
            .navigationTitle("설정")
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

// MARK: - 전송 기록 뷰

/// 완료된 전송 기록 표시
struct TransferHistoryView: View {
    @Environment(FileTransferService.self) private var transferService
    
    var body: some View {
        Group {
            if transferService.completedTransfers.isEmpty {
                ContentUnavailableView(
                    "전송 기록 없음",
                    systemImage: "clock",
                    description: Text("완료된 파일 전송이 여기에 표시됩니다")
                )
            } else {
                List {
                    ForEach(transferService.completedTransfers.reversed()) { file in
                        HStack {
                            Image(systemName: file.direction == .sending ? "arrow.up.circle" : "arrow.down.circle")
                                .foregroundStyle(file.status == .completed ? .green : .red)
                            
                            VStack(alignment: .leading) {
                                Text(file.fileName)
                                    .font(.body)
                                
                                Text("\(file.formattedSize) • \(file.status.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if let endTime = file.endTime {
                                Text(endTime, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(WiFiAwareManager())
        .environment(FileTransferService())
}
