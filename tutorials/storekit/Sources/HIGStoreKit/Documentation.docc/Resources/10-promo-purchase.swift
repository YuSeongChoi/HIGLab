import StoreKit
import SwiftUI

/// Promotional Offer로 구매 진행
@MainActor
class PromoPurchaseManager: ObservableObject {
    @Published var purchaseState: PurchaseState = .ready
    
    private let signatureService: OfferSignatureService
    private let userId: String
    
    init(signatureService: OfferSignatureService, userId: String) {
        self.signatureService = signatureService
        self.userId = userId
    }
    
    /// Promotional Offer 구매 실행
    func purchaseWithPromoOffer(
        product: Product,
        offerId: String
    ) async throws -> Transaction? {
        purchaseState = .purchasing
        
        do {
            // 1. 서버에서 서명 획득
            let signature = try await signatureService.requestSignature(
                productId: product.id,
                offerId: offerId,
                userId: userId
            )
            
            // 2. PurchaseOption 구성
            let options: Set<Product.PurchaseOption> = [
                .promotionalOffer(
                    offerID: offerId,
                    keyID: signature.keyId,
                    nonce: signature.nonce,
                    signature: Data(base64Encoded: signature.signature)!,
                    timestamp: signature.timestamp
                ),
                .appAccountToken(UUID(uuidString: userId) ?? UUID())
            ]
            
            // 3. 구매 요청
            let result = try await product.purchase(options: options)
            
            switch result {
            case .success(let verification):
                // 영수증 검증
                switch verification {
                case .verified(let transaction):
                    // 구매 완료 처리
                    await transaction.finish()
                    purchaseState = .purchased
                    print("✅ 프로모션 구매 완료: \(product.displayName)")
                    return transaction
                    
                case .unverified(let transaction, let error):
                    print("⚠️ 검증 실패: \(error)")
                    purchaseState = .failed(error)
                    return nil
                }
                
            case .pending:
                purchaseState = .pending
                print("⏳ 구매 대기 중 (Ask to Buy 등)")
                return nil
                
            case .userCancelled:
                purchaseState = .ready
                print("🚫 사용자 취소")
                return nil
                
            @unknown default:
                purchaseState = .ready
                return nil
            }
            
        } catch {
            purchaseState = .failed(error)
            print("❌ 구매 실패: \(error)")
            throw error
        }
    }
}

enum PurchaseState: Equatable {
    case ready
    case purchasing
    case pending
    case purchased
    case failed(Error)
    
    static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready), (.purchasing, .purchasing),
             (.pending, .pending), (.purchased, .purchased):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}

// MARK: - Promotional Offer 구매 UI

struct PromoOfferPurchaseView: View {
    let product: Product
    let offer: PromoOfferInfo
    @ObservedObject var purchaseManager: PromoPurchaseManager
    
    var body: some View {
        VStack(spacing: 20) {
            // 오퍼 정보
            VStack(spacing: 8) {
                Text("🎉 특별 할인 오퍼")
                    .font(.headline)
                
                Text(offer.description)
                    .font(.title.bold())
                    .foregroundStyle(.green)
                
                Text("정상가 \(product.displayPrice)")
                    .font(.subheadline)
                    .strikethrough()
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // 구매 버튼
            Button {
                Task {
                    try await purchaseManager.purchaseWithPromoOffer(
                        product: product,
                        offerId: offer.id
                    )
                }
            } label: {
                HStack {
                    if purchaseManager.purchaseState == .purchasing {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(buttonTitle)
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonBackground)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(purchaseManager.purchaseState == .purchasing)
            
            // 상태 메시지
            statusMessage
        }
        .padding()
    }
    
    private var buttonTitle: String {
        switch purchaseManager.purchaseState {
        case .purchasing: return "처리 중..."
        case .purchased: return "구매 완료!"
        default: return "\(offer.displayPrice)에 구독하기"
        }
    }
    
    private var buttonBackground: Color {
        switch purchaseManager.purchaseState {
        case .purchased: return .green
        case .failed: return .red
        default: return .accentColor
        }
    }
    
    @ViewBuilder
    private var statusMessage: some View {
        switch purchaseManager.purchaseState {
        case .pending:
            Label("승인 대기 중", systemImage: "clock")
                .foregroundStyle(.orange)
        case .failed(let error):
            Label(error.localizedDescription, systemImage: "xmark.circle")
                .foregroundStyle(.red)
        default:
            EmptyView()
        }
    }
}
