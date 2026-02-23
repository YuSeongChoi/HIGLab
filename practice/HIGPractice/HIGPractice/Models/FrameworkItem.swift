import Foundation
import SwiftUI

enum FrameworkTint: String, Hashable {
    case sky
    case indigo
    case mint
    case orange
    case pink
    case teal
    case cyan

    var gradient: LinearGradient {
        switch self {
        case .sky:
            return LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .indigo:
            return LinearGradient(colors: [Color.indigo, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .mint:
            return LinearGradient(colors: [Color.mint, Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .orange:
            return LinearGradient(colors: [Color.orange, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .pink:
            return LinearGradient(colors: [Color.pink, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .teal:
            return LinearGradient(colors: [Color.teal, Color.green], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cyan:
            return LinearGradient(colors: [Color.cyan, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

enum FrameworkResourceKind: String, CaseIterable, Hashable, Identifiable {
    case docs
    case blog
    case sample
    case ai

    var id: String { rawValue }

    var title: String {
        switch self {
        case .docs: return "문서"
        case .blog: return "블로그"
        case .sample: return "샘플"
        case .ai: return "AI"
        }
    }

    var systemImage: String {
        switch self {
        case .docs: return "book"
        case .blog: return "newspaper"
        case .sample: return "hammer"
        case .ai: return "sparkles"
        }
    }
}

struct FrameworkResourceLink: Hashable, Identifiable {
    let kind: FrameworkResourceKind
    let url: URL?

    var id: FrameworkResourceKind { kind }
}

struct FrameworkItem: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let phase: FrameworkPhase
    let symbolName: String
    let tint: FrameworkTint
    let isCompleted: Bool

    let localSitePath: String
    let localTutorialPath: String
    let localSamplePath: String?

    let links: [FrameworkResourceLink]
}
