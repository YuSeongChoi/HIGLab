import SwiftUI

// MARK: - Minimal View
// 다른 Live Activity와 함께 표시될 때
// 우측의 작은 원형 영역만 사용

struct DeliveryMinimalView: View {
    let status: DeliveryStatus
    
    var body: some View {
        // 작은 원형 영역이므로 아이콘만 표시
        ZStack {
            // 배경 (선택적)
            Circle()
                .fill(status.color.opacity(0.2))
            
            // 아이콘
            Image(systemName: status.symbolName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(status.color)
        }
    }
}

// HIG 팁: Minimal에서는 가장 핵심적인 상태만 표시
// 텍스트는 읽기 어려우므로 아이콘 사용 권장
