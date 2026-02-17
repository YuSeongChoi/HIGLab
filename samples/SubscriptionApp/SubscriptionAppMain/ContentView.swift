import SwiftUI

// MARK: - 메인 콘텐츠 뷰
// 구독 상태에 따라 다른 UI를 표시합니다.

struct ContentView: View {
    
    // MARK: - 환경 객체
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    // MARK: - 상태
    
    /// 페이월 표시 여부
    @State private var showPaywall = false
    
    /// 구독 관리 시트 표시 여부
    @State private var showManageSubscription = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 구독 상태 카드
                    subscriptionStatusCard
                    
                    // 기능 목록
                    featuresSection
                }
                .padding()
            }
            .navigationTitle("구독 앱")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsMenu
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showManageSubscription) {
                ManageSubscriptionView()
            }
        }
    }
    
    // MARK: - 구독 상태 카드
    
    /// 현재 구독 상태를 보여주는 카드
    private var subscriptionStatusCard: some View {
        VStack(spacing: 16) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(statusGradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            // 상태 텍스트
            VStack(spacing: 4) {
                Text(entitlementManager.currentTier.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let subscription = subscriptionManager.activeSubscription {
                    Text(subscription.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("구독하고 더 많은 기능을 즐기세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // 액션 버튼
            if entitlementManager.isSubscribed {
                Button {
                    showManageSubscription = true
                } label: {
                    Text("구독 관리")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    Text("구독 시작하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    /// 상태에 따른 그라데이션
    private var statusGradient: LinearGradient {
        switch entitlementManager.currentTier {
        case .none:
            return LinearGradient(
                colors: [.gray, .gray.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .basic:
            return LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .premium:
            return LinearGradient(
                colors: [.purple, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    /// 상태에 따른 아이콘
    private var statusIcon: String {
        switch entitlementManager.currentTier {
        case .none:
            return "person.fill"
        case .basic:
            return "star.fill"
        case .premium:
            return "crown.fill"
        }
    }
    
    // MARK: - 기능 섹션
    
    /// 이용 가능한 기능 목록
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("기능")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(Feature.allCases) { feature in
                FeatureRow(feature: feature)
            }
        }
    }
    
    // MARK: - 설정 메뉴
    
    /// 네비게이션 바 설정 메뉴
    private var settingsMenu: some View {
        Menu {
            if entitlementManager.isSubscribed {
                Button {
                    showManageSubscription = true
                } label: {
                    Label("구독 관리", systemImage: "creditcard")
                }
            }
            
            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            } label: {
                Label("구매 복원", systemImage: "arrow.clockwise")
            }
            
            Divider()
            
            NavigationLink {
                SubscriptionStatusView()
            } label: {
                Label("구독 상태", systemImage: "info.circle")
            }
        } label: {
            Image(systemName: "gearshape")
        }
    }
}

// MARK: - 기능 행

/// 개별 기능을 표시하는 행
struct FeatureRow: View {
    let feature: Feature
    
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    /// 이 기능이 잠금 해제되었는지 여부
    private var isUnlocked: Bool {
        entitlementManager.hasAccess(to: feature)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 기능 아이콘
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: feature.icon)
                    .foregroundColor(isUnlocked ? .blue : .gray)
            }
            
            // 기능 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.rawValue)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 잠금 상태 표시
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                    Text(feature.requiredTier.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - 프리뷰

#Preview("구독 없음") {
    ContentView()
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(EntitlementManager.shared)
}
