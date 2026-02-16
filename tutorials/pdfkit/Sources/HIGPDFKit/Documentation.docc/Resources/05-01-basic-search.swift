import PDFKit

class PDFSearchManager: NSObject {
    let document: PDFDocument
    var searchResults: [PDFSelection] = []
    var onResultFound: ((PDFSelection) -> Void)?
    var onSearchComplete: (() -> Void)?
    
    init(document: PDFDocument) {
        self.document = document
        super.init()
        document.delegate = self
    }
    
    func search(for text: String, caseSensitive: Bool = false) {
        // 기존 검색 취소
        document.cancelFindString()
        searchResults.removeAll()
        
        // 검색 옵션 설정
        var options: NSString.CompareOptions = []
        if !caseSensitive {
            options.insert(.caseInsensitive)
        }
        
        // 비동기 검색 시작
        document.beginFindString(text, withOptions: options)
    }
    
    func cancelSearch() {
        document.cancelFindString()
    }
}

extension PDFSearchManager: PDFDocumentDelegate {
    func didMatchString(_ instance: PDFSelection) {
        searchResults.append(instance)
        onResultFound?(instance)
    }
    
    func documentDidEndDocumentFind(_ notification: Notification) {
        onSearchComplete?()
    }
}
