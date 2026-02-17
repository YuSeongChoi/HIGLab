import SwiftUI
import StoreKit

/// 업그레이드 확인 다이얼로그
struct UpgradeConfirmView: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 플랜 정보
                VStack(spacing: 8) {
                    Text(product.displayName)
                        .font(.title2.bold())
                    Text(product.displayPrice)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                // 변경 타입 안내
                changeTypeInfo
                
                // 구매 버튼
                Button {
                    Task { await purchase() }
                } label: {
                    if isPurchasing {
                        ProgressView()
                    } else {
                        Text(isUpgrade ? "업그레이드" : "변경")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isPurchasing)
                
                // 안내 문구
                Text("변경 시 Apple ID 결제가 진행됩니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("플랜 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }
    
    private var isUpgrade: Bool {
        guard let currentLevel = subscriptionManager.currentServiceLevel else { return true }
        let newLevel = subscriptionManager.serviceLevel(for: product.id)
        return newLevel > currentLevel
    }
    
    private var changeTypeInfo: some View {
        Group {
            if isUpgrade {
                Label("업그레이드는 즉시 적용됩니다", systemImage: "arrow.up.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Label("다운그레이드는 다음 갱신일에 적용됩니다", systemImage: "calendar")
                    .foregroundStyle(.orange)
            }
        }
        .font(.subheadline)
    }
    
    private func purchase() async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    dismiss()
                }
            case .pending, .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            print("Purchase error: \(error)")
        }
    }
}
