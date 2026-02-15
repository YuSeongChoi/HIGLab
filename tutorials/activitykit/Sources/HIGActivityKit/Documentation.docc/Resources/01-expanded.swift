// Dynamic Island - Expanded 레이아웃
// 길게 눌렀을 때 표시

struct ExpandedView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            // 상단: 가게 정보 + 배달 상태
            HStack {
                // Leading
                Image(systemName: "storefront")
                    .font(.title2)
                
                // Center
                VStack(alignment: .leading) {
                    Text(context.attributes.storeName)
                        .font(.headline)
                    Text(context.state.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Trailing
                Image(systemName: context.state.status.symbolName)
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            
            // Bottom: 진행 바
            DeliveryProgressBar(progress: context.state.progress)
        }
        .padding()
    }
}
