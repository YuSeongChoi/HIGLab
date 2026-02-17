import AVFoundation
import UIKit

// MARK: - 사진 캡처 델리게이트
// AVCapturePhotoCaptureDelegate를 구현하여 사진 촬영 결과를 처리합니다.

/// 사진 캡처 결과 타입
typealias PhotoCaptureCompletion = (Result<UIImage, Error>) -> Void

/// 사진 캡처 델리게이트
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Properties
    
    /// 캡처 완료 핸들러
    private let completion: PhotoCaptureCompletion
    
    // MARK: - Initialization
    
    /// 완료 핸들러와 함께 초기화
    /// - Parameter completion: 캡처 결과를 전달받을 클로저
    init(completion: @escaping PhotoCaptureCompletion) {
        self.completion = completion
        super.init()
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    /// 사진 촬영 완료 시 호출
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        // 에러 처리
        if let error = error {
            completion(.failure(CaptureError.processingFailed(error.localizedDescription)))
            return
        }
        
        // 이미지 데이터 추출
        guard let imageData = photo.fileDataRepresentation() else {
            completion(.failure(CaptureError.noImageData))
            return
        }
        
        // UIImage 생성
        guard let image = UIImage(data: imageData) else {
            completion(.failure(CaptureError.invalidImageData))
            return
        }
        
        // 이미지 방향 보정
        let correctedImage = fixImageOrientation(image)
        
        completion(.success(correctedImage))
    }
    
    /// 촬영 시작 시 호출 (셔터 사운드 타이밍)
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        // 필요시 UI 피드백 (플래시 등)
    }
    
    /// 촬영 종료 시 호출
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
        error: Error?
    ) {
        // 캡처 완전 종료 처리
    }
    
    // MARK: - Private Methods
    
    /// 이미지 방향 보정
    /// - Parameter image: 원본 이미지
    /// - Returns: 방향이 보정된 이미지
    private func fixImageOrientation(_ image: UIImage) -> UIImage {
        // 이미 올바른 방향이면 그대로 반환
        guard image.imageOrientation != .up else { return image }
        
        // 그래픽 컨텍스트에서 이미지를 다시 그려 방향 보정
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? image
    }
}

// MARK: - 캡처 에러 정의

enum CaptureError: LocalizedError {
    case processingFailed(String)
    case noImageData
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .processingFailed(let reason):
            "사진 처리 실패: \(reason)"
        case .noImageData:
            "이미지 데이터를 추출할 수 없습니다"
        case .invalidImageData:
            "이미지를 생성할 수 없습니다"
        }
    }
}
