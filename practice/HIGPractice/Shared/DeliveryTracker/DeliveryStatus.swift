import SwiftUI

// 이 파일은 앱/위젯 공통으로 사용하는 배달 상태와 상태별 표시 속성을 정의합니다.
enum DeliveryStatus: String, Equatable, Codable, CaseIterable {
    case preparing
    case pickedUp
    case nearby
    case delivered

    var displayName: String {
        switch self {
        case .preparing: "준비 중"
        case .pickedUp:  "픽업 완료"
        case .nearby:    "거의 도착"
        case .delivered: "완료"
        }
    }

    var symbolName: String {
        switch self {
        case .preparing: "bag.fill"
        case .pickedUp:  "bicycle"
        case .nearby:    "location.fill"
        case .delivered: "checkmark.circle.fill"
        }
    }

    // 앱 학습 화면과의 호환을 위해 별칭을 유지합니다.
    var title: String { displayName }
    var icon: String { symbolName }

    var color: Color {
        switch self {
        case .preparing: .orange
        case .pickedUp:  .blue
        case .nearby:    .green
        case .delivered: .green
        }
    }
}
