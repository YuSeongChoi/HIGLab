import Foundation

enum FrameworkPhase: String, CaseIterable, Hashable, Identifiable {
    case appFrameworks
    case appServices
    case graphicsAndMedia
    case systemAndNetwork
    case ios26

    var id: String { rawValue }

    var title: String {
        switch self {
        case .appFrameworks:
            return "Phase 1: App Frameworks"
        case .appServices:
            return "Phase 2: App Services"
        case .graphicsAndMedia:
            return "Phase 3: Graphics & Media"
        case .systemAndNetwork:
            return "Phase 4: System & Network"
        case .ios26:
            return "Phase 5: iOS 26"
        }
    }

    var subtitle: String {
        switch self {
        case .appFrameworks:
            return "UI, state, and app architecture foundations"
        case .appServices:
            return "Platform services and app capabilities"
        case .graphicsAndMedia:
            return "Rendering, camera, audio, and immersive experiences"
        case .systemAndNetwork:
            return "Device connectivity and network-level features"
        case .ios26:
            return "Latest platform frameworks and intelligent features"
        }
    }
}
