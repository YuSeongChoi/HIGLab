import SwiftUI
import StoreKit

// MARK: - PurchaseHistoryView
/// 구매 내역을 표시하는 뷰
/// 모든 과거 트랜잭션을 날짜순으로 보여줍니다.

struct PurchaseHistoryView: View {
    // MARK: - 상태
    
    /// 구매 내역
    @State private var transactions: [Transaction] = []
    
    /// 로딩 중 여부
    @State private var isLoading = true
    
    /// 선택된 트랜잭션 (상세 보기용)
    @State private var selectedTransaction: Transaction?
    
    // MARK: - 뷰 본문
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if transactions.isEmpty {
                    emptyView
                } else {
                    transactionList
                }
            }
            .navigationTitle("구매 내역")
            .task {
                await loadTransactions()
            }
            .refreshable {
                await loadTransactions()
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction)
                    .presentationDetents([.medium])
            }
        }
    }
    
    // MARK: - 로딩 뷰
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("구매 내역을 불러오는 중...")
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 빈 상태 뷰
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label("구매 내역 없음", systemImage: "clock")
        } description: {
            Text("아직 구매한 상품이 없습니다.")
        }
    }
    
    // MARK: - 트랜잭션 목록
    
    private var transactionList: some View {
        List {
            // 날짜별로 그룹화
            ForEach(groupedTransactions, id: \.key) { group in
                Section(header: Text(group.key)) {
                    ForEach(group.value, id: \.id) { transaction in
                        TransactionRow(transaction: transaction)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTransaction = transaction
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    /// 날짜별로 그룹화된 트랜잭션
    private var groupedTransactions: [(key: String, value: [Transaction])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        
        let grouped = Dictionary(grouping: transactions) { transaction in
            formatter.string(from: transaction.purchaseDate)
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    // MARK: - 데이터 로드
    
    private func loadTransactions() async {
        isLoading = true
        transactions = await StoreManager.shared.getPurchaseHistory()
        isLoading = false
    }
}

// MARK: - TransactionRow
/// 트랜잭션 행

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            // 상품 유형 아이콘
            transactionIcon
            
            // 트랜잭션 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.productID.components(separatedBy: ".").last ?? "상품")
                    .font(.headline)
                
                Text(transaction.purchaseDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 상태 표시
            transactionStatus
        }
        .padding(.vertical, 4)
    }
    
    // MARK: 아이콘
    
    private var transactionIcon: some View {
        Image(systemName: iconName)
            .font(.title2)
            .foregroundStyle(iconColor)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(iconColor.opacity(0.15))
            )
    }
    
    private var iconName: String {
        switch transaction.productType {
        case .consumable:
            return "c.circle.fill"
        case .nonConsumable:
            return "star.fill"
        case .autoRenewable:
            return "crown.fill"
        case .nonRenewable:
            return "clock.fill"
        @unknown default:
            return "bag.fill"
        }
    }
    
    private var iconColor: Color {
        if transaction.revocationDate != nil {
            return .red
        }
        
        switch transaction.productType {
        case .consumable:
            return .orange
        case .nonConsumable:
            return .purple
        case .autoRenewable:
            return .yellow
        default:
            return .blue
        }
    }
    
    // MARK: 상태
    
    @ViewBuilder
    private var transactionStatus: some View {
        if transaction.revocationDate != nil {
            // 환불됨
            Label("환불됨", systemImage: "arrow.uturn.backward.circle")
                .font(.caption)
                .foregroundStyle(.red)
        } else if let expirationDate = transaction.expirationDate {
            // 구독 상품
            if expirationDate > Date() {
                Label("활성", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else {
                Label("만료됨", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            // 일반 구매
            Label("완료", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.green)
        }
    }
}

// MARK: - TransactionDetailView
/// 트랜잭션 상세 정보 시트

struct TransactionDetailView: View {
    let transaction: Transaction
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("기본 정보") {
                    DetailRow(title: "상품 ID", value: transaction.productID)
                    DetailRow(title: "트랜잭션 ID", value: String(transaction.id))
                    DetailRow(title: "구매 날짜", value: transaction.purchaseDate.formatted())
                    DetailRow(title: "상품 유형", value: productTypeString)
                }
                
                if let expirationDate = transaction.expirationDate {
                    Section("구독 정보") {
                        DetailRow(title: "만료 날짜", value: expirationDate.formatted())
                        DetailRow(title: "상태", value: expirationDate > Date() ? "활성" : "만료됨")
                    }
                }
                
                if transaction.revocationDate != nil {
                    Section("환불 정보") {
                        DetailRow(title: "환불 날짜", value: transaction.revocationDate?.formatted() ?? "-")
                        DetailRow(title: "환불 사유", value: revocationReasonString)
                    }
                }
                
                Section("기술 정보") {
                    DetailRow(title: "원본 구매 날짜", value: transaction.originalPurchaseDate.formatted())
                    DetailRow(title: "원본 트랜잭션 ID", value: String(transaction.originalID))
                    DetailRow(title: "환경", value: environmentString)
                }
            }
            .navigationTitle("트랜잭션 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - 헬퍼
    
    private var productTypeString: String {
        switch transaction.productType {
        case .consumable:
            return "소모성"
        case .nonConsumable:
            return "비소모성"
        case .autoRenewable:
            return "자동 갱신 구독"
        case .nonRenewable:
            return "비갱신 구독"
        @unknown default:
            return "알 수 없음"
        }
    }
    
    private var revocationReasonString: String {
        guard let reason = transaction.revocationReason else { return "-" }
        switch reason {
        case .developerIssue:
            return "개발자 문제"
        case .other:
            return "기타"
        @unknown default:
            return "알 수 없음"
        }
    }
    
    private var environmentString: String {
        switch transaction.environment {
        case .production:
            return "프로덕션"
        case .sandbox:
            return "샌드박스"
        case .xcode:
            return "Xcode"
        @unknown default:
            return "알 수 없음"
        }
    }
}

// MARK: - DetailRow
/// 상세 정보 행

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Transaction Extension

extension Transaction: @retroactive Identifiable {}

// MARK: - 프리뷰

#Preview {
    PurchaseHistoryView()
}
