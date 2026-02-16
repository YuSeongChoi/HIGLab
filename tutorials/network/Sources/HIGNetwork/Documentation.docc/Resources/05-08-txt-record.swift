import Network

class ChatServer {
    private var listener: NWListener?
    
    func startWithMetadata(name: String, username: String, deviceType: String) throws {
        let parameters = NWParameters.tcp
        
        listener = try NWListener(using: parameters)
        
        // TXT 레코드로 추가 정보 제공
        let txtRecord = NWTXTRecord([
            "username": username,
            "device": deviceType,
            "version": "1.0",
            "status": "online"
        ])
        
        listener?.service = NWListener.Service(
            name: name,
            type: "_p2pchat._tcp",
            domain: nil,
            txtRecord: txtRecord
        )
        
        listener?.start(queue: DispatchQueue.main)
    }
    
    // 런타임에 TXT 레코드 업데이트
    func updateStatus(_ status: String) {
        guard var service = listener?.service else { return }
        
        // 새 TXT 레코드 생성
        var txtRecord = NWTXTRecord()
        txtRecord["status"] = status
        
        // 서비스 업데이트 (리스너 재시작 필요할 수 있음)
        listener?.service = NWListener.Service(
            name: service.name,
            type: service.type,
            domain: service.domain,
            txtRecord: txtRecord
        )
    }
}
