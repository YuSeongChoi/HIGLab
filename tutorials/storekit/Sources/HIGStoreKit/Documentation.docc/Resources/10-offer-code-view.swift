import SwiftUI
import StoreKit

/// 오퍼 코드 입력 UI
struct OfferCodeView: View {
    @State private var showingRedeemSheet = false
    @State private var redeemStatus: RedeemStatus = .idle
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // 헤더
            VStack(spacing: 12) {
                Image(systemName: "ticket")
                    .font(.system(size: 60))
                    .foregroundStyle(.accent)
                
                Text("오퍼 코드 사용")
                    .font(.title.bold())
                
                Text("프로모션 코드가 있으신가요?\n코드를 입력하여 특별 혜택을 받으세요.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // 코드 입력 버튼
            Button {
                showingRedeemSheet = true
            } label: {
                Label("코드 입력하기", systemImage: "barcode")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // 코드 수령 방법 안내
            VStack(alignment: .leading, spacing: 12) {
                Text("코드를 받는 방법")
                    .font(.headline)
                
                CodeSourceRow(
                    icon: "envelope",
                    title: "이메일",
                    description: "뉴스레터 구독자 전용 코드"
                )
                
                CodeSourceRow(
                    icon: "person.2",
                    title: "친구 추천",
                    description: "친구에게 받은 추천 코드"
                )
                
                CodeSourceRow(
                    icon: "megaphone",
                    title: "프로모션",
                    description: "이벤트 참여 보상 코드"
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // 상태 메시지
            statusView
        }
        .padding()
        .offerCodeRedemption(isPresented: $showingRedeemSheet) { result in
            handleRedemptionResult(result)
        }
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch redeemStatus {
        case .idle:
            EmptyView()
        case .success:
            Label("코드가 적용되었습니다!", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .padding()
        case .error(let message):
            Label(message, systemImage: "xmark.circle.fill")
                .foregroundStyle(.red)
                .padding()
        }
    }
    
    private func handleRedemptionResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            redeemStatus = .success
            // 성공 후 자동으로 닫기
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        case .failure(let error):
            if let storeError = error as? StoreKit.StoreKitError {
                switch storeError {
                case .userCancelled:
                    redeemStatus = .idle
                default:
                    redeemStatus = .error("코드를 적용할 수 없습니다.")
                }
            } else {
                redeemStatus = .error(error.localizedDescription)
            }
        }
    }
}

enum RedeemStatus {
    case idle
    case success
    case error(String)
}

struct CodeSourceRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.accent)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OfferCodeView()
}
