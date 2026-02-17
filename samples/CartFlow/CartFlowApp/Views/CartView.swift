import SwiftUI

// MARK: - 장바구니 뷰
/// 장바구니 관리 및 결제 진행 화면
///
/// ## 주요 기능
/// - 담긴 상품 목록 표시
/// - 수량 조절 (증가/감소)
/// - 상품 삭제 (스와이프, 버튼)
/// - 결제 화면으로 이동
/// - 장바구니 비우기
///
/// ## 접근성
/// - 모든 액션에 VoiceOver 라벨 제공
/// - 스와이프 액션 대신 버튼 제공
/// - 수량 변경 시 피드백

struct CartView: View {
    
    // MARK: - 환경
    
    @Environment(CartStore.self) private var cartStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - 상태
    
    /// 삭제 확인 알림 표시
    @State private var showDeleteConfirmation = false
    
    /// 삭제 대상 아이템
    @State private var itemToDelete: CartItem?
    
    /// 결제 화면 표시
    @State private var showCheckout = false
    
    /// 전체 삭제 확인 알림 표시
    @State private var showClearConfirmation = false
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if cartStore.isEmpty {
                emptyCartView
            } else {
                cartContentView
            }
        }
        .navigationTitle("장바구니")
        .toolbar {
            if !cartStore.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    clearCartButton
                }
            }
        }
        .navigationDestination(isPresented: $showCheckout) {
            CheckoutView(cartStore: cartStore)
        }
        .alert("상품 삭제", isPresented: $showDeleteConfirmation) {
            Button("취소", role: .cancel) {
                itemToDelete = nil
            }
            Button("삭제", role: .destructive) {
                if let item = itemToDelete {
                    withAnimation {
                        cartStore.removeFromCart(item.product)
                    }
                }
                itemToDelete = nil
            }
        } message: {
            if let item = itemToDelete {
                Text("'\(item.product.name)'을(를) 장바구니에서 삭제하시겠습니까?")
            }
        }
        .alert("장바구니 비우기", isPresented: $showClearConfirmation) {
            Button("취소", role: .cancel) {}
            Button("비우기", role: .destructive) {
                withAnimation {
                    cartStore.clearCart()
                }
            }
        } message: {
            Text("장바구니의 모든 상품(\(cartStore.totalItemCount)개)을 삭제하시겠습니까?")
        }
    }
    
    // MARK: - 빈 장바구니 뷰
    
    private var emptyCartView: some View {
        ContentUnavailableView {
            Label("장바구니가 비었습니다", systemImage: "cart")
        } description: {
            Text("상품을 둘러보고 마음에 드는 상품을 담아보세요.")
        } actions: {
            NavigationLink(value: "products") {
                Text("쇼핑하기")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - 장바구니 콘텐츠
    
    private var cartContentView: some View {
        VStack(spacing: 0) {
            // 상품 목록
            List {
                // 상품 섹션
                Section {
                    ForEach(cartStore.items) { item in
                        CartItemRow(
                            item: item,
                            onIncrement: {
                                withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                                    cartStore.incrementQuantity(for: item)
                                }
                            },
                            onDecrement: {
                                if item.quantity == 1 {
                                    itemToDelete = item
                                    showDeleteConfirmation = true
                                } else {
                                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                                        cartStore.decrementQuantity(for: item)
                                    }
                                }
                            },
                            onDelete: {
                                itemToDelete = item
                                showDeleteConfirmation = true
                            }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                itemToDelete = item
                                showDeleteConfirmation = true
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text("담긴 상품 (\(cartStore.totalItemCount))")
                }
                
                // 배송 안내 섹션
                Section {
                    freeShippingProgress
                } header: {
                    Text("배송")
                }
            }
            .listStyle(.insetGrouped)
            
            // 하단 결제 영역
            checkoutBar
        }
    }
    
    // MARK: - 무료 배송 진행률
    
    private var freeShippingProgress: some View {
        VStack(alignment: .leading, spacing: 8) {
            let threshold = 50000
            let progress = min(Double(cartStore.totalPrice) / Double(threshold), 1.0)
            let remaining = max(0, threshold - cartStore.totalPrice)
            
            HStack {
                Image(systemName: "shippingbox")
                    .foregroundStyle(.secondary)
                
                if remaining > 0 {
                    Text("₩\(remaining.formatted()) 더 담으면 무료 배송!")
                        .font(.subheadline)
                } else {
                    Text("무료 배송 적용 가능!")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
            }
            
            ProgressView(value: progress)
                .tint(progress >= 1.0 ? .green : .accentColor)
                .accessibilityLabel("무료 배송까지 진행률 \(Int(progress * 100))%")
        }
    }
    
    // MARK: - 결제 바
    
    private var checkoutBar: some View {
        VStack(spacing: 12) {
            // 금액 정보
            HStack {
                Text("총 결제 예정 금액")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(cartStore.formattedTotalPrice)
                    .font(.title2.bold())
            }
            
            // 결제 버튼
            Button {
                showCheckout = true
            } label: {
                HStack {
                    Image(systemName: "creditcard")
                    Text("결제하기")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("결제하기, 총 금액 \(cartStore.formattedTotalPrice)")
        }
        .padding()
        .background(.bar)
    }
    
    // MARK: - 장바구니 비우기 버튼
    
    private var clearCartButton: some View {
        Button {
            showClearConfirmation = true
        } label: {
            Image(systemName: "trash")
        }
        .accessibilityLabel("장바구니 비우기")
        .accessibilityHint("\(cartStore.totalItemCount)개의 상품을 모두 삭제합니다")
    }
}

// MARK: - 장바구니 아이템 행

struct CartItemRow: View {
    let item: CartItem
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 상품 이미지
            RoundedRectangle(cornerRadius: 8)
                .fill(.fill.tertiary)
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: item.product.category.symbol)
                        .foregroundStyle(.secondary)
                }
            
            // 상품 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                
                Text(item.product.formattedPrice)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(item.formattedTotalPrice)
                    .font(.subheadline.weight(.semibold))
            }
            
            Spacer()
            
            // 수량 조절
            QuantityStepper(
                quantity: item.quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.product.name), 수량 \(item.quantity), \(item.formattedTotalPrice)")
        .accessibilityActions {
            Button("수량 추가", action: onIncrement)
            Button("수량 감소", action: onDecrement)
            Button("삭제", action: onDelete)
        }
    }
}

// MARK: - 수량 스테퍼

struct QuantityStepper: View {
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    /// 최대 수량
    private let maxQuantity = 99
    
    var body: some View {
        HStack(spacing: 0) {
            // 감소 버튼
            Button(action: onDecrement) {
                Image(systemName: quantity == 1 ? "trash" : "minus")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(quantity == 1 ? .red : .primary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(quantity == 1 ? "삭제" : "수량 감소")
            
            // 수량 표시
            Text("\(quantity)")
                .font(.subheadline.weight(.medium))
                .frame(width: 32)
                .accessibilityHidden(true)
            
            // 증가 버튼
            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .disabled(quantity >= maxQuantity)
            .accessibilityLabel("수량 추가")
        }
        .background(.fill.secondary, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("수량 \(quantity)")
    }
}

// MARK: - 장바구니 요약 뷰 (다른 화면에서 사용)

/// 장바구니 요약 정보를 보여주는 컴팩트 뷰
struct CartSummaryView: View {
    @Environment(CartStore.self) private var cartStore
    
    var body: some View {
        HStack {
            Image(systemName: "cart.fill")
                .foregroundStyle(.accentColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("장바구니")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(cartStore.totalItemCount)개 · \(cartStore.formattedTotalPrice)")
                    .font(.subheadline.weight(.medium))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("장바구니: \(cartStore.totalItemCount)개, \(cartStore.formattedTotalPrice)")
    }
}

// MARK: - Preview

#Preview("With Items") {
    NavigationStack {
        CartView()
    }
    .environment(CartStore.preview)
}

#Preview("Empty") {
    NavigationStack {
        CartView()
    }
    .environment(CartStore())
}

#Preview("Cart Summary") {
    CartSummaryView()
        .padding()
        .environment(CartStore.preview)
}

#Preview("Quantity Stepper") {
    VStack(spacing: 20) {
        QuantityStepper(quantity: 1, onIncrement: {}, onDecrement: {})
        QuantityStepper(quantity: 5, onIncrement: {}, onDecrement: {})
        QuantityStepper(quantity: 99, onIncrement: {}, onDecrement: {})
    }
    .padding()
}
