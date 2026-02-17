import SwiftUI

/// 가족 공유 취소 시 안내 뷰
struct FamilyShareRevokedView: View {
    @Environment(\.dismiss) private var dismiss
    var onSubscribe: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // 아이콘
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
            
            // 제목
            Text("가족 공유가 종료되었습니다")
                .font(.title2.bold())
            
            // 설명
            Text("더 이상 가족 구독을 통해 프리미엄 기능을 사용할 수 없습니다. 직접 구독하시면 모든 기능을 계속 이용할 수 있습니다.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // 액션 버튼들
            VStack(spacing: 12) {
                Button {
                    onSubscribe()
                    dismiss()
                } label: {
                    Text("지금 구독하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    dismiss()
                } label: {
                    Text("나중에")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            // 무료 기능 안내
            Text("무료 기능은 계속 사용할 수 있습니다")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .interactiveDismissDisabled()
    }
}

// MARK: - Preview
#Preview {
    FamilyShareRevokedView {
        print("Subscribe tapped")
    }
}
