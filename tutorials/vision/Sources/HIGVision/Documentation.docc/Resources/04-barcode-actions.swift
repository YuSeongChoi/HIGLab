import SwiftUI
import UIKit

extension BarcodeScanView {
    
    /// 바코드 값에 따른 액션 수행
    func performAction(for barcode: ScannedBarcode) {
        let value = barcode.value
        
        // URL인 경우 Safari로 열기
        if let url = URL(string: value), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return
        }
        
        // 그 외 클립보드에 복사
        UIPasteboard.general.string = value
    }
}

struct BarcodeActionSheet: View {
    let barcode: ScannedBarcode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("바코드 정보") {
                    LabeledContent("값", value: barcode.value)
                    LabeledContent("형식", value: barcode.symbologyName)
                }
                
                Section("작업") {
                    Button {
                        UIPasteboard.general.string = barcode.value
                        dismiss()
                    } label: {
                        Label("복사", systemImage: "doc.on.doc")
                    }
                    
                    if let url = URL(string: barcode.value),
                       UIApplication.shared.canOpenURL(url) {
                        Button {
                            UIApplication.shared.open(url)
                            dismiss()
                        } label: {
                            Label("Safari로 열기", systemImage: "safari")
                        }
                    }
                }
            }
            .navigationTitle("바코드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }
}
