import Network
import Security

func createTLSParameters() -> NWParameters {
    // TLS 옵션 설정
    let tlsOptions = NWProtocolTLS.Options()
    
    // Security 프레임워크의 sec_protocol_options 접근
    sec_protocol_options_set_verify_block(
        tlsOptions.securityProtocolOptions,
        { (sec_protocol_metadata, sec_trust, complete) in
            // 인증서 검증 로직
            let trust = sec_trust_copy_ref(sec_trust).takeRetainedValue()
            
            var error: CFError?
            let result = SecTrustEvaluateWithError(trust, &error)
            
            complete(result)
        },
        DispatchQueue.global()
    )
    
    // TCP 옵션과 결합
    let tcpOptions = NWProtocolTCP.Options()
    tcpOptions.enableKeepalive = true
    
    let parameters = NWParameters(tls: tlsOptions, tcp: tcpOptions)
    return parameters
}
