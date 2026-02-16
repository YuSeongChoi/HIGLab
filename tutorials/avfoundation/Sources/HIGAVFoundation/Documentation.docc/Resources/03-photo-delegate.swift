import AVFoundation
import UIKit

/// 사진 촬영 완료를 처리하는 델리게이트
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    /// 촬영 완료 시 호출될 콜백
    private let completionHandler: (UIImage?) -> Void
    
    init(completionHandler: @escaping (UIImage?) -> Void) {
        self.completionHandler = completionHandler
        super.init()
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    /// 셔터 소리 직후 호출 - UI 피드백에 활용
    func photoOutput(_ output: AVCapturePhotoOutput, 
                     willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // 셔터 애니메이션 등 시각적 피드백
        print("📸 촬영 시작!")
    }
    
    /// 사진 처리 완료 후 호출
    func photoOutput(_ output: AVCapturePhotoOutput, 
                     didFinishProcessingPhoto photo: AVCapturePhoto, 
                     error: Error?) {
        if let error = error {
            print("촬영 실패: \(error.localizedDescription)")
            completionHandler(nil)
            return
        }
        
        // 이미지 데이터 추출
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completionHandler(nil)
            return
        }
        
        completionHandler(image)
    }
}
