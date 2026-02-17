import Foundation
import SwiftUI

// MARK: - 통화 기록 모델
// 과거 통화 내역을 저장하고 관리

/// 통화 결과 열거형
enum CallResult: String, Codable {
    case completed      // 정상 종료
    case missed         // 부재중
    case declined       // 거절됨
    case failed         // 실패
    case cancelled      // 취소됨
    
    /// 결과에 따른 표시 텍스트
    var displayText: String {
        switch self {
        case .completed: return "완료"
        case .missed: return "부재중"
        case .declined: return "거절됨"
        case .failed: return "실패"
        case .cancelled: return "취소됨"
        }
    }
    
    /// 결과에 따른 색상
    var color: Color {
        switch self {
        case .completed: return .primary
        case .missed: return .red
        case .declined: return .orange
        case .failed: return .red
        case .cancelled: return .secondary
        }
    }
}

/// 통화 기록 항목
struct CallHistoryEntry: Identifiable, Codable {
    let id: UUID                    // 고유 식별자
    let callId: UUID                // 원본 통화 ID
    let phoneNumber: String         // 전화번호
    let contactName: String?        // 연락처 이름
    let direction: CallDirection    // 통화 방향
    let result: CallResult          // 통화 결과
    let timestamp: Date             // 통화 시작 시간
    let duration: TimeInterval?     // 통화 시간 (초)
    
    /// 표시할 이름
    var displayName: String {
        contactName ?? phoneNumber
    }
    
    /// 포맷된 통화 시간
    var formattedDuration: String {
        guard let duration = duration else { return "-" }
        if duration < 60 {
            return "\(Int(duration))초"
        }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)분 \(seconds)초"
    }
    
    /// 포맷된 타임스탬프
    var formattedTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    /// 상세 타임스탬프
    var detailedTimestamp: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 a h:mm"
        return formatter.string(from: timestamp)
    }
    
    /// Call 객체로부터 생성
    init(from call: Call, result: CallResult) {
        self.id = UUID()
        self.callId = call.id
        self.phoneNumber = call.remotePhoneNumber
        self.contactName = call.remoteName
        self.direction = call.direction
        self.result = result
        self.timestamp = call.startTime
        self.duration = call.duration
    }
    
    init(
        id: UUID = UUID(),
        callId: UUID = UUID(),
        phoneNumber: String,
        contactName: String? = nil,
        direction: CallDirection,
        result: CallResult,
        timestamp: Date = Date(),
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.callId = callId
        self.phoneNumber = phoneNumber
        self.contactName = contactName
        self.direction = direction
        self.result = result
        self.timestamp = timestamp
        self.duration = duration
    }
}

// MARK: - 통화 기록 저장소
// 통화 기록을 영구 저장하고 관리

/// 통화 기록 저장소 클래스
class CallHistoryStore: ObservableObject {
    static let shared = CallHistoryStore()
    
    @Published var entries: [CallHistoryEntry] = []
    
    private let storageKey = "voipphone_call_history"
    private let maxEntries = 100  // 최대 저장 개수
    
    private init() {
        loadHistory()
        
        // 샘플 데이터가 없으면 추가
        if entries.isEmpty {
            addSampleHistory()
        }
    }
    
    /// 기록 불러오기
    func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CallHistoryEntry].self, from: data) else {
            return
        }
        entries = decoded.sorted { $0.timestamp > $1.timestamp }
    }
    
    /// 기록 저장
    func saveHistory() {
        // 최대 개수 제한
        let entriesToSave = Array(entries.prefix(maxEntries))
        guard let data = try? JSONEncoder().encode(entriesToSave) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    /// 새 기록 추가
    func addEntry(_ entry: CallHistoryEntry) {
        entries.insert(entry, at: 0)
        saveHistory()
    }
    
    /// Call 객체로부터 기록 추가
    func addEntry(from call: Call, result: CallResult) {
        let entry = CallHistoryEntry(from: call, result: result)
        addEntry(entry)
    }
    
    /// 기록 삭제
    func deleteEntry(_ entry: CallHistoryEntry) {
        entries.removeAll { $0.id == entry.id }
        saveHistory()
    }
    
    /// 여러 기록 삭제
    func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveHistory()
    }
    
    /// 모든 기록 삭제
    func clearAllHistory() {
        entries.removeAll()
        saveHistory()
    }
    
    /// 특정 전화번호의 기록 조회
    func entries(for phoneNumber: String) -> [CallHistoryEntry] {
        let digits = phoneNumber.filter { $0.isNumber }
        return entries.filter { entry in
            entry.phoneNumber.filter { $0.isNumber } == digits
        }
    }
    
    /// 부재중 통화 목록
    var missedCalls: [CallHistoryEntry] {
        entries.filter { $0.result == .missed }
    }
    
    /// 오늘 통화 목록
    var todayCalls: [CallHistoryEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.timestamp) }
    }
    
    /// 날짜별로 그룹화된 기록
    var groupedByDate: [(Date, [CallHistoryEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    /// 샘플 기록 추가
    private func addSampleHistory() {
        let now = Date()
        let samples = [
            CallHistoryEntry(
                phoneNumber: "01012345678",
                contactName: "김철수",
                direction: .incoming,
                result: .completed,
                timestamp: now.addingTimeInterval(-3600),
                duration: 125
            ),
            CallHistoryEntry(
                phoneNumber: "01023456789",
                contactName: "이영희",
                direction: .outgoing,
                result: .completed,
                timestamp: now.addingTimeInterval(-7200),
                duration: 302
            ),
            CallHistoryEntry(
                phoneNumber: "01099999999",
                contactName: nil,
                direction: .incoming,
                result: .missed,
                timestamp: now.addingTimeInterval(-10800),
                duration: nil
            ),
            CallHistoryEntry(
                phoneNumber: "01034567890",
                contactName: "박민수",
                direction: .outgoing,
                result: .cancelled,
                timestamp: now.addingTimeInterval(-86400),
                duration: nil
            ),
            CallHistoryEntry(
                phoneNumber: "01045678901",
                contactName: "정수진",
                direction: .incoming,
                result: .declined,
                timestamp: now.addingTimeInterval(-172800),
                duration: nil
            )
        ]
        entries = samples
        saveHistory()
    }
}

// MARK: - 통화 기록 행 뷰
// 통화 기록 목록에서 각 항목을 표시하는 뷰

/// 통화 기록 행 뷰
struct CallHistoryRow: View {
    let entry: CallHistoryEntry
    let contact: Contact?
    
    var body: some View {
        HStack(spacing: 12) {
            // 아바타 또는 기본 아이콘
            if let contact = contact {
                ContactAvatar(contact: contact, size: 44)
            } else {
                Circle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                    )
            }
            
            // 연락처 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    // 방향 아이콘
                    Image(systemName: entry.direction.iconName)
                        .font(.caption)
                        .foregroundColor(entry.result.color)
                    
                    // 이름
                    Text(entry.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(entry.result.color)
                }
                
                // 시간 및 결과
                HStack(spacing: 4) {
                    Text(entry.formattedTimestamp)
                    if let _ = entry.duration {
                        Text("•")
                        Text(entry.formattedDuration)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 전화 버튼
            Button(action: {}) {
                Image(systemName: "phone.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}
