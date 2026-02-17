import SwiftUI
import TipKit

/// 인라인 팁 예제 화면
/// TipView를 사용하여 화면에 직접 팁을 삽입하는 방법을 보여줍니다.
struct InlineTipView: View {
    // 팁 인스턴스 생성
    private let favoriteTip = FavoriteTip()
    private let actionTip = ActionTip()
    
    @State private var isFavorite = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - 기본 인라인 팁
                    sectionHeader("기본 인라인 팁")
                    
                    // TipView: 팁을 화면에 직접 표시
                    // 사용자가 팁을 닫으면 자동으로 사라집니다.
                    TipView(favoriteTip)
                        .tipBackground(.blue.opacity(0.1))
                    
                    // 팁과 연관된 버튼
                    Button {
                        isFavorite.toggle()
                        // 팁을 프로그래매틱하게 무효화 (닫기)
                        favoriteTip.invalidate(reason: .actionPerformed)
                    } label: {
                        Label(
                            isFavorite ? "즐겨찾기됨" : "즐겨찾기",
                            systemImage: isFavorite ? "heart.fill" : "heart"
                        )
                        .font(.headline)
                        .foregroundStyle(isFavorite ? .red : .primary)
                    }
                    .buttonStyle(.bordered)
                    
                    Divider()
                        .padding(.vertical)
                    
                    // MARK: - 액션이 있는 팁
                    sectionHeader("액션 버튼 팁")
                    
                    // 액션 버튼이 포함된 팁
                    // 사용자가 액션을 선택하면 해당 액션을 처리할 수 있습니다.
                    TipView(actionTip) { action in
                        // 액션 ID에 따라 다른 동작 수행
                        switch action.id {
                        case "learn-more":
                            print("📚 자세히 보기 선택됨")
                        case "dismiss":
                            print("❌ 닫기 선택됨")
                        default:
                            break
                        }
                    }
                    .tipBackground(.orange.opacity(0.1))
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("인라인 팁")
        }
    }
    
    /// 섹션 헤더 뷰
    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

#Preview {
    InlineTipView()
        .task {
            // 프리뷰에서 팁을 표시하기 위한 설정
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}
