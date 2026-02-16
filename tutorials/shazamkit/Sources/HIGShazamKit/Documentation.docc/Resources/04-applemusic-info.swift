import ShazamKit
import UIKit

// Apple Music 연동 정보
struct AppleMusicInfo {
    let item: SHMatchedMediaItem
    
    /// Apple Music 곡 ID
    var appleMusicID: String? {
        item.appleMusicID
    }
    
    /// Apple Music에서 곡 열기 URL
    var appleMusicURL: URL? {
        item.appleMusicURL
    }
    
    /// 웹에서 열기 URL (Shazam 웹페이지)
    var webURL: URL? {
        item.webURL
    }
    
    /// Apple Music에서 곡 열기
    func openInAppleMusic() {
        guard let url = appleMusicURL else { return }
        UIApplication.shared.open(url)
    }
    
    /// 웹 브라우저에서 열기
    func openInBrowser() {
        guard let url = webURL else { return }
        UIApplication.shared.open(url)
    }
}
