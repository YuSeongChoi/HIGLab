import UIKit
import PDFKit

class PDFCreator {
    
    /// 기본 PDF 생성
    func createSimplePDF() -> Data {
        // A4 크기 설정 (포인트 단위: 72 points = 1 inch)
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        
        // PDF 렌더러 생성
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        // PDF 데이터 생성
        let data = renderer.pdfData { context in
            // 첫 번째 페이지 시작
            context.beginPage()
            
            // 텍스트 그리기
            let title = "Hello, PDFKit!"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: attributes)
            
            // 두 번째 페이지
            context.beginPage()
            
            let content = "This is page 2"
            content.draw(at: CGPoint(x: 50, y: 50), withAttributes: [
                .font: UIFont.systemFont(ofSize: 16)
            ])
        }
        
        return data
    }
}
