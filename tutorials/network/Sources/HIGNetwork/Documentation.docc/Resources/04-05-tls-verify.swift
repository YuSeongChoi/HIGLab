import Network
import Security

func createCustomVerifyParameters() -> NWParameters {
    let tlsOptions = NWProtocolTLS.Options()
    
    // 커스텀 인증서 검증
    sec_protocol_options_set_verify_block(
        tlsOptions.securityProtocolOptions,
        { (metadata, trust, complete) in
            let secTrust = sec_trust_copy_ref(trust).takeRetainedValue()
            
            // 1. 기본 시스템 검증
            var error: CFError?
            let systemTrusted = SecTrustEvaluateWithError(secTrust, &error)
            
            if !systemTrusted {
                print("시스템 인증서 검증 실패: \(error?.localizedDescription ?? "알 수 없음")")
            }
            
            // 2. 호스트 이름 확인 (선택)
            // SecTrustSetPolicies로 호스트 검증 정책 추가 가능
            
            // 3. 인증서 체인 확인
            let certCount = SecTrustGetCertificateCount(secTrust)
            print("인증서 체인: \(certCount)개")
            
            complete(systemTrusted)
        },
        DispatchQueue.global()
    )
    
    return NWParameters(tls: tlsOptions, tcp: NWProtocolTCP.Options())
}
