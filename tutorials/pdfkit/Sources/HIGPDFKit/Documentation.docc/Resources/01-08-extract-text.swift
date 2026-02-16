import PDFKit

func extractText(_ page: PDFPage) {
    // 페이지의 전체 텍스트 추출
    if let text = page.string {
        print("페이지 텍스트:")
        print(text)
    }
    
    // 서식이 있는 텍스트 추출
    if let attributedString = page.attributedString {
        print("서식 있는 텍스트:")
        print(attributedString)
    }
}

func extractAllText(_ document: PDFDocument) -> String {
    var fullText = ""
    
    for i in 0..<document.pageCount {
        if let page = document.page(at: i),
           let text = page.string {
            fullText += "--- 페이지 \(i + 1) ---\n"
            fullText += text
            fullText += "\n\n"
        }
    }
    
    return fullText
}
