import Foundation
import Combine
import SwiftUI

enum LearningStatus: String, CaseIterable, Codable, Identifiable {
    case inProgress
    case completed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inProgress:
            return "진행중"
        case .completed:
            return "완성"
        }
    }

    var systemImage: String {
        switch self {
        case .inProgress:
            return "clock"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
}

enum DailyChecklistItem: String, CaseIterable, Codable, Identifiable {
    case docs
    case tutorial
    case sample
    case retrospective

    var id: String { rawValue }

    var title: String {
        switch self {
        case .docs:
            return "문서/블로그 읽기"
        case .tutorial:
            return "튜토리얼 1챕터 실습"
        case .sample:
            return "샘플 코드 비교"
        case .retrospective:
            return "회고 3줄 작성"
        }
    }
}

@MainActor
final class LearningProgressStore: ObservableObject {
    @Published private(set) var statusByFramework: [String: LearningStatus] = [:]
    @Published private(set) var checklistByFramework: [String: Set<String>] = [:]

    private let statusKey = "practice.learning.statusByFramework"
    private let checklistKey = "practice.learning.checklistByFramework"

    init() {
        load()
    }

    func status(for item: FrameworkItem) -> LearningStatus {
        statusByFramework[item.id] ?? (item.isCompleted ? .completed : .inProgress)
    }

    func setStatus(_ status: LearningStatus, for item: FrameworkItem) {
        statusByFramework[item.id] = status
        persist()
    }

    func isChecked(_ task: DailyChecklistItem, for item: FrameworkItem) -> Bool {
        checklistByFramework[item.id, default: []].contains(task.rawValue)
    }

    func toggle(_ task: DailyChecklistItem, for item: FrameworkItem) {
        var tasks = checklistByFramework[item.id, default: []]
        if tasks.contains(task.rawValue) {
            tasks.remove(task.rawValue)
        } else {
            tasks.insert(task.rawValue)
        }
        checklistByFramework[item.id] = tasks
        persist()
    }

    func completedCount(for item: FrameworkItem) -> Int {
        checklistByFramework[item.id, default: []].count
    }

    private func load() {
        let decoder = JSONDecoder()
        if let statusData = UserDefaults.standard.data(forKey: statusKey),
           let decodedStatus = try? decoder.decode([String: LearningStatus].self, from: statusData) {
            statusByFramework = decodedStatus
        }

        if let checklistData = UserDefaults.standard.data(forKey: checklistKey),
           let decodedChecklist = try? decoder.decode([String: Set<String>].self, from: checklistData) {
            checklistByFramework = decodedChecklist
        }
    }

    private func persist() {
        let encoder = JSONEncoder()
        if let statusData = try? encoder.encode(statusByFramework) {
            UserDefaults.standard.set(statusData, forKey: statusKey)
        }
        if let checklistData = try? encoder.encode(checklistByFramework) {
            UserDefaults.standard.set(checklistData, forKey: checklistKey)
        }
    }
}
