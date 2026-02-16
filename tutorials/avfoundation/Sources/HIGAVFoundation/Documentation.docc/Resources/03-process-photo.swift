import AVFoundation
import UIKit

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private let completionHandler: (UIImage?) -> Void
    
    init(completionHandler: @escaping (UIImage?) -> Void) {
        self.completionHandler = completionHandler
        super.init()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, 
                     willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // 셔터 애니메이션
    }
    
    // MARK: - Process Captured Photo
    
    func photoOutput(_ output: AVCapturePhotoOutput, 
                     didFinishProcessingPhoto photo: AVCapturePhoto, 
                     error: Error?) {
        if let error = error {
            print("촬영 실패: \(error.localizedDescription)")
            completionHandler(nil)
            return
        }
        
        // 이미지 데이터 추출
        guard let imageData = photo.fileDataRepresentation() else {
            print("이미지 데이터를 추출할 수 없습니다.")
            completionHandler(nil)
            return
        }
        
        // UIImage로 변환
        guard let image = UIImage(data: imageData) else {
            print("이미지 변환 실패")
            completionHandler(nil)
            return
        }
        
        // 메타데이터 확인 (선택사항)
        if let metadata = photo.metadata {
            print("📷 촬영 정보:")
            if let exif = metadata["{Exif}"] as? [String: Any] {
                print("  - ISO: \(exif["ISOSpeedRatings"] ?? "N/A")")
                print("  - 셔터 속도: \(exif["ExposureTime"] ?? "N/A")")
            }
        }
        
        completionHandler(image)
    }
}
