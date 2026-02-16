import PDFKit

func inspectDocument(_ document: PDFDocument) {
    // 페이지 수
    print("총 페이지: \(document.pageCount)")
    
    // 암호화 여부
    print("암호화됨: \(document.isEncrypted)")
    print("잠금 상태: \(document.isLocked)")
    
    // 문서 메타데이터
    if let attributes = document.documentAttributes {
        if let title = attributes[PDFDocumentAttribute.titleAttribute] as? String {
            print("제목: \(title)")
        }
        if let author = attributes[PDFDocumentAttribute.authorAttribute] as? String {
            print("작성자: \(author)")
        }
        if let subject = attributes[PDFDocumentAttribute.subjectAttribute] as? String {
            print("주제: \(subject)")
        }
    }
}
