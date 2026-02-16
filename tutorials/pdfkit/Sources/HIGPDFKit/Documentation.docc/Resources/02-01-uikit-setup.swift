import UIKit
import PDFKit

class PDFViewController: UIViewController {
    private let pdfView = PDFView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPDFView()
        loadDocument()
    }
    
    private func setupPDFView() {
        // PDFView를 뷰에 추가
        view.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        // Auto Layout 제약 조건 (전체 화면)
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadDocument() {
        guard let url = Bundle.main.url(forResource: "sample", withExtension: "pdf"),
              let document = PDFDocument(url: url) else { return }
        
        pdfView.document = document
    }
}
