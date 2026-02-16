import Network
import Security

func createDTLSParameters() -> NWParameters {
    let dtlsOptions = NWProtocolTLS.Options()
    
    // DTLS 1.2 이상
    sec_protocol_options_set_min_tls_protocol_version(
        dtlsOptions.securityProtocolOptions,
        .DTLSv12
    )
    
    // 인증서 검증 (TLS와 동일)
    sec_protocol_options_set_verify_block(
        dtlsOptions.securityProtocolOptions,
        { (_, trust, complete) in
            let secTrust = sec_trust_copy_ref(trust).takeRetainedValue()
            var error: CFError?
            let result = SecTrustEvaluateWithError(secTrust, &error)
            complete(result)
        },
        DispatchQueue.global()
    )
    
    let udpOptions = NWProtocolUDP.Options()
    
    return NWParameters(dtls: dtlsOptions, udp: udpOptions)
}

// DTLS vs TLS 차이점:
// - DTLS는 패킷 순서 독립적
// - DTLS는 패킷 손실 허용
// - DTLS 핸드셰이크는 UDP 특성에 맞게 설계됨
