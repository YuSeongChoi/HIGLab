import AVFoundation
import UIKit
import Photos

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private let completionHandler: (UIImage?) -> Void
    private let autoSaveToLibrary: Bool
    
    init(autoSave: Bool = true, completionHandler: @escaping (UIImage?) -> Void) {
        self.autoSaveToLibrary = autoSave
        self.completionHandler = completionHandler
        super.init()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, 
                     didFinishProcessingPhoto photo: AVCapturePhoto, 
                     error: Error?) {
        if let error = error {
            print("촬영 실패: \(error.localizedDescription)")
            completionHandler(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completionHandler(nil)
            return
        }
        
        // 자동 저장 활성화 시 사진 라이브러리에 저장
        if autoSaveToLibrary {
            Task {
                do {
                    try await PhotoLibraryService.savePhotoData(imageData)
                    print("✅ 사진이 앨범에 저장되었습니다.")
                } catch {
                    print("❌ 저장 실패: \(error.localizedDescription)")
                }
            }
        }
        
        completionHandler(image)
    }
}
