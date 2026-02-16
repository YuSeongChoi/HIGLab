import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

// MARK: - CoreImage 기본 설정
struct CoreImageSetup {
    // CIContext는 생성 비용이 높으므로 재사용
    static let sharedContext = CIContext(options: [
        .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
        .cacheIntermediates: true
    ])
    
    // Metal 기반 CIContext (최대 성능)
    static let metalContext: CIContext = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return CIContext()
        }
        return CIContext(mtlDevice: device)
    }()
}
