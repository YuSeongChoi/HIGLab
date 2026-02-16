import AVFoundation

// Video Gravity 옵션 비교
//
// 1. resizeAspect (기본값)
//    - 비율 유지
//    - 전체 이미지가 보임
//    - 레터박스/필러박스 발생 가능
//
// 2. resizeAspectFill (추천)
//    - 비율 유지
//    - 화면을 완전히 채움
//    - 이미지 일부가 잘릴 수 있음
//
// 3. resize
//    - 비율 무시
//    - 화면을 완전히 채움
//    - 이미지 왜곡 발생

enum VideoGravityExample {
    static func demonstrateGravity() {
        let previewLayer = AVCaptureVideoPreviewLayer()
        
        // 비율 유지, 레터박스 허용
        previewLayer.videoGravity = .resizeAspect
        
        // 비율 유지, 화면 채움 (가장 많이 사용)
        previewLayer.videoGravity = .resizeAspectFill
        
        // 비율 무시, 화면 채움 (왜곡됨)
        previewLayer.videoGravity = .resize
    }
}
