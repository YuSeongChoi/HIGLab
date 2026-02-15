import SwiftUI

// MARK: - Compact Leading View
// Dynamic Island 좌측 영역

struct CompactLeadingView: View {
    let status: DeliveryStatus
    
    var body: some View {
        Image(systemName: status.symbolName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(status.color)
    }
}

// 사용 예시 (DynamicIsland 내부)
/*
 DynamicIsland {
     ...
 } compactLeading: {
     CompactLeadingView(status: context.state.status)
 }
*/
