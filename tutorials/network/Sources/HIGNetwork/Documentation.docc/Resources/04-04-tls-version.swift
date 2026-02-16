import Network
import Security

func createSecureTLSParameters() -> NWParameters {
    let tlsOptions = NWProtocolTLS.Options()
    
    // 최소 TLS 버전 설정 (TLS 1.2 이상 권장)
    sec_protocol_options_set_min_tls_protocol_version(
        tlsOptions.securityProtocolOptions,
        .TLSv12
    )
    
    // 최대 TLS 버전 설정
    sec_protocol_options_set_max_tls_protocol_version(
        tlsOptions.securityProtocolOptions,
        .TLSv13
    )
    
    // 특정 암호화 스위트 강제 (선택사항)
    // sec_protocol_options_append_tls_ciphersuite(
    //     tlsOptions.securityProtocolOptions,
    //     tls_ciphersuite_t(rawValue: UInt16(TLS_AES_256_GCM_SHA384))!
    // )
    
    let tcpOptions = NWProtocolTCP.Options()
    return NWParameters(tls: tlsOptions, tcp: tcpOptions)
}
