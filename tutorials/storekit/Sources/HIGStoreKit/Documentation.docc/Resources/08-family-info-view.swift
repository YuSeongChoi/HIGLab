import SwiftUI
import StoreKit

/// 가족 공유 사용자를 위한 정보 뷰
struct FamilyShareInfoView: View {
    @EnvironmentObject var familyManager: FamilyShareManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    var body: some View {
        VStack(spacing: 20) {
            // 가족 공유 배지
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("가족 공유 멤버")
                .font(.title2.bold())
            
            Text("가족 구성원의 구독을 통해 프리미엄 기능을 사용하고 있습니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Divider()
            
            // 사용 가능한 기능
            VStack(alignment: .leading, spacing: 12) {
                Label("모든 프리미엄 콘텐츠", systemImage: "checkmark.circle.fill")
                Label("광고 제거", systemImage: "checkmark.circle.fill")
                Label("오프라인 저장", systemImage: "checkmark.circle.fill")
            }
            .foregroundStyle(.green)
            
            Divider()
            
            // 제한 사항 안내
            VStack(alignment: .leading, spacing: 8) {
                Text("알아두세요")
                    .font(.headline)
                
                Text("• 구독 관리는 원래 구매자만 가능합니다")
                Text("• 가족 그룹에서 나가면 접근이 종료됩니다")
                Text("• 구독 취소 시 모든 가족 구성원 접근이 종료됩니다")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            Spacer()
            
            // 직접 구독 유도 (선택)
            Button {
                // 직접 구독 화면으로 이동
            } label: {
                Text("나만의 구독 시작하기")
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
