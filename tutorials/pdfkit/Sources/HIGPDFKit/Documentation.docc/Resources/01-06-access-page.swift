import PDFKit

func accessPages(_ document: PDFDocument) {
    // 인덱스로 페이지 접근 (0부터 시작)
    if let firstPage = document.page(at: 0) {
        print("첫 페이지 접근 성공")
    }
    
    // 마지막 페이지 접근
    let lastIndex = document.pageCount - 1
    if let lastPage = document.page(at: lastIndex) {
        print("마지막 페이지 접근 성공")
    }
    
    // 모든 페이지 순회
    for i in 0..<document.pageCount {
        if let page = document.page(at: i) {
            print("페이지 \(i + 1): \(page)")
        }
    }
}
