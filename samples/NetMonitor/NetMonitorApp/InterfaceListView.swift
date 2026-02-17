import SwiftUI
import Network

/// 네트워크 인터페이스 목록 뷰
/// 사용 가능한 모든 네트워크 인터페이스 정보 표시
struct InterfaceListView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    /// 선택된 인터페이스 (상세 정보 표시용)
    @State private var selectedInterface: NetworkInterfaceInfo?
    
    /// 인터페이스 유형 필터
    @State private var filterType: NetworkConnectionType?
    
    var body: some View {
        NavigationStack {
            List {
                // 필터 섹션
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "전체",
                                isSelected: filterType == nil,
                                action: { filterType = nil }
                            )
                            
                            ForEach(availableTypes, id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    icon: type.iconName,
                                    isSelected: filterType == type,
                                    action: { filterType = type }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                // 인터페이스 목록 섹션
                Section {
                    if filteredInterfaces.isEmpty {
                        EmptyInterfaceView()
                    } else {
                        ForEach(filteredInterfaces) { interface in
                            InterfaceRow(interface: interface)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedInterface = interface
                                }
                        }
                    }
                } header: {
                    HStack {
                        Text("사용 가능한 인터페이스")
                        Spacer()
                        Text("\(filteredInterfaces.count)개")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 인터페이스 상세 정보 섹션
                if let interface = selectedInterface {
                    Section {
                        InterfaceDetailView(interface: interface)
                    } header: {
                        HStack {
                            Text("상세 정보")
                            Spacer()
                            Button("닫기") {
                                selectedInterface = nil
                            }
                            .font(.caption)
                        }
                    }
                }
                
                // 시스템 인터페이스 정보 섹션
                Section {
                    SystemInterfaceInfoView()
                } header: {
                    Text("시스템 정보")
                }
            }
            .navigationTitle("인터페이스")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .refreshable {
                // 새로고침 시 모니터 재시작
                networkMonitor.stopMonitoring()
                try? await Task.sleep(nanoseconds: 500_000_000)
                networkMonitor.startMonitoring()
            }
        }
    }
    
    /// 필터링된 인터페이스 목록
    private var filteredInterfaces: [NetworkInterfaceInfo] {
        guard let filter = filterType else {
            return networkMonitor.availableInterfaces
        }
        return networkMonitor.availableInterfaces.filter { $0.type == filter }
    }
    
    /// 사용 가능한 인터페이스 유형들
    private var availableTypes: [NetworkConnectionType] {
        let types = Set(networkMonitor.availableInterfaces.map { $0.type })
        return Array(types).sorted { $0.rawValue < $1.rawValue }
    }
}

// MARK: - 필터 칩
/// 인터페이스 유형 필터 버튼
struct FilterChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 인터페이스 행
/// 개별 인터페이스 정보를 표시하는 행
struct InterfaceRow: View {
    let interface: NetworkInterfaceInfo
    
    var body: some View {
        HStack {
            // 인터페이스 유형 아이콘
            Image(systemName: interface.type.iconName)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(interface.name)
                    .font(.headline)
                
                Text(interface.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 상태 뱃지
            HStack(spacing: 4) {
                if interface.isExpensive {
                    StatusBadge(text: "비용", color: .orange)
                }
                if interface.isConstrained {
                    StatusBadge(text: "제한", color: .yellow)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 상태 뱃지
/// 작은 상태 표시 뱃지
struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

// MARK: - 인터페이스 상세 뷰
/// 선택된 인터페이스의 상세 정보
struct InterfaceDetailView: View {
    let interface: NetworkInterfaceInfo
    
    var body: some View {
        VStack(spacing: 12) {
            // 헤더
            HStack {
                Image(systemName: interface.type.iconName)
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading) {
                    Text(interface.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(interface.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // 상세 정보
            VStack(spacing: 8) {
                DetailInfoRow(title: "인터페이스 ID", value: interface.id)
                DetailInfoRow(title: "유형", value: interface.type.rawValue)
                DetailInfoRow(title: "비용 발생", value: interface.isExpensive ? "예" : "아니오")
                DetailInfoRow(title: "데이터 제한", value: interface.isConstrained ? "예" : "아니오")
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 상세 정보 행
struct DetailInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

// MARK: - 빈 인터페이스 뷰
/// 인터페이스가 없을 때 표시
struct EmptyInterfaceView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "network.slash")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("사용 가능한 인터페이스가 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("네트워크 연결을 확인해주세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - 시스템 인터페이스 정보 뷰
/// 시스템 수준의 네트워크 정보 표시
struct SystemInterfaceInfoView: View {
    @State private var hostName: String = ""
    @State private var ipAddresses: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !hostName.isEmpty {
                DetailInfoRow(title: "호스트명", value: hostName)
            }
            
            if !ipAddresses.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("IP 주소")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    
                    ForEach(ipAddresses, id: \.self) { ip in
                        Text(ip)
                            .font(.system(.subheadline, design: .monospaced))
                            .padding(.leading, 8)
                    }
                }
            }
        }
        .onAppear {
            loadSystemInfo()
        }
    }
    
    /// 시스템 정보 로드
    private func loadSystemInfo() {
        // 호스트명 가져오기
        hostName = ProcessInfo.processInfo.hostName
        
        // IP 주소 가져오기 (간단한 구현)
        ipAddresses = getIPAddresses()
    }
    
    /// 모든 IP 주소 가져오기
    private func getIPAddresses() -> [String] {
        var addresses: [String] = []
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return addresses
        }
        
        defer { freeifaddrs(ifaddr) }
        
        var ptr = firstAddr
        while true {
            let interface = ptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                
                // 루프백 제외
                if name != "lo0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        0,
                        NI_NUMERICHOST
                    )
                    let address = String(cString: hostname)
                    if !address.isEmpty {
                        addresses.append("\(name): \(address)")
                    }
                }
            }
            
            guard let next = interface.ifa_next else { break }
            ptr = next
        }
        
        return addresses
    }
}

#Preview {
    InterfaceListView()
        .environmentObject(NetworkMonitor())
}
