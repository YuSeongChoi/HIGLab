import SwiftUI

struct TransferProgressView: View {
    @ObservedObject var resourceManager: ResourceManager
    
    var body: some View {
        List {
            ForEach(resourceManager.transfers) { transfer in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: iconName(for: transfer))
                            .foregroundStyle(iconColor(for: transfer))
                        
                        Text(transfer.fileName)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(transfer.peer.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !transfer.isCompleted {
                        ProgressView(value: transfer.progress)
                        
                        Text("\(Int(transfer.progress * 100))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else if let error = transfer.error {
                        Text("실패: \(error.localizedDescription)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("전송 현황")
    }
    
    private func iconName(for transfer: ResourceManager.TransferInfo) -> String {
        if transfer.isCompleted {
            return transfer.error == nil ? "checkmark.circle.fill" : "xmark.circle.fill"
        }
        return "arrow.up.circle"
    }
    
    private func iconColor(for transfer: ResourceManager.TransferInfo) -> Color {
        if transfer.isCompleted {
            return transfer.error == nil ? .green : .red
        }
        return .blue
    }
}
