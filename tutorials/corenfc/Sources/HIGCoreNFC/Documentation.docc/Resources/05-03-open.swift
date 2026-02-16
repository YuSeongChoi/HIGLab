import CoreNFC
import UIKit

class URLHandler {
    
    func handleURLRecord(_ record: NFCNDEFPayload) {
        guard let url = record.wellKnownTypeURIPayload() else {
            print("URL을 추출할 수 없습니다.")
            return
        }
        
        print("감지된 URL: \(url)")
        
        // URL 스킴에 따른 처리
        switch url.scheme {
        case "http", "https":
            openInSafari(url)
            
        case "tel":
            makePhoneCall(url)
            
        case "mailto":
            openMail(url)
            
        default:
            // 앱 커스텀 스킴 또는 Universal Link
            openURL(url)
        }
    }
    
    private func openInSafari(_ url: URL) {
        DispatchQueue.main.async {
            UIApplication.shared.open(url) { success in
                print(success ? "Safari에서 열림" : "Safari 열기 실패")
            }
        }
    }
    
    private func makePhoneCall(_ url: URL) {
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
    
    private func openMail(_ url: URL) {
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
    
    private func openURL(_ url: URL) {
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("이 URL을 열 수 없습니다: \(url)")
            }
        }
    }
}
