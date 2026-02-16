import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

// MARK: - CIImage & CIContext 핵심
extension CIImage {
    /// UIImage로 변환
    func toUIImage(context: CIContext = CoreImageSetup.sharedContext) -> UIImage? {
        guard let cgImage = context.createCGImage(self, from: extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    /// 특정 크기로 리사이즈
    func resized(to size: CGSize) -> CIImage {
        let scaleX = size.width / extent.width
        let scaleY = size.height / extent.height
        return transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    }
}

// MARK: - 필터 적용 예시
func applySepia(to image: CIImage, intensity: Float = 0.8) -> CIImage {
    let filter = CIFilter.sepiaTone()
    filter.inputImage = image
    filter.intensity = intensity
    return filter.outputImage ?? image
}
