import SwiftUI
import SwiftData
import PassKit

struct CartView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CartItem.addedAt, order: .reverse) private var cartItems: [CartItem]
    
    @State private var paymentManager = PaymentManager()
    @State private var showPaymentResult = false
    @State private var paymentSuccess = false
    
    private var total: Decimal {
        cartItems.reduce(Decimal.zero) { $0 + $1.subtotal }
    }
    
    private var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: total as NSDecimalNumber) ?? "₩0"
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if cartItems.isEmpty {
                    ContentUnavailableView(
                        "장바구니가 비어있습니다",
                        systemImage: "cart",
                        description: Text("상품을 추가해주세요")
                    )
                } else {
                    List {
                        ForEach(cartItems) { item in
                            CartItemRow(item: item)
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .navigationTitle("장바구니")
            .toolbar {
                if !cartItems.isEmpty {
                    EditButton()
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !cartItems.isEmpty {
                    checkoutSection
                }
            }
            .alert(
                paymentSuccess ? "결제 완료" : "결제 실패",
                isPresented: $showPaymentResult
            ) {
                Button("확인") {
                    if paymentSuccess {
                        completeOrder()
                    }
                }
            } message: {
                Text(paymentSuccess ? "주문이 완료되었습니다." : "결제를 다시 시도해주세요.")
            }
        }
    }
    
    // MARK: - Checkout Section
    private var checkoutSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("총 \(cartItems.count)개 상품")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(formattedTotal)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            // Apple Pay 버튼
            if paymentManager.canMakePayments {
                ApplePayButton(action: startApplePay)
                    .frame(height: 50)
            }
            
            // 일반 결제 버튼
            Button {
                simulatePayment()
            } label: {
                Text("일반 결제")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Apple Pay Button
    struct ApplePayButton: UIViewRepresentable {
        let action: () -> Void
        
        func makeUIView(context: Context) -> PKPaymentButton {
            let button = PKPaymentButton(paymentButtonType: .checkout, paymentButtonStyle: .automatic)
            button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
            return button
        }
        
        func updateUIView(_ uiView: PKPaymentButton, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(action: action)
        }
        
        class Coordinator: NSObject {
            let action: () -> Void
            init(action: @escaping () -> Void) { self.action = action }
            @objc func buttonTapped() { action() }
        }
    }
    
    // MARK: - Actions
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(cartItems[index])
        }
    }
    
    private func startApplePay() {
        let items = cartItems.map { ($0.productName, $0.subtotal) }
        let request = paymentManager.createPaymentRequest(for: items)
        
        Task {
            paymentSuccess = await paymentManager.startPayment(request: request)
            showPaymentResult = true
        }
    }
    
    private func simulatePayment() {
        paymentSuccess = true
        showPaymentResult = true
    }
    
    private func completeOrder() {
        // 주문 생성
        let orderItems = cartItems.map {
            OrderItem(productName: $0.productName, quantity: $0.quantity, price: $0.price)
        }
        let order = Order(items: orderItems, totalAmount: total, paymentMethod: "Apple Pay")
        modelContext.insert(order)
        
        // 장바구니 비우기
        for item in cartItems {
            modelContext.delete(item)
        }
    }
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    let item: CartItem
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "cube.box")
                        .foregroundStyle(.secondary)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.productName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("수량: \(item.quantity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(item.formattedSubtotal)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    CartView()
        .modelContainer(for: [CartItem.self, Order.self], inMemory: true)
}
