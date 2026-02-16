import Vision

extension QRScanner {
    
    enum QRContentType {
        case url(URL)
        case text(String)
        case email(String)
        case phone(String)
        case wifi(ssid: String, password: String?)
        case unknown(String)
    }
    
    func parseQRContent(_ payload: String) -> QRContentType {
        // URL 확인
        if let url = URL(string: payload),
           url.scheme != nil {
            return .url(url)
        }
        
        // 이메일 확인
        if payload.lowercased().hasPrefix("mailto:") {
            let email = String(payload.dropFirst(7))
            return .email(email)
        }
        
        // 전화번호 확인
        if payload.lowercased().hasPrefix("tel:") {
            let phone = String(payload.dropFirst(4))
            return .phone(phone)
        }
        
        // WiFi 설정 확인 (WIFI:S:ssid;P:password;;)
        if payload.uppercased().hasPrefix("WIFI:") {
            let components = parseWiFi(payload)
            return .wifi(ssid: components.ssid, password: components.password)
        }
        
        // 일반 텍스트
        if payload.count > 0 {
            return .text(payload)
        }
        
        return .unknown(payload)
    }
    
    private func parseWiFi(_ payload: String) -> (ssid: String, password: String?) {
        var ssid = ""
        var password: String?
        
        let components = payload.dropFirst(5).components(separatedBy: ";")
        for component in components {
            if component.hasPrefix("S:") {
                ssid = String(component.dropFirst(2))
            } else if component.hasPrefix("P:") {
                password = String(component.dropFirst(2))
            }
        }
        
        return (ssid, password)
    }
}
