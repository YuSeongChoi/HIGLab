import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument?
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        // 기본 설정
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // 문서가 변경되면 업데이트
        if pdfView.document !== document {
            pdfView.document = document
        }
    }
}

// 사용 예시
struct ContentView: View {
    @State private var document: PDFDocument?
    
    var body: some View {
        PDFKitView(document: document)
            .onAppear {
                if let url = Bundle.main.url(forResource: "sample", withExtension: "pdf") {
                    document = PDFDocument(url: url)
                }
            }
    }
}
