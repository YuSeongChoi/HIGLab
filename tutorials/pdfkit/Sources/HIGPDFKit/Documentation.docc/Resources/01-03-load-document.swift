import PDFKit

func loadPDFFromBundle() -> PDFDocument? {
    // Bundle에서 PDF 파일 URL 가져오기
    guard let url = Bundle.main.url(
        forResource: "sample",
        withExtension: "pdf"
    ) else {
        print("PDF 파일을 찾을 수 없습니다")
        return nil
    }
    
    // URL로부터 PDFDocument 생성
    guard let document = PDFDocument(url: url) else {
        print("PDF 문서를 로드할 수 없습니다")
        return nil
    }
    
    return document
}
