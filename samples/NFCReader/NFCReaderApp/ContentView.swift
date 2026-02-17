import SwiftUI

// MARK: - 메인 콘텐츠 뷰

/// 앱의 메인 화면
struct ContentView: View {
    @EnvironmentObject var nfcManager: NFCManager
    @EnvironmentObject var historyManager: ScanHistoryManager
    
    /// 선택된 탭
    @State private var selectedTab: Tab = .scan
    
    /// 탭 열거형
    enum Tab {
        case scan, write, history
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 스캔 탭
            ScanView()
                .tabItem {
                    Label("스캔", systemImage: "wave.3.right")
                }
                .tag(Tab.scan)
            
            // 쓰기 탭
            WriteTagView()
                .tabItem {
                    Label("쓰기", systemImage: "square.and.pencil")
                }
                .tag(Tab.write)
            
            // 히스토리 탭
            HistoryView()
                .tabItem {
                    Label("히스토리", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.history)
        }
        .accentColor(.nfcPrimary)
    }
}

// MARK: - 스캔 뷰

/// NFC 태그 스캔 화면
struct ScanView: View {
    @EnvironmentObject var nfcManager: NFCManager
    @EnvironmentObject var historyManager: ScanHistoryManager
    
    /// 스캔 결과 시트 표시 여부
    @State private var showResult = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // NFC 지원 여부 체크
                    if !nfcManager.isNFCSupported {
                        NFCNotSupportedView()
                    } else {
                        // 상태 아이콘
                        ScanStatusView(state: nfcManager.scanState)
                            .padding(.top, 40)
                        
                        // 스캔 버튼
                        scanButton
                            .padding(.horizontal)
                        
                        // 최근 스캔 정보
                        if let message = nfcManager.lastScannedMessage {
                            RecentScanCard(message: message)
                                .padding(.horizontal)
                                .onTapGesture {
                                    showResult = true
                                }
                        }
                        
                        // 간단한 통계
                        QuickStatsView()
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.nfcBackground)
            .navigationTitle("NFC 스캔")
            .sheet(isPresented: $showResult) {
                if let message = nfcManager.lastScannedMessage {
                    ScanResultView(message: message)
                }
            }
            .onChange(of: nfcManager.scanState) { _, newState in
                if case .success = newState {
                    // 스캔 성공 시 히스토리에 추가
                    if let message = nfcManager.lastScannedMessage {
                        historyManager.addItem(message)
                        showResult = true
                    }
                }
            }
        }
    }
    
    /// 스캔 버튼
    private var scanButton: some View {
        Button {
            nfcManager.startScanning()
        } label: {
            HStack {
                Image(systemName: "wave.3.right.circle.fill")
                    .font(.title2)
                Text("태그 스캔하기")
            }
        }
        .primaryButtonStyle(isEnabled: !nfcManager.scanState.isActive)
        .disabled(nfcManager.scanState.isActive)
    }
}

// MARK: - 스캔 상태 뷰

/// 스캔 상태를 시각적으로 표시
struct ScanStatusView: View {
    let state: NFCManager.ScanState
    
    var body: some View {
        VStack(spacing: 16) {
            // 상태 아이콘
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 120, height: 120)
                
                Image(systemName: iconName)
                    .font(.system(size: 50))
                    .foregroundColor(iconColor)
                    .symbolEffect(.pulse, isActive: state.isActive)
            }
            
            // 상태 텍스트
            Text(statusText)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .animation(.easeInOut, value: state)
    }
    
    private var iconName: String {
        switch state {
        case .idle:
            return "wave.3.right"
        case .scanning:
            return "antenna.radiowaves.left.and.right"
        case .writing:
            return "square.and.pencil"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var iconColor: Color {
        switch state {
        case .idle:
            return .nfcPrimary
        case .scanning, .writing:
            return .nfcSecondary
        case .success:
            return .nfcSuccess
        case .error:
            return .nfcError
        }
    }
    
    private var backgroundColor: Color {
        iconColor.opacity(0.15)
    }
    
    private var statusText: String {
        switch state {
        case .idle:
            return "태그를 스캔할 준비가 되었습니다"
        case .scanning:
            return "태그 스캔 중..."
        case .writing:
            return "태그에 쓰는 중..."
        case .success:
            return "스캔 완료!"
        case .error(let message):
            return message
        }
    }
}

// MARK: - NFC 미지원 뷰

/// NFC를 지원하지 않는 기기용 안내 뷰
struct NFCNotSupportedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "iphone.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("NFC를 지원하지 않습니다")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("이 기기에서는 NFC 기능을 사용할 수 없습니다.\niPhone 7 이상에서 지원됩니다.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .cardStyle()
        .padding()
    }
}

// MARK: - 최근 스캔 카드

/// 최근 스캔된 태그 정보 카드
struct RecentScanCard: View {
    let message: NDEFMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("최근 스캔")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            HStack(spacing: 12) {
                // 콘텐츠 타입 아이콘
                Image(systemName: message.primaryContentType.iconName)
                    .font(.title2)
                    .foregroundColor(.nfcPrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.nfcPrimary.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.primaryContentType.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(message.summary)
                        .font(.body)
                        .lineLimit(2)
                }
            }
            
            // 태그 정보
            HStack {
                Label(message.tagType.rawValue, systemImage: message.tagType.iconName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if message.records.count > 1 {
                    Text("\(message.records.count)개 레코드")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - 간단한 통계 뷰

/// 스캔 통계를 간략히 보여주는 뷰
struct QuickStatsView: View {
    @EnvironmentObject var historyManager: ScanHistoryManager
    
    var body: some View {
        let stats = historyManager.statistics
        
        VStack(alignment: .leading, spacing: 12) {
            Text("통계")
                .font(.headline)
            
            HStack(spacing: 16) {
                StatItem(
                    icon: "number",
                    title: "총 스캔",
                    value: "\(stats.totalScans)"
                )
                
                StatItem(
                    icon: "link",
                    title: "URL",
                    value: "\(stats.urlScans)"
                )
                
                StatItem(
                    icon: "text.alignleft",
                    title: "텍스트",
                    value: "\(stats.textScans)"
                )
                
                StatItem(
                    icon: "star.fill",
                    title: "즐겨찾기",
                    value: "\(stats.favoriteCount)"
                )
            }
        }
        .cardStyle()
    }
}

/// 통계 항목
struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.nfcPrimary)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 프리뷰

#Preview {
    ContentView()
        .environmentObject(NFCManager())
        .environmentObject(ScanHistoryManager())
}
