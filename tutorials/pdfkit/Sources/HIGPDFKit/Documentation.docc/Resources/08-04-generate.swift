import PDFKit
import UIKit

class ThumbnailGenerator {
    let document: PDFDocument
    private let cache = NSCache<NSNumber, UIImage>()
    
    init(document: PDFDocument) {
        self.document = document
        cache.countLimit = 50 // 최대 50개 캐시
    }
    
    /// 특정 페이지의 썸네일 생성
    func thumbnail(for pageIndex: Int, size: CGSize) -> UIImage? {
        let key = NSNumber(value: pageIndex)
        
        // 캐시 확인
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        // 페이지 가져오기
        guard let page = document.page(at: pageIndex) else {
            return nil
        }
        
        // 썸네일 생성
        let thumbnail = page.thumbnail(of: size, for: .cropBox)
        
        // 캐시에 저장
        cache.setObject(thumbnail, forKey: key)
        
        return thumbnail
    }
    
    /// 모든 페이지의 썸네일 비동기 생성
    func generateAllThumbnails(
        size: CGSize,
        progress: @escaping (Int, UIImage) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0..<self.document.pageCount {
                if let thumbnail = self.thumbnail(for: i, size: size) {
                    DispatchQueue.main.async {
                        progress(i, thumbnail)
                    }
                }
            }
        }
    }
}
