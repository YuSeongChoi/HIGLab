import ShazamKit

// SHCatalog - 매칭 대상 데이터베이스

// 1. Shazam 공식 카탈로그 (네트워크 필요)
// SHManagedSession이나 SHSession()은 기본으로 공식 카탈로그 사용

// 2. 커스텀 카탈로그 (오프라인 가능)
func createCustomCatalog() throws -> SHCustomCatalog {
    let catalog = SHCustomCatalog()
    
    // 시그니처와 메타데이터 추가
    let signature = try loadSignature()
    let mediaItem = SHMediaItem(properties: [
        .title: "My Custom Audio",
        .artist: "My Brand"
    ])
    
    try catalog.add(signature, representing: [mediaItem])
    
    return catalog
}

func loadSignature() throws -> SHSignature {
    // 파일에서 시그니처 로드
    let url = Bundle.main.url(forResource: "reference", withExtension: "shazamsignature")!
    return try SHSignature(contentsOf: url)
}
