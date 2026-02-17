import SwiftUI

// MARK: - 이미지 캐시
/// 메모리 기반 이미지 캐시
/// NSCache를 사용해 메모리 압박 시 자동으로 캐시 정리
final class ImageCache {
    
    // MARK: - 싱글톤
    static let shared = ImageCache()
    
    // MARK: - 내부 저장소
    
    /// NSCache 래퍼 클래스 (참조 타입 필요)
    private class CacheEntry {
        let image: UIImage
        let timestamp: Date
        
        init(image: UIImage) {
            self.image = image
            self.timestamp = Date()
        }
    }
    
    /// 실제 캐시 저장소
    private let cache: NSCache<NSString, CacheEntry> = {
        let cache = NSCache<NSString, CacheEntry>()
        // 캐시 제한 설정
        cache.countLimit = 100          // 최대 100개 이미지
        cache.totalCostLimit = 100 * 1024 * 1024  // 최대 100MB
        return cache
    }()
    
    /// 캐시 키 목록 (순서 추적용)
    private var keys: [String] = []
    
    /// 동기화를 위한 큐
    private let queue = DispatchQueue(label: "com.higlabs.imagecache", attributes: .concurrent)
    
    // MARK: - 초기화
    
    private init() {
        // 메모리 경고 시 캐시 정리
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 공개 API
    
    /// 캐시에서 이미지 조회
    /// - Parameter key: 이미지 식별자
    /// - Returns: 캐시된 이미지 (없으면 nil)
    func image(forKey key: String) -> UIImage? {
        queue.sync {
            cache.object(forKey: key as NSString)?.image
        }
    }
    
    /// 캐시에 이미지 저장
    /// - Parameters:
    ///   - image: 저장할 이미지
    ///   - key: 이미지 식별자
    func setImage(_ image: UIImage, forKey key: String) {
        let cost = imageCost(image)
        let entry = CacheEntry(image: image)
        
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.setObject(entry, forKey: key as NSString, cost: cost)
            
            // 키 목록에 추가
            if let self = self, !self.keys.contains(key) {
                self.keys.append(key)
            }
        }
    }
    
    /// 특정 이미지 캐시에서 제거
    /// - Parameter key: 이미지 식별자
    func removeImage(forKey key: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.removeObject(forKey: key as NSString)
            self?.keys.removeAll { $0 == key }
        }
    }
    
    /// 전체 캐시 정리
    @objc func clearCache() {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.removeAllObjects()
            self?.keys.removeAll()
        }
    }
    
    /// 캐시된 이미지 개수
    var count: Int {
        queue.sync { keys.count }
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 이미지의 메모리 비용 계산
    /// - Parameter image: 이미지
    /// - Returns: 예상 메모리 사용량 (바이트)
    private func imageCost(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}

// MARK: - SwiftUI Image 확장
extension ImageCache {
    
    /// SwiftUI Image로 변환하여 반환
    /// - Parameter key: 이미지 식별자
    /// - Returns: SwiftUI Image (없으면 nil)
    func swiftUIImage(forKey key: String) -> Image? {
        guard let uiImage = image(forKey: key) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    /// SwiftUI Image의 UIImage 버전을 캐시에 저장
    /// - Parameters:
    ///   - uiImage: 저장할 UIImage
    ///   - key: 이미지 식별자
    func cacheUIImage(_ uiImage: UIImage, forKey key: String) {
        setImage(uiImage, forKey: key)
    }
}

// MARK: - 캐시 가능 프로토콜
/// 캐시 키 생성을 위한 프로토콜
protocol CacheKeyProviding {
    var cacheKey: String { get }
}

// MARK: - MediaItem 캐시 키 확장
extension MediaItem: CacheKeyProviding {
    /// MediaItem의 고유 캐시 키
    var cacheKey: String {
        id.uuidString
    }
    
    /// 썸네일용 캐시 키
    var thumbnailCacheKey: String {
        "\(id.uuidString)_thumb"
    }
}
