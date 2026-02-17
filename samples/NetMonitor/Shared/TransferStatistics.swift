import Foundation

// MARK: - 전송 통계
/// 네트워크 데이터 전송 통계를 관리
class TransferStatistics: ObservableObject {
    /// 송신 바이트 수
    @Published private(set) var bytesSent: UInt64 = 0
    
    /// 수신 바이트 수
    @Published private(set) var bytesReceived: UInt64 = 0
    
    /// 송신 패킷 수
    @Published private(set) var packetsSent: UInt64 = 0
    
    /// 수신 패킷 수
    @Published private(set) var packetsReceived: UInt64 = 0
    
    /// 통계 시작 시간
    let startTime: Date
    
    /// 마지막 갱신 시간
    @Published private(set) var lastUpdateTime: Date
    
    /// 최근 송신 속도 (bytes/sec)
    @Published private(set) var sendRate: Double = 0
    
    /// 최근 수신 속도 (bytes/sec)
    @Published private(set) var receiveRate: Double = 0
    
    /// 속도 계산을 위한 이전 값들
    private var previousBytesSent: UInt64 = 0
    private var previousBytesReceived: UInt64 = 0
    private var previousUpdateTime: Date
    
    init() {
        let now = Date()
        self.startTime = now
        self.lastUpdateTime = now
        self.previousUpdateTime = now
    }
    
    // MARK: - 통계 기록
    
    /// 송신 데이터 기록
    func recordSent(bytes: Int) {
        DispatchQueue.main.async {
            self.bytesSent += UInt64(bytes)
            self.packetsSent += 1
            self.updateRates()
        }
    }
    
    /// 수신 데이터 기록
    func recordReceived(bytes: Int) {
        DispatchQueue.main.async {
            self.bytesReceived += UInt64(bytes)
            self.packetsReceived += 1
            self.updateRates()
        }
    }
    
    /// 전송 속도 갱신
    private func updateRates() {
        let now = Date()
        let elapsed = now.timeIntervalSince(previousUpdateTime)
        
        // 최소 1초 간격으로 속도 계산
        guard elapsed >= 1.0 else {
            lastUpdateTime = now
            return
        }
        
        let sentDiff = Double(bytesSent - previousBytesSent)
        let receivedDiff = Double(bytesReceived - previousBytesReceived)
        
        sendRate = sentDiff / elapsed
        receiveRate = receivedDiff / elapsed
        
        previousBytesSent = bytesSent
        previousBytesReceived = bytesReceived
        previousUpdateTime = now
        lastUpdateTime = now
    }
    
    /// 통계 초기화
    func reset() {
        DispatchQueue.main.async {
            self.bytesSent = 0
            self.bytesReceived = 0
            self.packetsSent = 0
            self.packetsReceived = 0
            self.sendRate = 0
            self.receiveRate = 0
            self.previousBytesSent = 0
            self.previousBytesReceived = 0
            self.previousUpdateTime = Date()
            self.lastUpdateTime = Date()
        }
    }
    
    // MARK: - 포맷된 문자열
    
    /// 총 전송 바이트 (송신 + 수신)
    var totalBytes: UInt64 {
        bytesSent + bytesReceived
    }
    
    /// 포맷된 송신 바이트
    var formattedBytesSent: String {
        Self.formatBytes(bytesSent)
    }
    
    /// 포맷된 수신 바이트
    var formattedBytesReceived: String {
        Self.formatBytes(bytesReceived)
    }
    
    /// 포맷된 총 바이트
    var formattedTotalBytes: String {
        Self.formatBytes(totalBytes)
    }
    
    /// 포맷된 송신 속도
    var formattedSendRate: String {
        Self.formatBytesPerSecond(sendRate)
    }
    
    /// 포맷된 수신 속도
    var formattedReceiveRate: String {
        Self.formatBytesPerSecond(receiveRate)
    }
    
    /// 경과 시간
    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startTime)
    }
    
    /// 포맷된 경과 시간
    var formattedElapsedTime: String {
        let seconds = Int(elapsedTime)
        let minutes = seconds / 60
        let hours = minutes / 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes % 60, seconds % 60)
        } else {
            return String(format: "%02d:%02d", minutes, seconds % 60)
        }
    }
    
    // MARK: - 유틸리티
    
    /// 바이트를 읽기 쉬운 형식으로 변환
    static func formatBytes(_ bytes: UInt64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var unitIndex = 0
        
        while value >= 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }
        
        if unitIndex == 0 {
            return "\(Int(value)) \(units[unitIndex])"
        } else {
            return String(format: "%.2f %@", value, units[unitIndex])
        }
    }
    
    /// 초당 바이트를 읽기 쉬운 형식으로 변환
    static func formatBytesPerSecond(_ bytesPerSecond: Double) -> String {
        let formatted = formatBytes(UInt64(bytesPerSecond))
        return "\(formatted)/s"
    }
}

// MARK: - 통계 스냅샷
/// 특정 시점의 통계 스냅샷 (비교용)
struct StatisticsSnapshot: Identifiable {
    let id: UUID
    let timestamp: Date
    let bytesSent: UInt64
    let bytesReceived: UInt64
    let packetsSent: UInt64
    let packetsReceived: UInt64
    
    init(from statistics: TransferStatistics) {
        self.id = UUID()
        self.timestamp = Date()
        self.bytesSent = statistics.bytesSent
        self.bytesReceived = statistics.bytesReceived
        self.packetsSent = statistics.packetsSent
        self.packetsReceived = statistics.packetsReceived
    }
    
    /// 포맷된 시간
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: timestamp)
    }
}

// MARK: - 세션 통계
/// 연결 세션별 통계
struct SessionStatistics: Identifiable {
    let id: UUID
    let connectionInfo: ConnectionInfo
    let statistics: TransferStatistics
    let startTime: Date
    var endTime: Date?
    
    init(connectionInfo: ConnectionInfo) {
        self.id = UUID()
        self.connectionInfo = connectionInfo
        self.statistics = TransferStatistics()
        self.startTime = Date()
        self.endTime = nil
    }
    
    /// 세션 종료
    mutating func end() {
        endTime = Date()
    }
    
    /// 세션 지속 시간
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    /// 포맷된 지속 시간
    var formattedDuration: String {
        let seconds = Int(duration)
        let minutes = seconds / 60
        
        if minutes > 0 {
            return "\(minutes)분 \(seconds % 60)초"
        } else {
            return "\(seconds)초"
        }
    }
}
