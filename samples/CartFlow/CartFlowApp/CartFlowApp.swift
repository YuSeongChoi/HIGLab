import SwiftUI

// MARK: - CartFlow 앱
/// PassKit(Apple Pay) 기능을 보여주는 쇼핑 앱 샘플
///
/// ## 개요
/// CartFlow는 Apple Pay를 활용한 결제 프로세스를 시연하는
/// HIG Lab 샘플 프로젝트입니다.
///
/// ## 주요 기능
/// - 상품 목록 및 상세
/// - 장바구니 관리
/// - Apple Pay 결제
/// - 배송 옵션 선택
/// - 쿠폰 코드 적용
///
/// ## PassKit API 활용
/// ```
/// ┌─────────────────────────────────────────────────────────┐
/// │                    CartFlow App                          │
/// ├─────────────────────────────────────────────────────────┤
/// │                                                          │
/// │  ┌──────────────┐    ┌──────────────┐    ┌────────────┐ │
/// │  │ ProductList  │───▶│    Cart      │───▶│  Checkout  │ │
/// │  │    View      │    │    View      │    │    View    │ │
/// │  └──────────────┘    └──────────────┘    └─────┬──────┘ │
/// │                                                 │        │
/// │                                                 ▼        │
/// │                                     ┌───────────────────┐│
/// │                                     │  Apple Pay Sheet  ││
/// │                                     │  ┌─────────────┐  ││
/// │                                     │  │PKPayment    │  ││
/// │                                     │  │Authorization│  ││
/// │                                     │  │Controller   │  ││
/// │                                     │  └─────────────┘  ││
/// │                                     └───────────────────┘│
/// │                                                          │
/// └─────────────────────────────────────────────────────────┘
/// ```
///
/// ## 아키텍처
/// - **Observation Framework**: iOS 17+ @Observable 매크로 활용
/// - **Async/Await**: 비동기 결제 처리
/// - **Sendable**: 동시성 안전한 데이터 모델

@main
struct CartFlowApp: App {
    
    // MARK: - 상태
    
    /// 장바구니 상태 (앱 전역)
    @State private var cartStore = CartStore()
    
    /// 상품 서비스
    private let productService = ProductService.shared
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(cartStore)
        }
    }
}

// MARK: - 메인 콘텐츠 뷰

/// 앱의 메인 콘텐츠를 담당하는 루트 뷰
struct ContentView: View {
    
    // MARK: - 환경
    
    @Environment(CartStore.self) private var cartStore
    
    // MARK: - 상태
    
    /// 선택된 탭
    @State private var selectedTab: Tab = .products
    
    /// 장바구니 배지 애니메이션
    @State private var cartBadgeScale: CGFloat = 1.0
    
    // MARK: - 탭 열거형
    
    enum Tab: String, CaseIterable {
        case products = "상품"
        case cart = "장바구니"
        case settings = "설정"
        
        var icon: String {
            switch self {
            case .products: return "square.grid.2x2"
            case .cart: return "cart"
            case .settings: return "gearshape"
            }
        }
        
        var filledIcon: String {
            switch self {
            case .products: return "square.grid.2x2.fill"
            case .cart: return "cart.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 상품 목록
            NavigationStack {
                ProductListView()
            }
            .tabItem {
                Label(
                    Tab.products.rawValue,
                    systemImage: selectedTab == .products 
                        ? Tab.products.filledIcon 
                        : Tab.products.icon
                )
            }
            .tag(Tab.products)
            
            // 장바구니
            NavigationStack {
                CartView()
            }
            .tabItem {
                Label(
                    Tab.cart.rawValue,
                    systemImage: selectedTab == .cart 
                        ? Tab.cart.filledIcon 
                        : Tab.cart.icon
                )
            }
            .tag(Tab.cart)
            .badge(cartStore.totalItemCount > 0 ? cartStore.totalItemCount : 0)
            
            // 설정
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(
                    Tab.settings.rawValue,
                    systemImage: selectedTab == .settings 
                        ? Tab.settings.filledIcon 
                        : Tab.settings.icon
                )
            }
            .tag(Tab.settings)
        }
        .onChange(of: cartStore.totalItemCount) { oldValue, newValue in
            // 장바구니 아이템 추가 시 배지 애니메이션
            if newValue > oldValue {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    cartBadgeScale = 1.2
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
                    cartBadgeScale = 1.0
                }
            }
        }
    }
}

// MARK: - 설정 뷰

/// 앱 설정 및 Apple Pay 상태 확인 뷰
struct SettingsView: View {
    
    // MARK: - 상태
    
    /// Apple Pay 서비스 (상태 확인용)
    @State private var paymentService = ApplePayService()
    
    // MARK: - Body
    
    var body: some View {
        List {
            // Apple Pay 섹션
            Section {
                // Apple Pay 상태
                applePayStatusRow
                
                // Apple Pay 설정 버튼
                if paymentService.needsSetup {
                    Button {
                        paymentService.presentAddCardSheet()
                    } label: {
                        Label("카드 추가", systemImage: "plus.rectangle.on.folder")
                    }
                }
            } header: {
                Label("Apple Pay", systemImage: "applelogo")
            } footer: {
                Text("Apple Pay를 사용하면 안전하고 빠르게 결제할 수 있습니다.")
            }
            
            // 지원 카드 네트워크
            Section {
                ForEach(PaymentConfiguration.defaultNetworks, id: \.rawValue) { network in
                    Label(network.rawValue.capitalized, systemImage: "creditcard")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("지원 카드")
            }
            
            // 앱 정보
            Section {
                LabeledContent("버전", value: "1.0.0")
                LabeledContent("빌드", value: "1")
                
                Link(destination: URL(string: "https://developer.apple.com/documentation/passkit")!) {
                    Label("PassKit 문서", systemImage: "doc.text")
                }
                
                Link(destination: URL(string: "https://developer.apple.com/design/human-interface-guidelines/apple-pay")!) {
                    Label("Apple Pay HIG", systemImage: "book")
                }
            } header: {
                Text("정보")
            }
            
            // 디버그 섹션
            #if DEBUG
            Section {
                NavigationLink {
                    PaymentDebugView()
                } label: {
                    Label("결제 디버그", systemImage: "ladybug")
                }
            } header: {
                Text("개발자 도구")
            }
            #endif
        }
        .navigationTitle("설정")
    }
    
    // MARK: - Apple Pay 상태 행
    
    @ViewBuilder
    private var applePayStatusRow: some View {
        HStack {
            Label("Apple Pay", systemImage: "applelogo")
            
            Spacer()
            
            switch paymentService.paymentAvailability {
            case .available:
                Label("사용 가능", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .labelStyle(.iconOnly)
                Text("사용 가능")
                    .foregroundStyle(.green)
                
            case .needsSetup:
                Label("설정 필요", systemImage: "exclamationmark.circle.fill")
                    .foregroundStyle(.orange)
                    .labelStyle(.iconOnly)
                Text("설정 필요")
                    .foregroundStyle(.orange)
                
            case .notSupported:
                Label("지원 안됨", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .labelStyle(.iconOnly)
                Text("지원 안됨")
                    .foregroundStyle(.red)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Apple Pay 상태: \(statusText)")
    }
    
    private var statusText: String {
        switch paymentService.paymentAvailability {
        case .available: return "사용 가능"
        case .needsSetup: return "설정 필요"
        case .notSupported: return "지원 안됨"
        }
    }
}

// MARK: - 결제 디버그 뷰

#if DEBUG
struct PaymentDebugView: View {
    
    @State private var paymentService = ApplePayService()
    @State private var testResult: String = ""
    
    var body: some View {
        List {
            Section("결제 설정") {
                LabeledContent("Merchant ID", value: PaymentConfiguration.default.merchantIdentifier)
                LabeledContent("국가 코드", value: PaymentConfiguration.default.countryCode)
                LabeledContent("통화 코드", value: PaymentConfiguration.default.currencyCode)
            }
            
            Section("결제 상태") {
                LabeledContent("canMakePayments", value: "\(paymentService.canMakePayments)")
                LabeledContent("canMakePaymentsWithCards", value: "\(paymentService.canMakePaymentsWithRegisteredCards)")
                LabeledContent("needsSetup", value: "\(paymentService.needsSetup)")
                LabeledContent("paymentState", value: paymentService.paymentState.rawValue)
            }
            
            Section("테스트") {
                Button("테스트 결제 (₩10,000)") {
                    Task {
                        do {
                            let result = try await paymentService.processPayment(amount: 10000)
                            testResult = "성공: \(result.transactionId)"
                        } catch {
                            testResult = "실패: \(error.localizedDescription)"
                        }
                    }
                }
                
                if !testResult.isEmpty {
                    Text(testResult)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Button("상태 초기화") {
                    paymentService.resetPayment()
                    testResult = ""
                }
                .foregroundStyle(.red)
            }
            
            Section("에러 코드") {
                ForEach([
                    PaymentError.applePayNotSupported,
                    PaymentError.noRegisteredCards,
                    PaymentError.userCancelled,
                    PaymentError.timeout
                ], id: \.errorCode) { error in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("[\(error.errorCode)] \(error.category.rawValue)")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("결제 디버그")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif

// MARK: - Preview

#Preview {
    ContentView()
        .environment(CartStore.preview)
}

#Preview("Settings") {
    NavigationStack {
        SettingsView()
    }
}
