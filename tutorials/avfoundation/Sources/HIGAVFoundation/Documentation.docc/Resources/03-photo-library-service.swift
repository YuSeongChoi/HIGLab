import Photos
import UIKit

/// 사진 라이브러리 저장 서비스
class PhotoLibraryService {
    
    // MARK: - Save Photo
    
    /// 사진을 사진 앨범에 저장
    static func savePhoto(_ image: UIImage) async throws {
        // 권한 확인
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized || status == .limited else {
            throw PhotoLibraryError.notAuthorized
        }
        
        // 사진 저장
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
    
    /// Data로부터 사진 저장 (HEIF 등 원본 포맷 유지)
    static func savePhotoData(_ data: Data) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized || status == .limited else {
            throw PhotoLibraryError.notAuthorized
        }
        
        try await PHPhotoLibrary.shared().performChanges {
            let options = PHAssetResourceCreationOptions()
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data, options: options)
        }
    }
}

enum PhotoLibraryError: LocalizedError {
    case notAuthorized
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "사진 라이브러리 접근 권한이 없습니다."
        }
    }
}
