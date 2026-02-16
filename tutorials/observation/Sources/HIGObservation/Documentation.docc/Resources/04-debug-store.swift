import Foundation
import Observation

/// CartFlow 디버그 스토어
/// 앱의 상태 변화를 기록하고 디버그 콘솔에 표시합니다.

@Observable
class DebugStore {
    /// 로그 항목
    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let category: Category
        let message: String
        
        enum Category: String {
            case cart = "🛒"
            case product = "📦"
            case network = "🌐"
            case error = "❌"
            case info = "ℹ️"
        }
        
        var formattedTime: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter.string(from: timestamp)
        }
    }
    
    /// 최근 로그들 (최대 100개)
    private(set) var logs: [LogEntry] = []
    
    /// 콘솔 표시 여부
    var isVisible: Bool = false
    
    /// 로그 필터
    var filter: LogEntry.Category?
    
    /// 필터링된 로그
    var filteredLogs: [LogEntry] {
        guard let filter = filter else { return logs }
        return logs.filter { $0.category == filter }
    }
    
    // MARK: - Actions
    
    func log(_ message: String, category: LogEntry.Category = .info) {
        let entry = LogEntry(
            timestamp: Date(),
            category: category,
            message: message
        )
        
        logs.append(entry)
        
        // 최대 100개 유지
        if logs.count > 100 {
            logs.removeFirst()
        }
        
        #if DEBUG
        print("[\(entry.formattedTime)] \(category.rawValue) \(message)")
        #endif
    }
    
    func clear() {
        logs.removeAll()
    }
    
    func toggleVisibility() {
        isVisible.toggle()
    }
}

// MARK: - Shared Instance

extension DebugStore {
    static let shared = DebugStore()
}

// MARK: - Convenience Methods

extension DebugStore {
    func logCartAction(_ message: String) {
        log(message, category: .cart)
    }
    
    func logProductAction(_ message: String) {
        log(message, category: .product)
    }
    
    func logError(_ message: String) {
        log(message, category: .error)
    }
}
