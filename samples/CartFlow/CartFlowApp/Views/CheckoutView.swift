import SwiftUI
import PassKit

// MARK: - 결제 화면
/// 장바구니에서 결제로 진행하는 체크아웃 화면
///
/// ## 주요 기능
/// - 주문 요약 표시
/// - 배송 방법 선택
/// - 쿠폰 코드 입력
/// - Apple Pay 결제 버튼
/// - 결제 결과 표시
///
/// ## 사용 예시
/// ```swift
/// CheckoutView(cartStore: cartStore)
/// ```

struct CheckoutView: View {
    
    // MARK: - 의존성
    
    /// 장바구니 상태
    @Bindable var cartStore: CartStore
    
    /// Apple Pay 서비스
    @State private var paymentService = ApplePayService()
    
    // MARK: - 상태
    
    /// 선택된 배송 방법
    @State private var selectedShipping: ShippingMethod = .standardPaid
    
    /// 쿠폰 코드 입력
    @State private var couponCode = ""
    
    /// 적용된 쿠폰 할인 금액
    @State private var couponDiscount: Int = 0
    
    /// 쿠폰 적용 중 여부
    @State private var isApplyingCoupon = false
    
    /// 쿠폰 에러 메시지
    @State private var couponError: String?
    
    /// 결제 결과 표시 여부
    @State private var showPaymentResult = false
    
    /// 결제 결과
    @State private var paymentResult: PaymentResult?
    
    /// 에러 알림 표시 여부
    @State private var showError = false
    
    /// 에러 메시지
    @State private var errorMessage = ""
    
    /// 주문 요약 섹션 접힘 상태
    @State private var isOrderSummaryExpanded = true
    
    // MARK: - 계산 속성
    
    /// 상품 소계
    private var subtotal: Int {
        cartStore.totalPrice
    }
    
    /// 배송비
    private var shippingCost: Int {
        selectedShipping.calculatePrice(for: subtotal)
    }
    
    /// 최종 결제 금액
    private var totalAmount: Int {
        max(0, subtotal + shippingCost - couponDiscount)
    }
    
    /// 포맷팅된 총액
    private var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: totalAmount)) ?? "\(totalAmount)"
        return "₩\(formatted)"
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 주문 요약
                orderSummarySection
                
                // 배송 방법 선택
                shippingMethodSection
                
                // 쿠폰 코드
                couponSection
                
                // 금액 상세
                priceBreakdownSection
                
                Divider()
                
                // Apple Pay 버튼
                paymentSection
                
                // 결제 안내
                paymentInfoSection
            }
            .padding()
        }
        .navigationTitle("결제")
        .navigationBarTitleDisplayMode(.inline)
        .alert("결제 오류", isPresented: $showError) {
            Button("확인", role: .cancel) {}
            
            if paymentService.lastError?.isRetryable == true {
                Button("다시 시도") {
                    Task { await processPayment() }
                }
            }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showPaymentResult) {
            if let result = paymentResult {
                PaymentResultView(result: result) {
                    cartStore.clearCart()
                    showPaymentResult = false
                }
            }
        }
    }
    
    // MARK: - 주문 요약 섹션
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isOrderSummaryExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("주문 상품", systemImage: "bag")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(cartStore.totalItemCount)개")
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isOrderSummaryExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("주문 상품 \(cartStore.totalItemCount)개")
            .accessibilityHint("탭하여 \(isOrderSummaryExpanded ? "접기" : "펼치기")")
            
            if isOrderSummaryExpanded {
                ForEach(cartStore.items) { item in
                    OrderItemRow(item: item)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 배송 방법 섹션
    
    private var shippingMethodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("배송 방법", systemImage: "shippingbox")
                .font(.headline)
            
            ForEach(ShippingMethod.defaultMethods, id: \.id) { method in
                ShippingMethodRow(
                    method: method,
                    isSelected: selectedShipping.id == method.id,
                    orderAmount: subtotal
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedShipping = method
                    }
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 쿠폰 섹션
    
    private var couponSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("쿠폰 코드", systemImage: "ticket")
                .font(.headline)
            
            HStack(spacing: 12) {
                TextField("쿠폰 코드 입력", text: $couponCode)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit {
                        Task { await applyCoupon() }
                    }
                    .accessibilityLabel("쿠폰 코드 입력")
                    .accessibilityHint("쿠폰 코드를 입력하고 적용 버튼을 눌러주세요")
                
                Button {
                    Task { await applyCoupon() }
                } label: {
                    if isApplyingCoupon {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("적용")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(couponCode.isEmpty || isApplyingCoupon)
            }
            
            // 쿠폰 적용 결과
            if couponDiscount > 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    
                    Text("쿠폰 적용됨: -₩\(couponDiscount.formatted())")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                    
                    Spacer()
                    
                    Button {
                        couponCode = ""
                        couponDiscount = 0
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("쿠폰 제거")
                }
            }
            
            // 쿠폰 에러
            if let error = couponError {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                    
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            }
            
            // 쿠폰 힌트
            Text("테스트 쿠폰: SAVE10, SAVE20, WELCOME, FREESHIP")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 금액 상세 섹션
    
    private var priceBreakdownSection: some View {
        VStack(spacing: 12) {
            // 상품 소계
            PriceRow(label: "상품 금액", amount: subtotal)
            
            // 배송비
            PriceRow(
                label: selectedShipping.name,
                amount: shippingCost,
                detail: shippingCost == 0 ? "무료" : nil
            )
            
            // 쿠폰 할인
            if couponDiscount > 0 {
                PriceRow(
                    label: "쿠폰 할인",
                    amount: -couponDiscount,
                    isDiscount: true
                )
            }
            
            Divider()
            
            // 총액
            HStack {
                Text("총 결제 금액")
                    .font(.headline)
                
                Spacer()
                
                Text(formattedTotal)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("총 결제 금액 \(formattedTotal)")
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 결제 섹션
    
    private var paymentSection: some View {
        VStack(spacing: 16) {
            // 결제 진행 상태 (처리 중일 때만)
            if paymentService.paymentState.isInProgress {
                PaymentProgressView(state: paymentService.paymentState)
            }
            
            // Apple Pay 버튼
            ConditionalApplePayButton(
                paymentService: paymentService,
                height: 50,
                payAction: {
                    await processPayment()
                },
                setupAction: {
                    paymentService.presentAddCardSheet()
                }
            )
            .disabled(cartStore.isEmpty || paymentService.paymentState.isInProgress)
        }
    }
    
    // MARK: - 결제 안내 섹션
    
    private var paymentInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("결제 안내", systemImage: "info.circle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Text("• Apple Pay로 안전하게 결제할 수 있습니다.")
            Text("• Face ID 또는 Touch ID로 인증합니다.")
            Text("• 실제 카드 정보는 판매자에게 공유되지 않습니다.")
        }
        .font(.caption)
        .foregroundStyle(.tertiary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 액션
    
    /// 쿠폰 적용
    private func applyCoupon() async {
        guard !couponCode.isEmpty else { return }
        
        isApplyingCoupon = true
        couponError = nil
        
        // 쿠폰 검증 (Mock)
        try? await Task.sleep(for: .milliseconds(500))
        
        let normalizedCode = couponCode.uppercased().trimmingCharacters(in: .whitespaces)
        
        let validCoupons: [String: Int] = [
            "SAVE10": 10000,
            "SAVE20": 20000,
            "WELCOME": 5000,
            "FREESHIP": 3000
        ]
        
        if let discount = validCoupons[normalizedCode] {
            couponDiscount = discount
            couponError = nil
        } else if normalizedCode == "EXPIRED" {
            couponError = "만료된 쿠폰입니다"
            couponDiscount = 0
        } else {
            couponError = "유효하지 않은 쿠폰 코드입니다"
            couponDiscount = 0
        }
        
        isApplyingCoupon = false
    }
    
    /// 결제 처리
    private func processPayment() async {
        do {
            let result = try await paymentService.processPayment(
                for: cartStore.items,
                shippingMethod: selectedShipping
            )
            
            paymentResult = result
            showPaymentResult = true
            
        } catch let error as PaymentError {
            switch error {
            case .userCancelled:
                // 사용자 취소는 에러로 처리하지 않음
                break
            default:
                errorMessage = error.localizedDescription
                showError = true
            }
            
            paymentService.resetPayment()
            
        } catch {
            errorMessage = "알 수 없는 오류가 발생했습니다."
            showError = true
            paymentService.resetPayment()
        }
    }
}

// MARK: - 주문 상품 행

struct OrderItemRow: View {
    let item: CartItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 상품 이미지 플레이스홀더
            RoundedRectangle(cornerRadius: 8)
                .fill(.fill.quaternary)
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: item.product.category.symbol)
                        .foregroundStyle(.secondary)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                
                Text("수량: \(item.quantity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(item.formattedTotalPrice)
                .font(.subheadline.weight(.medium))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.product.name), 수량 \(item.quantity), \(item.formattedTotalPrice)")
    }
}

// MARK: - 배송 방법 행

struct ShippingMethodRow: View {
    let method: ShippingMethod
    let isSelected: Bool
    let orderAmount: Int
    let action: () -> Void
    
    private var price: Int {
        method.calculatePrice(for: orderAmount)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 선택 표시
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .blue : .secondary)
                
                // 아이콘
                Image(systemName: method.type.symbol)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                
                // 정보
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    Text(method.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 가격
                VStack(alignment: .trailing, spacing: 2) {
                    Text(method.formattedPrice(for: orderAmount))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(price == 0 ? .green : .primary)
                    
                    Text(method.estimatedDeliveryDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .background(
                isSelected ? Color.blue.opacity(0.1) : Color.clear,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.blue : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(method.name), \(method.formattedPrice(for: orderAmount)), \(method.estimatedDeliveryDescription)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - 가격 행

struct PriceRow: View {
    let label: String
    let amount: Int
    var detail: String? = nil
    var isDiscount: Bool = false
    
    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: abs(amount))) ?? "\(abs(amount))"
        let prefix = isDiscount || amount < 0 ? "-" : ""
        return "\(prefix)₩\(formatted)"
    }
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            if let detail = detail {
                Text(detail)
                    .foregroundStyle(.green)
                    .font(.subheadline.weight(.medium))
            } else {
                Text(formattedAmount)
                    .foregroundStyle(isDiscount ? .green : .primary)
            }
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(detail ?? formattedAmount)")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CheckoutView(cartStore: .preview)
    }
}

#Preview("Empty Cart") {
    NavigationStack {
        CheckoutView(cartStore: .empty)
    }
}
