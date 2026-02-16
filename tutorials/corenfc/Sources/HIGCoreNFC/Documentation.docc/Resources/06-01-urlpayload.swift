import CoreNFC
import Foundation

class NFCWriter {
    
    /// URL 레코드 생성
    func createURLPayload(url: URL) -> NFCNDEFPayload? {
        // 편의 생성자 사용 (자동으로 프리픽스 최적화)
        return NFCNDEFPayload.wellKnownTypeURIPayload(url: url)
    }
    
    // 사용 예시
    func createURLRecord() {
        // 웹 URL
        if let url = URL(string: "https://apple.com"),
           let payload = createURLPayload(url: url) {
            print("URL 페이로드 생성 완료: \(payload.payload.count) bytes")
        }
        
        // 앱 딥링크
        if let deepLink = URL(string: "myapp://product/12345"),
           let payload = createURLPayload(url: deepLink) {
            print("딥링크 페이로드 생성 완료")
        }
        
        // 전화번호
        if let tel = URL(string: "tel:+821012345678"),
           let payload = createURLPayload(url: tel) {
            print("전화번호 페이로드 생성 완료")
        }
    }
}
