import PDFKit
import UIKit

class PDFEditor {
    let document: PDFDocument
    
    init(document: PDFDocument) {
        self.document = document
    }
    
    /// 빈 페이지 삽입
    func insertBlankPage(at index: Int, size: CGSize? = nil) {
        // 페이지 크기 결정 (기본: 첫 페이지와 동일)
        let pageSize: CGSize
        if let size = size {
            pageSize = size
        } else if let firstPage = document.page(at: 0) {
            let bounds = firstPage.bounds(for: .mediaBox)
            pageSize = bounds.size
        } else {
            pageSize = CGSize(width: 612, height: 792) // Letter 크기
        }
        
        // 빈 PDF 페이지 생성
        let page = PDFPage()
        page.setBounds(
            CGRect(origin: .zero, size: pageSize),
            for: .mediaBox
        )
        
        // 문서에 삽입
        document.insert(page, at: index)
    }
    
    /// 이미지로부터 페이지 생성하여 삽입
    func insertImagePage(_ image: UIImage, at index: Int) {
        guard let page = PDFPage(image: image) else { return }
        document.insert(page, at: index)
    }
    
    /// 페이지 삭제
    func removePage(at index: Int) {
        guard index < document.pageCount else { return }
        document.removePage(at: index)
    }
    
    /// 문서 저장
    func save(to url: URL) -> Bool {
        return document.write(to: url)
    }
}
