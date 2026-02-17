import Foundation

// MARK: - 스캔 히스토리 항목

/// NFC 태그 스캔 히스토리 항목
struct ScanHistoryItem: Identifiable, Codable {
    let id: UUID
    let scannedAt: Date           // 스캔 시간
    let message: NDEFMessage      // 스캔된 메시지
    var isFavorite: Bool          // 즐겨찾기 여부
    var note: String?             // 사용자 메모
    
    init(
        id: UUID = UUID(),
        scannedAt: Date = Date(),
        message: NDEFMessage,
        isFavorite: Bool = false,
        note: String? = nil
    ) {
        self.id = id
        self.scannedAt = scannedAt
        self.message = message
        self.isFavorite = isFavorite
        self.note = note
    }
    
    /// 포맷된 스캔 시간
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: scannedAt)
    }
    
    /// 상대적 스캔 시간 (예: "3분 전")
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: scannedAt, relativeTo: Date())
    }
}

// MARK: - 스캔 히스토리 매니저

/// 스캔 히스토리를 관리하는 클래스
@MainActor
class ScanHistoryManager: ObservableObject {
    @Published private(set) var items: [ScanHistoryItem] = []
    
    private let storageKey = "NFCReader.ScanHistory"
    private let maxHistoryCount = 100  // 최대 저장 개수
    
    init() {
        loadHistory()
    }
    
    // MARK: - 공개 메서드
    
    /// 새 스캔 항목 추가
    func addItem(_ message: NDEFMessage) {
        let item = ScanHistoryItem(message: message)
        items.insert(item, at: 0)
        
        // 최대 개수 초과 시 오래된 항목 제거
        if items.count > maxHistoryCount {
            items = Array(items.prefix(maxHistoryCount))
        }
        
        saveHistory()
    }
    
    /// 항목 삭제
    func deleteItem(_ item: ScanHistoryItem) {
        items.removeAll { $0.id == item.id }
        saveHistory()
    }
    
    /// 여러 항목 삭제
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveHistory()
    }
    
    /// 모든 히스토리 삭제
    func clearHistory() {
        items.removeAll()
        saveHistory()
    }
    
    /// 즐겨찾기 토글
    func toggleFavorite(_ item: ScanHistoryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite.toggle()
            saveHistory()
        }
    }
    
    /// 메모 업데이트
    func updateNote(_ item: ScanHistoryItem, note: String?) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].note = note
            saveHistory()
        }
    }
    
    /// 즐겨찾기 항목만 필터링
    var favoriteItems: [ScanHistoryItem] {
        items.filter { $0.isFavorite }
    }
    
    /// 특정 기간 내 항목 필터링
    func items(within period: DatePeriod) -> [ScanHistoryItem] {
        let cutoffDate: Date
        
        switch period {
        case .today:
            cutoffDate = Calendar.current.startOfDay(for: Date())
        case .week:
            cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .all:
            return items
        }
        
        return items.filter { $0.scannedAt >= cutoffDate }
    }
    
    /// 콘텐츠 타입으로 필터링
    func items(ofType type: NDEFMessage.ContentType) -> [ScanHistoryItem] {
        items.filter { $0.message.primaryContentType == type }
    }
    
    // MARK: - 저장 및 로드
    
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("히스토리 저장 실패: \(error.localizedDescription)")
        }
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }
        
        do {
            items = try JSONDecoder().decode([ScanHistoryItem].self, from: data)
        } catch {
            print("히스토리 로드 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 기간 열거형
    
    enum DatePeriod: String, CaseIterable {
        case today = "오늘"
        case week = "이번 주"
        case month = "이번 달"
        case all = "전체"
    }
}

// MARK: - 히스토리 통계

extension ScanHistoryManager {
    /// 히스토리 통계
    struct Statistics {
        let totalScans: Int
        let urlScans: Int
        let textScans: Int
        let contactScans: Int
        let uniqueTags: Int
        let favoriteCount: Int
        let mostRecentScan: Date?
    }
    
    /// 통계 계산
    var statistics: Statistics {
        var urlCount = 0
        var textCount = 0
        var contactCount = 0
        var uniqueTagIds = Set<String>()
        
        for item in items {
            switch item.message.primaryContentType {
            case .url, .email, .phone:
                urlCount += 1
            case .text:
                textCount += 1
            case .contact:
                contactCount += 1
            default:
                break
            }
            
            if let tagId = item.message.tagIdentifier {
                uniqueTagIds.insert(tagId.hexString)
            }
        }
        
        return Statistics(
            totalScans: items.count,
            urlScans: urlCount,
            textScans: textCount,
            contactScans: contactCount,
            uniqueTags: uniqueTagIds.count,
            favoriteCount: favoriteItems.count,
            mostRecentScan: items.first?.scannedAt
        )
    }
}

// MARK: - 내보내기 기능

extension ScanHistoryManager {
    /// 히스토리를 JSON으로 내보내기
    func exportToJSON() -> Data? {
        try? JSONEncoder().encode(items)
    }
    
    /// JSON에서 히스토리 가져오기
    func importFromJSON(_ data: Data) throws {
        let importedItems = try JSONDecoder().decode([ScanHistoryItem].self, from: data)
        
        // 중복 제거하며 병합
        var existingIds = Set(items.map { $0.id })
        for item in importedItems {
            if !existingIds.contains(item.id) {
                items.append(item)
                existingIds.insert(item.id)
            }
        }
        
        // 날짜순 정렬
        items.sort { $0.scannedAt > $1.scannedAt }
        
        // 최대 개수 제한
        if items.count > maxHistoryCount {
            items = Array(items.prefix(maxHistoryCount))
        }
        
        saveHistory()
    }
}
