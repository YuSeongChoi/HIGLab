import SwiftUI
import SwiftData

struct ProductDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let product: Product
    
    @State private var quantity = 1
    @State private var showAddedToCart = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 상품 이미지
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray5))
                    .frame(height: 300)
                    .overlay {
                        Image(systemName: product.imageName)
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                
                // 상품 정보
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(product.category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundStyle(.accent)
                            .clipShape(Capsule())
                        
                        Spacer()
                    }
                    
                    Text(product.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(product.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    Text(product.formattedPrice)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.accent)
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // 수량 선택
                VStack(alignment: .leading, spacing: 12) {
                    Text("수량")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        Button {
                            if quantity > 1 { quantity -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(quantity > 1 ? .accent : .gray)
                        }
                        .disabled(quantity <= 1)
                        
                        Text("\(quantity)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(width: 50)
                        
                        Button {
                            if quantity < 10 { quantity += 1 }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(quantity < 10 ? .accent : .gray)
                        }
                        .disabled(quantity >= 10)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            // 장바구니 추가 버튼
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("총 금액")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formattedTotal)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Button {
                        addToCart()
                    } label: {
                        Label("장바구니 담기", systemImage: "cart.badge.plus")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .overlay {
            if showAddedToCart {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("장바구니에 추가되었습니다")
                    }
                    .padding()
                    .background(.ultraThickMaterial, in: Capsule())
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring, value: showAddedToCart)
    }
    
    private var formattedTotal: String {
        let total = product.price * Decimal(quantity)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: total as NSDecimalNumber) ?? "₩0"
    }
    
    private func addToCart() {
        let cartItem = CartItem(product: product, quantity: quantity)
        modelContext.insert(cartItem)
        
        showAddedToCart = true
        
        Task {
            try? await Task.sleep(for: .seconds(2))
            showAddedToCart = false
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: Product.samples[0])
    }
    .modelContainer(for: CartItem.self, inMemory: true)
}
