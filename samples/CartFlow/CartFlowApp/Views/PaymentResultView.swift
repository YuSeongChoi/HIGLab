import SwiftUI
import PassKit

// MARK: - 결제 결과 화면
/// Apple Pay 결제 완료 후 결과를 표시하는 화면
///
/// ## 주요 기능
/// - 결제 성공/실패 상태 표시
/// - 주문 정보 요약
/// - 배송 정보 표시
/// - 영수증 공유 기능
///
/// ## 사용 예시
/// ```swift
/// PaymentResultView(result: paymentResult) {
///     // 완료 후 처리
///     cartStore.clearCart()
/// }
/// ```

struct PaymentResultView: View {
    
    // MARK: - 속성
    
    /// 결제 결과
    let result: PaymentResult
    
    /// 완료 액션
    let onComplete: () -> Void
    
    // MARK: - 환경
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 상태
    
    /// 애니메이션 상태
    @State private var showContent = false
    
    /// 공유 시트 표시
    @State private var showShareSheet = false
    
    /// 복사 완료 토스트
    @State private var showCopiedToast = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // 결과 헤더
                    resultHeader
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)
                    
                    // 주문 정보
                    orderInfoSection
                        .offset(y: showContent ? 0 : 20)
                        .opacity(showContent ? 1 : 0)
                    
                    // 배송 정보
                    if result.shippingContact != nil || result.shippingMethod != nil {
                        shippingInfoSection
                            .offset(y: showContent ? 0 : 20)
                            .opacity(showContent ? 1 : 0)
                    }
                    
                    // 결제 정보
                    paymentInfoSection
                        .offset(y: showContent ? 0 : 20)
                        .opacity(showContent ? 1 : 0)
                    
                    // 주문 항목
                    orderItemsSection
                        .offset(y: showContent ? 0 : 20)
                        .opacity(showContent ? 1 : 0)
                }
                .padding()
            }
            .navigationTitle("결제 완료")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        onComplete()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if showCopiedToast {
                    copiedToast
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [receiptText])
        }
    }
    
    // MARK: - 결과 헤더
    
    private var resultHeader: some View {
        VStack(spacing: 16) {
            // 성공/실패 아이콘
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 50))
                    .foregroundStyle(statusColor)
            }
            .accessibilityHidden(true)
            
            // 상태 텍스트
            Text(statusTitle)
                .font(.title.bold())
            
            Text(statusDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(statusTitle). \(statusDescription)")
    }
    
    private var statusColor: Color {
        switch result.status {
        case .success:
            return .green
        case .pending:
            return .orange
        case .failed:
            return .red
        case .refunded:
            return .blue
        }
    }
    
    private var statusIcon: String {
        switch result.status {
        case .success:
            return "checkmark.circle.fill"
        case .pending:
            return "clock.fill"
        case .failed:
            return "xmark.circle.fill"
        case .refunded:
            return "arrow.uturn.left.circle.fill"
        }
    }
    
    private var statusTitle: String {
        switch result.status {
        case .success:
            return "결제 완료"
        case .pending:
            return "처리 중"
        case .failed:
            return "결제 실패"
        case .refunded:
            return "환불 완료"
        }
    }
    
    private var statusDescription: String {
        switch result.status {
        case .success:
            return "주문이 성공적으로 완료되었습니다."
        case .pending:
            return "결제가 처리 중입니다. 잠시만 기다려주세요."
        case .failed:
            return "결제에 실패했습니다. 다시 시도해주세요."
        case .refunded:
            return "결제가 환불되었습니다."
        }
    }
    
    // MARK: - 주문 정보 섹션
    
    private var orderInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "주문 정보", icon: "doc.text")
            
            InfoRow(label: "주문 번호", value: String(result.transactionId.prefix(16)))
            InfoRow(label: "결제 일시", value: result.formattedDate)
            InfoRow(label: "결제 금액", value: result.formattedAmount, isHighlighted: true)
        }
        .infoSectionStyle()
    }
    
    // MARK: - 배송 정보 섹션
    
    private var shippingInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "배송 정보", icon: "shippingbox")
            
            if let method = result.shippingMethod {
                InfoRow(label: "배송 방법", value: method.name)
                InfoRow(label: "예상 배송일", value: method.formattedDeliveryDate())
            }
            
            if let contact = result.shippingContact {
                if let name = contact.name {
                    let fullName = [name.familyName, name.givenName]
                        .compactMap { $0 }
                        .joined(separator: "")
                    InfoRow(label: "받는 분", value: fullName)
                }
                
                if let address = contact.postalAddress {
                    let fullAddress = [
                        address.state,
                        address.city,
                        address.street,
                        address.subLocality
                    ]
                    .compactMap { $0.isEmpty ? nil : $0 }
                    .joined(separator: " ")
                    
                    InfoRow(label: "배송 주소", value: fullAddress)
                }
                
                if let phone = contact.phoneNumber?.stringValue {
                    InfoRow(label: "연락처", value: phone)
                }
            }
        }
        .infoSectionStyle()
    }
    
    // MARK: - 결제 정보 섹션
    
    private var paymentInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "결제 정보", icon: "creditcard")
            
            HStack(spacing: 12) {
                // 카드 네트워크 아이콘
                Image(systemName: cardNetworkIcon)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.paymentNetwork)
                        .font(.subheadline.weight(.medium))
                    
                    Text(result.cardType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "applelogo")
                    .font(.title3)
                Text("Pay")
                    .font(.headline)
            }
            .padding(12)
            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 8))
        }
        .infoSectionStyle()
    }
    
    private var cardNetworkIcon: String {
        switch result.paymentNetwork.lowercased() {
        case "visa":
            return "creditcard"
        case "mastercard":
            return "creditcard.fill"
        case "amex", "american express":
            return "creditcard.trianglebadge.exclamationmark"
        default:
            return "creditcard"
        }
    }
    
    // MARK: - 주문 항목 섹션
    
    private var orderItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "주문 항목", icon: "bag")
            
            ForEach(result.orderItems, id: \.productId) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.productName)
                            .font(.subheadline)
                        
                        Text("수량: \(item.quantity)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("₩\(item.totalPrice.formatted())")
                        .font(.subheadline)
                }
                
                if item.productId != result.orderItems.last?.productId {
                    Divider()
                }
            }
        }
        .infoSectionStyle()
    }
    
    // MARK: - 복사 완료 토스트
    
    private var copiedToast: some View {
        Text("주문 번호가 복사되었습니다")
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.1), radius: 10)
            .padding(.bottom, 16)
    }
    
    // MARK: - 영수증 텍스트
    
    private var receiptText: String {
        var text = """
        [CartFlow 주문 영수증]
        
        주문 번호: \(result.transactionId)
        결제 일시: \(result.formattedDate)
        결제 금액: \(result.formattedAmount)
        결제 방법: Apple Pay (\(result.paymentNetwork))
        
        [주문 항목]
        """
        
        for item in result.orderItems {
            text += "\n• \(item.productName) x \(item.quantity): ₩\(item.totalPrice.formatted())"
        }
        
        if let method = result.shippingMethod {
            text += "\n\n[배송 정보]\n배송 방법: \(method.name)"
            text += "\n예상 배송일: \(method.formattedDeliveryDate())"
        }
        
        text += "\n\n감사합니다!"
        
        return text
    }
    
    // MARK: - 복사 기능
    
    private func copyOrderNumber() {
        UIPasteboard.general.string = result.transactionId
        
        withAnimation {
            showCopiedToast = true
        }
        
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                showCopiedToast = false
            }
        }
    }
}

// MARK: - 보조 뷰

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(isHighlighted ? .primary : .secondary)
                .fontWeight(isHighlighted ? .semibold : .regular)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - 섹션 스타일 Modifier

extension View {
    func infoSectionStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 공유 시트

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview("Success") {
    PaymentResultView(
        result: PaymentResult(
            transactionId: "TXN-2024-0217-ABC123DEF456",
            status: .success,
            amount: 425000,
            currency: "KRW",
            paymentNetwork: "Visa",
            cardType: "Credit",
            shippingContact: nil,
            billingContact: nil,
            shippingMethod: .express,
            timestamp: Date(),
            orderItems: [
                OrderItem(from: CartItem(product: Product.samples[0], quantity: 1)),
                OrderItem(from: CartItem(product: Product.samples[3], quantity: 2))
            ]
        ),
        onComplete: {}
    )
}

#Preview("Pending") {
    PaymentResultView(
        result: PaymentResult(
            transactionId: "TXN-2024-0217-PENDING",
            status: .pending,
            amount: 99000,
            currency: "KRW",
            paymentNetwork: "Mastercard",
            cardType: "Debit",
            shippingContact: nil,
            billingContact: nil,
            shippingMethod: .standardPaid,
            timestamp: Date(),
            orderItems: [
                OrderItem(from: CartItem(product: Product.samples[1], quantity: 1))
            ]
        ),
        onComplete: {}
    )
}
