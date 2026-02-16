import Network
import Security

extension SecureChatClient {
    // 연결된 TLS 정보 확인
    func logTLSInfo() {
        guard let metadata = connection?.metadata(definition: NWProtocolTLS.definition) as? NWProtocolTLS.Metadata else {
            print("TLS 메타데이터 없음")
            return
        }
        
        // Security 프레임워크의 메타데이터 접근
        let secMetadata = metadata.securityProtocolMetadata
        
        // TLS 버전 확인
        let tlsVersion = sec_protocol_metadata_get_negotiated_tls_protocol_version(secMetadata)
        switch tlsVersion {
        case .TLSv13:
            print("TLS 버전: 1.3")
        case .TLSv12:
            print("TLS 버전: 1.2")
        default:
            print("TLS 버전: \(tlsVersion)")
        }
        
        // 암호화 스위트 확인
        let ciphersuite = sec_protocol_metadata_get_negotiated_tls_ciphersuite(secMetadata)
        print("암호화 스위트: \(ciphersuite)")
        
        // 서버 이름 확인
        if let serverName = sec_protocol_metadata_get_server_name(secMetadata) {
            print("서버 이름: \(String(cString: serverName))")
        }
    }
}
