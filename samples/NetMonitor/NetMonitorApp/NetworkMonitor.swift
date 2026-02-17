import Foundation
import Network
import Combine

/// NWPathMonitor를 사용한 네트워크 상태 모니터링
/// Wi-Fi, 셀룰러, 이더넷 등 다양한 네트워크 상태를 실시간으로 감지
class NetworkMonitor: ObservableObject {
    
    // MARK: - Published 속성
    
    /// 현재 네트워크 경로 상태
    @Published private(set) var pathState: NetworkPathState = .disconnected
    
    /// 연결 여부
    @Published private(set) var isConnected: Bool = false
    
    /// 현재 연결 유형
    @Published private(set) var connectionType: NetworkConnectionType = .none
    
    /// 비용 발생 연결 여부 (셀룰러 등)
    @Published private(set) var isExpensive: Bool = false
    
    /// 저데이터 모드 여부
    @Published private(set) var isConstrained: Bool = false
    
    /// 연결 품질
    @Published private(set) var connectionQuality: ConnectionQuality = .none
    
    /// 사용 가능한 인터페이스 목록
    @Published private(set) var availableInterfaces: [NetworkInterfaceInfo] = []
    
    /// 상태 변경 히스토리
    @Published private(set) var stateHistory: [NetworkStateChange] = []
    
    // MARK: - Private 속성
    
    /// NWPathMonitor 인스턴스
    private let pathMonitor: NWPathMonitor
    
    /// 모니터 실행 큐
    private let monitorQueue = DispatchQueue(label: "com.netmonitor.pathmonitor", qos: .userInitiated)
    
    /// 모니터링 활성화 여부
    private var isMonitoring: Bool = false
    
    /// 품질 측정 타이머
    private var qualityTimer: Timer?
    
    // MARK: - 초기화
    
    init() {
        self.pathMonitor = NWPathMonitor()
        setupPathMonitor()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - 모니터 설정
    
    /// NWPathMonitor 핸들러 설정
    private func setupPathMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.handlePathUpdate(path)
            }
        }
    }
    
    /// 경로 업데이트 처리
    private func handlePathUpdate(_ path: NWPath) {
        let newPathState = NetworkPathState(from: path)
        let previousConnectionType = connectionType
        
        // 상태 업데이트
        pathState = newPathState
        isConnected = path.status == .satisfied
        connectionType = newPathState.connectionType
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained
        availableInterfaces = newPathState.interfaces
        
        // 연결 유형이 변경되었으면 히스토리에 기록
        if previousConnectionType != connectionType {
            recordStateChange(from: previousConnectionType, to: connectionType)
        }
        
        // 연결 품질 업데이트
        updateConnectionQuality(path: path)
        
        // 디버그 로깅
        logPathUpdate(path)
    }
    
    /// 상태 변경 기록
    private func recordStateChange(from previousType: NetworkConnectionType, to newType: NetworkConnectionType) {
        let change = NetworkStateChange(
            timestamp: Date(),
            fromType: previousType,
            toType: newType
        )
        stateHistory.append(change)
        
        // 최대 50개까지만 유지
        if stateHistory.count > 50 {
            stateHistory.removeFirst()
        }
    }
    
    /// 연결 품질 업데이트
    private func updateConnectionQuality(path: NWPath) {
        guard path.status == .satisfied else {
            connectionQuality = .none
            return
        }
        
        // 연결 유형에 따른 기본 품질 추정
        // 실제로는 지연 시간, 패킷 손실률 등을 측정해야 함
        switch connectionType {
        case .wiredEthernet:
            connectionQuality = .excellent
        case .wifi:
            // Wi-Fi는 추가 측정이 필요하지만 기본적으로 양호
            connectionQuality = isConstrained ? .fair : .good
        case .cellular:
            // 셀룰러는 비용과 제한 상태에 따라 달라짐
            connectionQuality = isConstrained ? .poor : .fair
        case .loopback:
            connectionQuality = .excellent
        case .other:
            connectionQuality = .fair
        case .none:
            connectionQuality = .none
        }
    }
    
    /// 경로 업데이트 로깅
    private func logPathUpdate(_ path: NWPath) {
        #if DEBUG
        print("──────────────────────────────────")
        print("📡 네트워크 상태 변경")
        print("  상태: \(path.status == .satisfied ? "연결됨" : "연결 안 됨")")
        print("  유형: \(connectionType.rawValue)")
        print("  비용 발생: \(isExpensive ? "예" : "아니오")")
        print("  저데이터 모드: \(isConstrained ? "예" : "아니오")")
        print("  IPv4 지원: \(path.supportsIPv4 ? "예" : "아니오")")
        print("  IPv6 지원: \(path.supportsIPv6 ? "예" : "아니오")")
        print("  인터페이스:")
        for interface in path.availableInterfaces {
            print("    - \(interface.name) (\(interface.type))")
        }
        print("──────────────────────────────────")
        #endif
    }
    
    // MARK: - 모니터링 제어
    
    /// 모니터링 시작
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        pathMonitor.start(queue: monitorQueue)
        isMonitoring = true
        
        // 품질 주기적 업데이트 (30초마다)
        startQualityTimer()
        
        print("✅ 네트워크 모니터링 시작됨")
    }
    
    /// 모니터링 중지
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        pathMonitor.cancel()
        isMonitoring = false
        
        stopQualityTimer()
        
        print("⏹️ 네트워크 모니터링 중지됨")
    }
    
    /// 품질 측정 타이머 시작
    private func startQualityTimer() {
        qualityTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.measureConnectionQuality()
        }
    }
    
    /// 품질 측정 타이머 중지
    private func stopQualityTimer() {
        qualityTimer?.invalidate()
        qualityTimer = nil
    }
    
    /// 연결 품질 측정 (간단한 ping 테스트)
    private func measureConnectionQuality() {
        guard isConnected else {
            connectionQuality = .none
            return
        }
        
        // 실제 구현에서는 네트워크 지연 시간 측정
        // 여기서는 현재 상태 기반으로 유지
        #if DEBUG
        print("🔄 연결 품질 측정: \(connectionQuality.rawValue)")
        #endif
    }
    
    // MARK: - 특정 인터페이스 모니터링
    
    /// 특정 인터페이스 유형만 모니터링하는 새 모니터 생성
    func createMonitor(for interfaceType: NWInterface.InterfaceType) -> NWPathMonitor {
        return NWPathMonitor(requiredInterfaceType: interfaceType)
    }
    
    /// Wi-Fi 전용 모니터 생성
    func createWiFiMonitor() -> NWPathMonitor {
        return createMonitor(for: .wifi)
    }
    
    /// 셀룰러 전용 모니터 생성
    func createCellularMonitor() -> NWPathMonitor {
        return createMonitor(for: .cellular)
    }
    
    // MARK: - 히스토리 관리
    
    /// 히스토리 초기화
    func clearHistory() {
        stateHistory.removeAll()
    }
}

// MARK: - 상태 변경 기록
/// 네트워크 상태 변경 히스토리 항목
struct NetworkStateChange: Identifiable {
    let id = UUID()
    let timestamp: Date
    let fromType: NetworkConnectionType
    let toType: NetworkConnectionType
    
    /// 포맷된 시간
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: timestamp)
    }
    
    /// 변경 설명
    var description: String {
        "\(fromType.rawValue) → \(toType.rawValue)"
    }
}
