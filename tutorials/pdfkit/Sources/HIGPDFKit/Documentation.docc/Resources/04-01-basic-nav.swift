import PDFKit
import UIKit

class NavigationController {
    let pdfView: PDFView
    
    init(pdfView: PDFView) {
        self.pdfView = pdfView
    }
    
    // 이전 페이지로 이동
    func goToPreviousPage() {
        if pdfView.canGoToPreviousPage {
            pdfView.goToPreviousPage(nil)
        }
    }
    
    // 다음 페이지로 이동
    func goToNextPage() {
        if pdfView.canGoToNextPage {
            pdfView.goToNextPage(nil)
        }
    }
    
    // 첫 페이지로 이동
    func goToFirstPage() {
        pdfView.goToFirstPage(nil)
    }
    
    // 마지막 페이지로 이동
    func goToLastPage() {
        pdfView.goToLastPage(nil)
    }
    
    // 현재 페이지 정보
    var currentPageIndex: Int? {
        guard let page = pdfView.currentPage,
              let document = pdfView.document else { return nil }
        return document.index(for: page)
    }
    
    var totalPages: Int {
        pdfView.document?.pageCount ?? 0
    }
}
