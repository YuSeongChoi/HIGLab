import Network
import Security

class CertificatePinning {
    // 앱 번들에 포함된 인증서 로드
    private let pinnedCertificates: [Data]
    
    init() {
        // 번들에서 .cer 파일들 로드
        var certs: [Data] = []
        
        if let certURL = Bundle.main.url(forResource: "server", withExtension: "cer"),
           let certData = try? Data(contentsOf: certURL) {
            certs.append(certData)
        }
        
        pinnedCertificates = certs
    }
    
    func createPinnedParameters() -> NWParameters {
        let tlsOptions = NWProtocolTLS.Options()
        
        sec_protocol_options_set_verify_block(
            tlsOptions.securityProtocolOptions,
            { [weak self] (_, trust, complete) in
                guard let self = self else {
                    complete(false)
                    return
                }
                
                let secTrust = sec_trust_copy_ref(trust).takeRetainedValue()
                
                // 인증서 체인에서 고정된 인증서 찾기
                let certCount = SecTrustGetCertificateCount(secTrust)
                
                for i in 0..<certCount {
                    guard let cert = SecTrustGetCertificateAtIndex(secTrust, i) else {
                        continue
                    }
                    
                    let certData = SecCertificateCopyData(cert) as Data
                    
                    if self.pinnedCertificates.contains(certData) {
                        print("인증서 피닝 성공")
                        complete(true)
                        return
                    }
                }
                
                print("인증서 피닝 실패 - 알 수 없는 인증서")
                complete(false)
            },
            DispatchQueue.global()
        )
        
        return NWParameters(tls: tlsOptions, tcp: NWProtocolTCP.Options())
    }
}
