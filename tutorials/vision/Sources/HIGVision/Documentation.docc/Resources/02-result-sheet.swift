import SwiftUI

struct TextResultsSheet: View {
    let texts: [RecognizedText]
    @Environment(\.dismiss) private var dismiss
    
    var allText: String {
        texts.map(\.text).joined(separator: "\n")
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("전체 텍스트") {
                    Text(allText)
                        .textSelection(.enabled)
                }
                
                Section("상세 결과") {
                    ForEach(texts) { item in
                        HStack {
                            Text(item.text)
                            Spacer()
                            Text("\(item.confidencePercent)%")
                                .foregroundStyle(confidenceColor(item.confidenceLevel))
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("인식 결과")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        UIPasteboard.general.string = allText
                    } label: {
                        Label("복사", systemImage: "doc.on.doc")
                    }
                }
            }
        }
    }
    
    private func confidenceColor(_ level: ConfidenceLevel) -> Color {
        switch level {
        case .high: return .green
        case .medium: return .orange
        case .low: return .red
        }
    }
}
