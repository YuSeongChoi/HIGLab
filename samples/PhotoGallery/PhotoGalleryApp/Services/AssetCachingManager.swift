import Photos
import UIKit
import PhotosUI
import SwiftUI

// MARK: - 에셋 캐싱 매니저
/// PHCachingImageManager를 래핑하여 이미지/비디오 캐싱 및 로딩 제공
/// 스크롤 성능 최적화를 위한 프리페칭 지원
final class AssetCachingManager: ObservableObject {
    
    // MARK: - 싱글톤
    
    static let shared = AssetCachingManager()
    
    // MARK: - 캐싱 이미지 매니저
    
    /// PHCachingImageManager 인스턴스 (프리페칭 지원)
    private let cachingManager = PHCachingImageManager()
    
    /// 일반 이미지 매니저 (고품질 이미지 요청용)
    private let imageManager = PHImageManager.default()
    
    // MARK: - 메모리 캐시
    
    /// 썸네일 캐시
    private let thumbnailCache = NSCache<NSString, UIImage>()
    
    /// 전체 크기 이미지 캐시
    private let fullSizeCache = NSCache<NSString, UIImage>()
    
    /// 라이브 포토 캐시
    private let livePhotoCache = NSCache<NSString, PHLivePhoto>()
    
    // MARK: - 캐시 설정
    
    /// 썸네일 크기
    let thumbnailSize = CGSize(width: 200, height: 200)
    
    /// 미리보기 크기
    let previewSize = CGSize(width: 600, height: 600)
    
    // MARK: - 상태
    
    /// 현재 캐싱 중인 에셋
    private var cachedAssets: [PHAsset] = []
    
    /// 요청 ID 딕셔너리 (취소용)
    private var requestIDs: [String: PHImageRequestID] = [:]
    
    /// 동기화 큐
    private let queue = DispatchQueue(label: "com.photogallery.caching", attributes: .concurrent)
    
    // MARK: - 초기화
    
    private init() {
        // 캐시 제한 설정
        thumbnailCache.countLimit = 500
        thumbnailCache.totalCostLimit = 100 * 1024 * 1024  // 100MB
        
        fullSizeCache.countLimit = 20
        fullSizeCache.totalCostLimit = 200 * 1024 * 1024  // 200MB
        
        livePhotoCache.countLimit = 10
        
        // 메모리 경고 시 캐시 정리
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCaches),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        // 캐싱 매니저 설정
        cachingManager.allowsCachingHighQualityImages = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopCachingAll()
    }
    
    // MARK: - 썸네일 로드
    
    /// 썸네일 이미지 로드
    /// - Parameters:
    ///   - asset: 대상 에셋
    ///   - targetSize: 목표 크기 (기본값: thumbnailSize)
    /// - Returns: UIImage
    func loadThumbnail(for asset: PHAsset, targetSize: CGSize? = nil) async -> UIImage? {
        let size = targetSize ?? thumbnailSize
        let cacheKey = "\(asset.localIdentifier)_thumb_\(Int(size.width))x\(Int(size.height))" as NSString
        
        // 캐시 확인
        if let cached = thumbnailCache.object(forKey: cacheKey) {
            return cached
        }
        
        // 이미지 요청 옵션
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        return await withCheckedContinuation { continuation in
            let requestID = cachingManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { [weak self] image, info in
                // 취소되거나 저품질 이미지인 경우 무시
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                
                if isCancelled {
                    continuation.resume(returning: nil)
                    return
                }
                
                if let image = image, !isDegraded {
                    // 캐시에 저장
                    let cost = image.jpegData(compressionQuality: 0.5)?.count ?? 0
                    self?.thumbnailCache.setObject(image, forKey: cacheKey, cost: cost)
                }
                
                continuation.resume(returning: image)
            }
            
            // 요청 ID 저장
            queue.async(flags: .barrier) { [weak self] in
                self?.requestIDs[asset.localIdentifier] = requestID
            }
        }
    }
    
    /// SwiftUI Image로 썸네일 로드
    /// - Parameter asset: 대상 에셋
    /// - Returns: SwiftUI Image
    func loadThumbnailImage(for asset: PHAsset) async -> Image? {
        guard let uiImage = await loadThumbnail(for: asset) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    // MARK: - 전체 크기 이미지 로드
    
    /// 전체 크기 이미지 로드
    /// - Parameters:
    ///   - asset: 대상 에셋
    ///   - targetSize: 목표 크기 (기본값: PHImageManagerMaximumSize)
    /// - Returns: UIImage
    func loadFullSizeImage(for asset: PHAsset, targetSize: CGSize? = nil) async -> UIImage? {
        let size = targetSize ?? PHImageManagerMaximumSize
        let cacheKey = "\(asset.localIdentifier)_full" as NSString
        
        // 캐시 확인
        if let cached = fullSizeCache.object(forKey: cacheKey) {
            return cached
        }
        
        // 이미지 요청 옵션
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        return await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: options
            ) { [weak self] image, info in
                let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                
                if isCancelled {
                    continuation.resume(returning: nil)
                    return
                }
                
                if let image = image {
                    // 캐시에 저장
                    let cost = Int(image.size.width * image.size.height * 4)
                    self?.fullSizeCache.setObject(image, forKey: cacheKey, cost: cost)
                }
                
                continuation.resume(returning: image)
            }
        }
    }
    
    // MARK: - 라이브 포토 로드
    
    /// 라이브 포토 로드
    /// - Parameters:
    ///   - asset: 대상 에셋 (라이브 포토)
    ///   - targetSize: 목표 크기
    /// - Returns: PHLivePhoto
    func loadLivePhoto(for asset: PHAsset, targetSize: CGSize? = nil) async -> PHLivePhoto? {
        let size = targetSize ?? PHImageManagerMaximumSize
        let cacheKey = "\(asset.localIdentifier)_live" as NSString
        
        // 캐시 확인
        if let cached = livePhotoCache.object(forKey: cacheKey) {
            return cached
        }
        
        // 라이브 포토 요청 옵션
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            imageManager.requestLivePhoto(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: options
            ) { [weak self] livePhoto, info in
                let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                
                if isCancelled || isDegraded {
                    if !isDegraded {
                        continuation.resume(returning: nil)
                    }
                    return
                }
                
                if let livePhoto = livePhoto {
                    self?.livePhotoCache.setObject(livePhoto, forKey: cacheKey)
                }
                
                continuation.resume(returning: livePhoto)
            }
        }
    }
    
    // MARK: - 비디오 로드
    
    /// 비디오 AVPlayerItem 로드
    /// - Parameters:
    ///   - asset: 대상 에셋 (비디오)
    ///   - options: 요청 옵션
    /// - Returns: AVPlayerItem
    func loadVideo(for asset: PHAsset) async -> AVPlayerItem? {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            imageManager.requestPlayerItem(
                forVideo: asset,
                options: options
            ) { playerItem, info in
                let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                
                if isCancelled {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: playerItem)
            }
        }
    }
    
    /// 비디오 AVAsset 로드
    /// - Parameter asset: 대상 에셋 (비디오)
    /// - Returns: AVAsset
    func loadAVAsset(for asset: PHAsset) async -> AVAsset? {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            imageManager.requestAVAsset(
                forVideo: asset,
                options: options
            ) { avAsset, _, info in
                let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                
                if isCancelled {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: avAsset)
            }
        }
    }
    
    // MARK: - 프리페칭
    
    /// 에셋 프리페칭 시작
    /// - Parameters:
    ///   - assets: 프리페칭할 에셋 배열
    ///   - targetSize: 목표 크기
    func startCaching(assets: [PHAsset], targetSize: CGSize? = nil) {
        let size = targetSize ?? thumbnailSize
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        cachingManager.startCachingImages(
            for: assets,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        )
        
        queue.async(flags: .barrier) { [weak self] in
            self?.cachedAssets.append(contentsOf: assets)
        }
    }
    
    /// 에셋 프리페칭 중지
    /// - Parameters:
    ///   - assets: 프리페칭 중지할 에셋 배열
    ///   - targetSize: 목표 크기
    func stopCaching(assets: [PHAsset], targetSize: CGSize? = nil) {
        let size = targetSize ?? thumbnailSize
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        
        cachingManager.stopCachingImages(
            for: assets,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        )
        
        let assetIds = Set(assets.map { $0.localIdentifier })
        queue.async(flags: .barrier) { [weak self] in
            self?.cachedAssets.removeAll { assetIds.contains($0.localIdentifier) }
        }
    }
    
    /// 모든 프리페칭 중지
    func stopCachingAll() {
        cachingManager.stopCachingImagesForAllAssets()
        
        queue.async(flags: .barrier) { [weak self] in
            self?.cachedAssets.removeAll()
        }
    }
    
    // MARK: - 요청 취소
    
    /// 특정 에셋의 이미지 요청 취소
    /// - Parameter asset: 대상 에셋
    func cancelRequest(for asset: PHAsset) {
        queue.sync {
            if let requestID = requestIDs[asset.localIdentifier] {
                cachingManager.cancelImageRequest(requestID)
            }
        }
        
        queue.async(flags: .barrier) { [weak self] in
            self?.requestIDs.removeValue(forKey: asset.localIdentifier)
        }
    }
    
    // MARK: - 캐시 관리
    
    /// 모든 캐시 정리
    @objc func clearCaches() {
        thumbnailCache.removeAllObjects()
        fullSizeCache.removeAllObjects()
        livePhotoCache.removeAllObjects()
    }
    
    /// 특정 에셋의 캐시 정리
    /// - Parameter asset: 대상 에셋
    func clearCache(for asset: PHAsset) {
        let thumbKey = "\(asset.localIdentifier)_thumb_\(Int(thumbnailSize.width))x\(Int(thumbnailSize.height))" as NSString
        let fullKey = "\(asset.localIdentifier)_full" as NSString
        let liveKey = "\(asset.localIdentifier)_live" as NSString
        
        thumbnailCache.removeObject(forKey: thumbKey)
        fullSizeCache.removeObject(forKey: fullKey)
        livePhotoCache.removeObject(forKey: liveKey)
    }
}

// MARK: - 이미지 데이터 로드
extension AssetCachingManager {
    
    /// 이미지 데이터 로드 (공유, 저장 등에 사용)
    /// - Parameter asset: 대상 에셋
    /// - Returns: 이미지 데이터
    func loadImageData(for asset: PHAsset) async -> Data? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        return await withCheckedContinuation { continuation in
            imageManager.requestImageDataAndOrientation(
                for: asset,
                options: options
            ) { data, _, _, info in
                let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                
                if isCancelled {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: data)
            }
        }
    }
}

// MARK: - 편집용 입력 로드
extension AssetCachingManager {
    
    /// PHContentEditingInput 로드 (편집용)
    /// - Parameter asset: 대상 에셋
    /// - Returns: PHContentEditingInput
    func loadContentEditingInput(for asset: PHAsset) async -> PHContentEditingInput? {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        options.canHandleAdjustmentData = { _ in true }
        
        return await withCheckedContinuation { continuation in
            asset.requestContentEditingInput(with: options) { input, info in
                continuation.resume(returning: input)
            }
        }
    }
}
