import SwiftUI

// MARK: - ContentView
/// 메인 콘텐츠 뷰
/// 사용자의 프리미엄 상태에 따라 다른 UI를 표시합니다.

struct ContentView: View {
    // MARK: - 환경 및 상태
    
    /// StoreManager
    @Environment(StoreManager.self) private var storeManager
    
    /// 선택된 탭
    @State private var selectedTab = 0
    
    // MARK: - 뷰 본문
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: 홈 탭
            homeTab
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(0)
            
            // MARK: 스토어 탭
            StoreView()
                .tabItem {
                    Label("스토어", systemImage: "bag.fill")
                }
                .tag(1)
            
            // MARK: 구독 탭
            SubscriptionView()
                .tabItem {
                    Label("구독", systemImage: "crown.fill")
                }
                .tag(2)
            
            // MARK: 내역 탭
            PurchaseHistoryView()
                .tabItem {
                    Label("내역", systemImage: "clock.fill")
                }
                .tag(3)
        }
    }
    
    // MARK: - 홈 탭 콘텐츠
    
    private var homeTab: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 상태 카드
                    statusCard
                    
                    // 기능 목록
                    featuresSection
                    
                    #if DEBUG
                    // 디버그 섹션
                    debugSection
                    #endif
                }
                .padding()
            }
            .navigationTitle("PremiumApp")
        }
    }
    
    // MARK: - 상태 카드
    
    private var statusCard: some View {
        VStack(spacing: 16) {
            // 프리미엄 상태 표시
            Image(systemName: storeManager.isPremium ? "crown.fill" : "person.fill")
                .font(.system(size: 50))
                .foregroundStyle(storeManager.isPremium ? .yellow : .gray)
            
            Text(storeManager.isPremium ? "프리미엄 회원" : "무료 회원")
                .font(.title2)
                .fontWeight(.bold)
            
            if storeManager.isPremium {
                // 프리미엄 상태 상세
                if storeManager.subscriptionStatus.isEntitled,
                   let expirationDate = storeManager.subscriptionExpirationDate {
                    Text("구독 만료: \(expirationDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                // 업그레이드 유도
                Button {
                    selectedTab = 1 // 스토어 탭으로 이동
                } label: {
                    Text("프리미엄으로 업그레이드")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - 기능 섹션
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("기능")
                .font(.headline)
            
            // 무료 기능
            FeatureRow(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                title: "기본 기능",
                description: "모든 사용자가 이용 가능",
                isLocked: false
            )
            
            // 프리미엄 기능
            FeatureRow(
                icon: storeManager.isPremium ? "checkmark.circle.fill" : "lock.fill",
                iconColor: storeManager.isPremium ? .green : .orange,
                title: "프리미엄 기능",
                description: "광고 제거, 고급 테마",
                isLocked: !storeManager.isPremium
            )
            
            FeatureRow(
                icon: storeManager.isPremium ? "checkmark.circle.fill" : "lock.fill",
                iconColor: storeManager.isPremium ? .green : .orange,
                title: "프로 기능",
                description: "클라우드 동기화, 무제한 저장",
                isLocked: !storeManager.isPremium
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - 디버그 섹션
    
    #if DEBUG
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🛠 디버그")
                .font(.headline)
            
            Button("프리미엄 상태 토글") {
                storeManager.togglePremiumForTesting()
            }
            .buttonStyle(.bordered)
            
            Text("프리미엄: \(storeManager.isPremium ? "✅" : "❌")")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("구독 상태: \(storeManager.subscriptionStatus.description)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.yellow.opacity(0.1))
                .stroke(.yellow, lineWidth: 1)
        )
    }
    #endif
}

// MARK: - FeatureRow
/// 기능 항목을 표시하는 행

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isLocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isLocked {
                Text("프리미엄")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.orange.opacity(0.15))
                    )
            }
        }
    }
}

// MARK: - 프리뷰

#Preview("무료 회원") {
    ContentView()
        .environment(StoreManager.shared)
}
