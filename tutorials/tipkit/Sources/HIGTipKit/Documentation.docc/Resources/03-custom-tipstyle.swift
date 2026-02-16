import SwiftUI
import TipKit

// MARK: - 커스텀 TipViewStyle
// 팁의 전체 레이아웃을 완전히 재정의합니다.

struct CustomTipStyle: TipViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // 커스텀 아이콘 영역
            configuration.image?
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.blue.gradient)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                // 제목
                configuration.title
                    .font(.headline)
                
                // 메시지
                configuration.message?
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // 액션 버튼들
                if !configuration.actions.isEmpty {
                    HStack(spacing: 12) {
                        ForEach(configuration.actions) { action in
                            Button(action.title) {
                                action.handler()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
