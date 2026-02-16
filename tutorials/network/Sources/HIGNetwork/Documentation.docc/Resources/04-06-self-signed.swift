import Network
import Security

// ⚠️ 경고: 개발 환경에서만 사용!
// 프로덕션에서는 절대 사용하지 마세요.

func createDevParameters() -> NWParameters {
    let tlsOptions = NWProtocolTLS.Options()
    
    // 모든 인증서를 신뢰 (위험!)
    sec_protocol_options_set_verify_block(
        tlsOptions.securityProtocolOptions,
        { (_, _, complete) in
            // 검증 없이 항상 신뢰
            complete(true)
        },
        DispatchQueue.global()
    )
    
    return NWParameters(tls: tlsOptions, tcp: NWProtocolTCP.Options())
}

// 안전한 대안: 특정 자체 서명 인증서만 신뢰
func createPinnedParameters(trustedCertData: Data) -> NWParameters {
    let tlsOptions = NWProtocolTLS.Options()
    
    sec_protocol_options_set_verify_block(
        tlsOptions.securityProtocolOptions,
        { (_, trust, complete) in
            let secTrust = sec_trust_copy_ref(trust).takeRetainedValue()
            
            // 서버 인증서 가져오기
            guard let serverCert = SecTrustGetCertificateAtIndex(secTrust, 0) else {
                complete(false)
                return
            }
            
            // 저장된 인증서와 비교
            let serverCertData = SecCertificateCopyData(serverCert) as Data
            let trusted = serverCertData == trustedCertData
            
            complete(trusted)
        },
        DispatchQueue.global()
    )
    
    return NWParameters(tls: tlsOptions, tcp: NWProtocolTCP.Options())
}
