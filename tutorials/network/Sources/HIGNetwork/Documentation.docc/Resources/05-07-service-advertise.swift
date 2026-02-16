import Network

class ChatServer {
    private var listener: NWListener?
    
    func startWithBonjour(name: String) throws {
        let parameters = NWParameters.tcp
        
        listener = try NWListener(using: parameters)
        
        // Bonjour 서비스 설정
        listener?.service = NWListener.Service(
            name: name,           // 서비스 이름 (예: "John's Mac")
            type: "_p2pchat._tcp" // 서비스 타입
        )
        
        // 서비스 상태 변경 핸들러
        listener?.serviceRegistrationUpdateHandler = { serviceChange in
            switch serviceChange {
            case .add(let endpoint):
                switch endpoint {
                case .service(let name, let type, let domain, _):
                    print("서비스 등록됨: \(name).\(type).\(domain)")
                default:
                    break
                }
                
            case .remove(let endpoint):
                print("서비스 제거됨: \(endpoint)")
                
            @unknown default:
                break
            }
        }
        
        listener?.stateUpdateHandler = { state in
            if case .ready = state {
                print("Bonjour 서비스 광고 시작")
            }
        }
        
        listener?.start(queue: DispatchQueue.main)
    }
}
