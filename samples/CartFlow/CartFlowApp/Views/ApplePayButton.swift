import SwiftUI
import PassKit

// MARK: - Apple Pay 버튼
/// SwiftUI에서 사용하는 Apple Pay 버튼 래퍼
///
/// ## 개요
/// `PKPaymentButton`을 SwiftUI에서 사용할 수 있도록 래핑한 컴포넌트입니다.
/// 다양한 버튼 스타일과 타입을 지원하며, 접근성이 완벽하게 구현되어 있습니다.
///
/// ## 사용 예시
/// ```swift
/// // 기본 사용
/// ApplePayButton {
///     await processPayment()
/// }
///
/// // 스타일 커스터마이징
/// ApplePayButton(type: .checkout, style: .whiteOutline) {
///     await processPayment()
/// }
///
/// // 비활성화 상태
/// ApplePayButton {
///     await processPayment()
/// }
/// .disabled(cart.isEmpty)
/// ```
///
/// ## 버튼 타입
/// - `.buy`: 구입 (Buy with Apple Pay)
/// - `.setUp`: 설정 (Set up Apple Pay)
/// - `.checkout`: 결제 (Check out with Apple Pay)
/// - `.donate`: 기부 (Donate with Apple Pay)
/// - `.subscribe`: 구독 (Subscribe with Apple Pay)
/// - `.plain`: 로고만 표시

struct ApplePayButton: View {
    
    // MARK: - 속성
    
    /// 버튼 타입
    let type: PKPaymentButtonType
    
    /// 버튼 스타일
    let style: PKPaymentButtonStyle
    
    /// 버튼 높이
    let height: CGFloat
    
    /// 모서리 곡률
    let cornerRadius: CGFloat
    
    /// 탭 액션
    let action: () async -> Void
    
    /// 비활성화 상태
    @Environment(\.isEnabled) private var isEnabled
    
    // MARK: - 상태
    
    /// 로딩 중 여부
    @State private var isLoading = false
    
    // MARK: - 초기화
    
    /// Apple Pay 버튼 생성
    /// - Parameters:
    ///   - type: 버튼 타입 (기본: .checkout)
    ///   - style: 버튼 스타일 (기본: .black)
    ///   - height: 버튼 높이 (기본: 50)
    ///   - cornerRadius: 모서리 곡률 (기본: 8)
    ///   - action: 버튼 탭 시 실행할 비동기 액션
    init(
        type: PKPaymentButtonType = .checkout,
        style: PKPaymentButtonStyle = .black,
        height: CGFloat = 50,
        cornerRadius: CGFloat = 8,
        action: @escaping () async -> Void
    ) {
        self.type = type
        self.style = style
        self.height = height
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button {
            guard !isLoading else { return }
            
            Task {
                isLoading = true
                await action()
                isLoading = false
            }
        } label: {
            ZStack {
                // PKPaymentButton 래퍼
                PaymentButtonRepresentable(
                    type: type,
                    style: style,
                    cornerRadius: cornerRadius
                )
                .frame(height: height)
                
                // 로딩 오버레이
                if isLoading {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.black.opacity(0.5))
                    
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.5)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint(accessibilityHintText)
        .accessibilityAddTraits(.isButton)
        .accessibilityRemoveTraits(isEnabled ? [] : .isButton)
        .accessibilityValue(isLoading ? "처리 중" : nil)
    }
    
    // MARK: - 접근성
    
    private var accessibilityLabelText: String {
        switch type {
        case .plain:
            return "Apple Pay"
        case .buy:
            return "Apple Pay로 구입"
        case .setUp:
            return "Apple Pay 설정"
        case .inStore:
            return "매장에서 Apple Pay 사용"
        case .donate:
            return "Apple Pay로 기부"
        case .checkout:
            return "Apple Pay로 결제"
        case .book:
            return "Apple Pay로 예약"
        case .subscribe:
            return "Apple Pay로 구독"
        case .reload:
            return "Apple Pay로 충전"
        case .addMoney:
            return "Apple Pay로 금액 추가"
        case .topUp:
            return "Apple Pay로 충전"
        case .order:
            return "Apple Pay로 주문"
        case .rent:
            return "Apple Pay로 대여"
        case .support:
            return "Apple Pay로 후원"
        case .contribute:
            return "Apple Pay로 기여"
        case .tip:
            return "Apple Pay로 팁 주기"
        case .continue:
            return "Apple Pay로 계속"
        @unknown default:
            return "Apple Pay"
        }
    }
    
    private var accessibilityHintText: String {
        if !isEnabled {
            return "현재 사용할 수 없습니다"
        }
        if isLoading {
            return "결제 처리 중입니다"
        }
        return "두 번 탭하여 결제를 시작합니다"
    }
}

// MARK: - PKPaymentButton UIViewRepresentable

/// UIKit의 PKPaymentButton을 SwiftUI에서 사용하기 위한 래퍼
private struct PaymentButtonRepresentable: UIViewRepresentable {
    let type: PKPaymentButtonType
    let style: PKPaymentButtonStyle
    let cornerRadius: CGFloat
    
    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: type, paymentButtonStyle: style)
        button.cornerRadius = cornerRadius
        // 버튼의 기본 터치 이벤트 비활성화 (SwiftUI Button이 처리)
        button.isUserInteractionEnabled = false
        return button
    }
    
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {
        // 코너 라운드 업데이트
        uiView.cornerRadius = cornerRadius
    }
}

// MARK: - Apple Pay 설정 버튼

/// Apple Pay 설정 안내 버튼
/// 카드가 등록되지 않은 경우 표시
struct ApplePaySetupButton: View {
    
    /// 버튼 높이
    let height: CGFloat
    
    /// 설정 액션
    let action: () -> Void
    
    @Environment(\.isEnabled) private var isEnabled
    
    init(
        height: CGFloat = 50,
        action: @escaping () -> Void
    ) {
        self.height = height
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            PaymentButtonRepresentable(
                type: .setUp,
                style: .black,
                cornerRadius: 8
            )
            .frame(height: height)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
        .accessibilityLabel("Apple Pay 설정")
        .accessibilityHint("탭하여 Wallet에 카드를 추가합니다")
    }
}

// MARK: - 조건부 Apple Pay 버튼

/// Apple Pay 가용성에 따라 자동으로 적절한 버튼 표시
struct ConditionalApplePayButton: View {
    
    /// 결제 서비스
    let paymentService: ApplePayService
    
    /// 버튼 높이
    let height: CGFloat
    
    /// 결제 액션
    let payAction: () async -> Void
    
    /// 설정 액션
    let setupAction: () -> Void
    
    init(
        paymentService: ApplePayService,
        height: CGFloat = 50,
        payAction: @escaping () async -> Void,
        setupAction: @escaping () -> Void
    ) {
        self.paymentService = paymentService
        self.height = height
        self.payAction = payAction
        self.setupAction = setupAction
    }
    
    var body: some View {
        switch paymentService.paymentAvailability {
        case .available:
            ApplePayButton(
                type: .checkout,
                style: .black,
                height: height,
                action: payAction
            )
            
        case .needsSetup:
            ApplePaySetupButton(
                height: height,
                action: setupAction
            )
            
        case .notSupported:
            UnavailablePaymentButton(
                message: "이 기기에서 Apple Pay를 사용할 수 없습니다",
                height: height
            )
        }
    }
}

// MARK: - 사용 불가 버튼

/// Apple Pay를 사용할 수 없을 때 표시하는 대체 버튼
struct UnavailablePaymentButton: View {
    
    let message: String
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "creditcard.trianglebadge.exclamationmark")
                    .font(.title3)
                
                Text("Apple Pay 사용 불가")
                    .font(.headline)
            }
            .foregroundStyle(.secondary)
            
            Text(message)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height + 20)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Apple Pay 사용 불가: \(message)")
    }
}

// MARK: - 버튼 스타일 프리뷰

#Preview("Apple Pay Button Styles") {
    VStack(spacing: 20) {
        Text("버튼 타입")
            .font(.headline)
        
        ApplePayButton(type: .plain, style: .black) {}
        ApplePayButton(type: .buy, style: .black) {}
        ApplePayButton(type: .checkout, style: .black) {}
        ApplePayButton(type: .subscribe, style: .black) {}
        ApplePayButton(type: .donate, style: .black) {}
        
        Divider()
        
        Text("버튼 스타일")
            .font(.headline)
        
        ApplePayButton(type: .checkout, style: .black) {}
        ApplePayButton(type: .checkout, style: .white) {}
        ApplePayButton(type: .checkout, style: .whiteOutline) {}
        ApplePayButton(type: .checkout, style: .automatic) {}
        
        Divider()
        
        Text("비활성화 상태")
            .font(.headline)
        
        ApplePayButton(type: .checkout, style: .black) {}
            .disabled(true)
    }
    .padding()
}

#Preview("Setup & Unavailable") {
    VStack(spacing: 20) {
        ApplePaySetupButton {}
        
        UnavailablePaymentButton(
            message: "이 기기에서는 Apple Pay를 지원하지 않습니다",
            height: 50
        )
    }
    .padding()
}

// MARK: - 커스텀 모디파이어

extension View {
    /// Apple Pay 버튼 스타일 적용
    /// - Parameters:
    ///   - height: 버튼 높이
    ///   - cornerRadius: 모서리 곡률
    func applePayButtonStyle(
        height: CGFloat = 50,
        cornerRadius: CGFloat = 8
    ) -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - 결제 진행 상태 표시 뷰

/// Apple Pay 결제 진행 상태를 시각적으로 표시
struct PaymentProgressView: View {
    
    /// 현재 결제 상태
    let state: PaymentState
    
    var body: some View {
        HStack(spacing: 12) {
            statusIcon
                .font(.title2)
                .foregroundStyle(statusColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.headline)
                
                Text(statusDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if state.isInProgress {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(statusTitle): \(statusDescription)")
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch state {
        case .idle:
            Image(systemName: "creditcard")
        case .preparing:
            Image(systemName: "gear")
        case .authorizing:
            Image(systemName: "faceid")
        case .processing:
            Image(systemName: "arrow.triangle.2.circlepath")
        case .completed:
            Image(systemName: "checkmark.circle.fill")
        case .cancelled:
            Image(systemName: "xmark.circle")
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill")
        }
    }
    
    private var statusColor: Color {
        switch state {
        case .idle:
            return .secondary
        case .preparing, .authorizing, .processing:
            return .blue
        case .completed:
            return .green
        case .cancelled:
            return .orange
        case .failed:
            return .red
        }
    }
    
    private var statusTitle: String {
        state.rawValue
    }
    
    private var statusDescription: String {
        switch state {
        case .idle:
            return "결제를 시작해주세요"
        case .preparing:
            return "결제 정보를 준비하고 있습니다"
        case .authorizing:
            return "Face ID 또는 Touch ID로 인증해주세요"
        case .processing:
            return "결제를 처리하고 있습니다"
        case .completed:
            return "결제가 완료되었습니다"
        case .cancelled:
            return "결제가 취소되었습니다"
        case .failed:
            return "결제에 실패했습니다"
        }
    }
}

#Preview("Payment Progress") {
    VStack(spacing: 16) {
        PaymentProgressView(state: .idle)
        PaymentProgressView(state: .authorizing)
        PaymentProgressView(state: .processing)
        PaymentProgressView(state: .completed)
        PaymentProgressView(state: .failed)
    }
    .padding()
}
