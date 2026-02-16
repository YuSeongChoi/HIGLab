import CallKit
import UIKit

func createProviderConfiguration() -> CXProviderConfiguration {
    let configuration = CXProviderConfiguration()
    
    // 앱 아이콘 설정 (40x40 포인트, 마스크 가능)
    // 흰색 아이콘을 사용 (시스템이 색상 적용)
    if let iconImage = UIImage(named: "CallKitIcon") {
        configuration.iconTemplateImageData = iconImage.pngData()
    }
    
    return configuration
}

// 아이콘 요구사항:
// - 크기: 40x40 포인트 (@2x = 80x80, @3x = 120x120 픽셀)
// - 형식: PNG (투명 배경)
// - 색상: 단색 (시스템이 색상 변환)
// - Template 렌더링 모드 사용
