import SwiftUI
import SwiftData

struct OrderHistoryView: View {
    @Query(sort: \Order.orderedAt, order: .reverse) private var orders: [Order]
    @State private var cloudManager = CloudManager()
    
    var body: some View {
        NavigationStack {
            Group {
                if orders.isEmpty {
                    ContentUnavailableView(
                        "주문 내역이 없습니다",
                        systemImage: "list.clipboard",
                        description: Text("첫 주문을 해보세요!")
                    )
                } else {
                    List(orders) { order in
                        OrderRow(order: order)
                    }
                }
            }
            .navigationTitle("주문내역")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    cloudSyncStatus
                }
            }
        }
    }
    
    private var cloudSyncStatus: some View {
        Group {
            switch cloudManager.iCloudStatus {
            case .available:
                Image(systemName: "icloud.fill")
                    .foregroundStyle(.green)
            case .checking:
                ProgressView()
                    .scaleEffect(0.8)
            default:
                Image(systemName: "icloud.slash")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Order Row
struct OrderRow: View {
    let order: Order
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 주문 헤더
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("주문번호")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(order.orderId.prefix(8)).uppercased())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(order.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    StatusBadge(status: order.status)
                }
            }
            
            Divider()
            
            // 주문 상품
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(order.items, id: \.self) { item in
                        HStack {
                            Text(item.productName)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("×\(item.quantity)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                Divider()
            }
            
            // 총액
            HStack {
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "접기" : "상세보기")
                            .font(.caption)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(.accent)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: paymentIcon)
                        .font(.caption)
                    Text(order.formattedTotal)
                        .font(.headline)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var paymentIcon: String {
        order.paymentMethod == "Apple Pay" ? "applelogo" : "creditcard"
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: String
    
    private var color: Color {
        switch status {
        case "completed": return .green
        case "processing": return .orange
        case "cancelled": return .red
        default: return .gray
        }
    }
    
    private var text: String {
        switch status {
        case "completed": return "완료"
        case "processing": return "처리중"
        case "cancelled": return "취소"
        default: return status
        }
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    OrderHistoryView()
        .modelContainer(for: Order.self, inMemory: true)
}
