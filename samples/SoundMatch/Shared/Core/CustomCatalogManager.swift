import Foundation
import ShazamKit

// MARK: - CustomCatalogError
/// 커스텀 카탈로그 오류 타입

enum CustomCatalogError: LocalizedError {
    case catalogCreationFailed          // 카탈로그 생성 실패
    case signatureAdditionFailed        // 시그니처 추가 실패
    case catalogSaveFailed(Error)       // 카탈로그 저장 실패
    case catalogLoadFailed(Error)       // 카탈로그 로드 실패
    case invalidSignature               // 유효하지 않은 시그니처
    case duplicateEntry                 // 중복 항목
    case catalogNotFound                // 카탈로그 없음
    case exportFailed(Error)            // 내보내기 실패
    
    var errorDescription: String? {
        switch self {
        case .catalogCreationFailed:
            return "카탈로그를 생성할 수 없습니다."
        case .signatureAdditionFailed:
            return "시그니처를 카탈로그에 추가할 수 없습니다."
        case .catalogSaveFailed(let error):
            return "카탈로그 저장 실패: \(error.localizedDescription)"
        case .catalogLoadFailed(let error):
            return "카탈로그 로드 실패: \(error.localizedDescription)"
        case .invalidSignature:
            return "유효하지 않은 시그니처입니다."
        case .duplicateEntry:
            return "이미 존재하는 항목입니다."
        case .catalogNotFound:
            return "카탈로그를 찾을 수 없습니다."
        case .exportFailed(let error):
            return "내보내기 실패: \(error.localizedDescription)"
        }
    }
}

// MARK: - CatalogItem
/// 카탈로그에 저장될 항목 정보

struct CatalogItem: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let genres: [String]
    let artworkURLString: String?
    let customProperties: [String: String]
    let createdAt: Date
    let signatureDataFileName: String  // 시그니처 파일 참조
    
    var artworkURL: URL? {
        guard let urlString = artworkURLString else { return nil }
        return URL(string: urlString)
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        genres: [String] = [],
        artworkURL: URL? = nil,
        customProperties: [String: String] = [:],
        createdAt: Date = Date(),
        signatureDataFileName: String
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.genres = genres
        self.artworkURLString = artworkURL?.absoluteString
        self.customProperties = customProperties
        self.createdAt = createdAt
        self.signatureDataFileName = signatureDataFileName
    }
}

// MARK: - CatalogMetadata
/// 카탈로그 메타데이터

struct CatalogMetadata: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var createdAt: Date
    var modifiedAt: Date
    var itemCount: Int
    var totalDuration: TimeInterval
    var version: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        itemCount: Int = 0,
        totalDuration: TimeInterval = 0,
        version: Int = 1
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.itemCount = itemCount
        self.totalDuration = totalDuration
        self.version = version
    }
}

// MARK: - CustomCatalogManager
/// SHCustomCatalog를 사용한 커스텀 오디오 카탈로그 관리자
/// 오프라인 매칭을 위한 개인 오디오 라이브러리 구축 지원

@MainActor
@Observable
final class CustomCatalogManager {
    // MARK: - 싱글톤
    static let shared = CustomCatalogManager()
    
    // MARK: - 프로퍼티
    /// 현재 로드된 카탈로그 목록
    private(set) var catalogs: [CatalogMetadata] = []
    
    /// 현재 선택된 카탈로그
    private(set) var currentCatalog: SHCustomCatalog?
    
    /// 현재 카탈로그의 아이템들
    private(set) var currentCatalogItems: [CatalogItem] = []
    
    /// 현재 카탈로그 메타데이터
    private(set) var currentMetadata: CatalogMetadata?
    
    // MARK: - 파일 시스템 경로
    private var catalogsDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let catalogsPath = documentsPath.appendingPathComponent("CustomCatalogs", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: catalogsPath.path) {
            try? FileManager.default.createDirectory(at: catalogsPath, withIntermediateDirectories: true)
        }
        
        return catalogsPath
    }
    
    // MARK: - 초기화
    private init() {
        loadCatalogsList()
    }
    
    // MARK: - 카탈로그 생성
    /// 새 커스텀 카탈로그 생성
    /// - Parameters:
    ///   - name: 카탈로그 이름
    ///   - description: 설명
    /// - Returns: 생성된 카탈로그 메타데이터
    @discardableResult
    func createCatalog(name: String, description: String = "") throws -> CatalogMetadata {
        let catalogId = UUID()
        
        // 카탈로그 디렉토리 생성
        let catalogPath = catalogsDirectory.appendingPathComponent(catalogId.uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: catalogPath, withIntermediateDirectories: true)
        
        // 시그니처 디렉토리 생성
        let signaturesPath = catalogPath.appendingPathComponent("signatures", isDirectory: true)
        try FileManager.default.createDirectory(at: signaturesPath, withIntermediateDirectories: true)
        
        // 메타데이터 생성 및 저장
        let metadata = CatalogMetadata(
            id: catalogId,
            name: name,
            description: description
        )
        
        try saveMetadata(metadata, to: catalogPath)
        
        // 빈 아이템 목록 저장
        try saveItems([], to: catalogPath)
        
        // 목록 갱신
        catalogs.append(metadata)
        
        return metadata
    }
    
    // MARK: - 카탈로그 로드
    /// 카탈로그 로드
    /// - Parameter id: 카탈로그 ID
    func loadCatalog(id: UUID) throws {
        let catalogPath = catalogsDirectory.appendingPathComponent(id.uuidString, isDirectory: true)
        
        guard FileManager.default.fileExists(atPath: catalogPath.path) else {
            throw CustomCatalogError.catalogNotFound
        }
        
        // 메타데이터 로드
        let metadata = try loadMetadata(from: catalogPath)
        currentMetadata = metadata
        
        // 아이템 목록 로드
        let items = try loadItems(from: catalogPath)
        currentCatalogItems = items
        
        // SHCustomCatalog 생성 및 시그니처 추가
        let catalog = SHCustomCatalog()
        
        for item in items {
            if let signature = try? loadSignature(item: item, catalogPath: catalogPath) {
                // 미디어 아이템 생성
                let mediaItem = createMediaItem(from: item)
                
                do {
                    // 시그니처와 미디어 아이템을 카탈로그에 추가
                    try catalog.addReferenceSignature(signature, representing: [mediaItem])
                } catch {
                    print("⚠️ 시그니처 추가 실패: \(item.title) - \(error.localizedDescription)")
                }
            }
        }
        
        currentCatalog = catalog
    }
    
    // MARK: - 항목 추가
    /// 시그니처와 메타데이터를 카탈로그에 추가
    /// - Parameters:
    ///   - signature: 오디오 시그니처
    ///   - title: 곡 제목
    ///   - artist: 아티스트
    ///   - genres: 장르 목록
    ///   - artworkURL: 아트워크 URL
    ///   - customProperties: 커스텀 속성
    func addItem(
        signature: SHSignature,
        title: String,
        artist: String,
        genres: [String] = [],
        artworkURL: URL? = nil,
        customProperties: [String: String] = [:]
    ) throws {
        guard let metadata = currentMetadata else {
            throw CustomCatalogError.catalogNotFound
        }
        
        let catalogPath = catalogsDirectory.appendingPathComponent(metadata.id.uuidString, isDirectory: true)
        
        // 시그니처 파일 저장
        let signatureFileName = "\(UUID().uuidString).shazamsignature"
        let signaturesPath = catalogPath.appendingPathComponent("signatures", isDirectory: true)
        let signaturePath = signaturesPath.appendingPathComponent(signatureFileName)
        
        try signature.dataRepresentation.write(to: signaturePath)
        
        // 아이템 정보 생성
        let item = CatalogItem(
            title: title,
            artist: artist,
            genres: genres,
            artworkURL: artworkURL,
            customProperties: customProperties,
            signatureDataFileName: signatureFileName
        )
        
        // 현재 카탈로그에 추가
        if let catalog = currentCatalog {
            let mediaItem = createMediaItem(from: item)
            try catalog.addReferenceSignature(signature, representing: [mediaItem])
        }
        
        // 아이템 목록 업데이트
        currentCatalogItems.append(item)
        
        // 저장
        try saveItems(currentCatalogItems, to: catalogPath)
        
        // 메타데이터 업데이트
        var updatedMetadata = metadata
        updatedMetadata.modifiedAt = Date()
        updatedMetadata.itemCount = currentCatalogItems.count
        try saveMetadata(updatedMetadata, to: catalogPath)
        currentMetadata = updatedMetadata
        
        // 전체 목록 갱신
        if let index = catalogs.firstIndex(where: { $0.id == metadata.id }) {
            catalogs[index] = updatedMetadata
        }
    }
    
    /// SHRange를 사용하여 특정 시간 범위의 시그니처 추가
    /// - Parameters:
    ///   - signature: 전체 시그니처
    ///   - range: 매칭에 사용할 시간 범위 (SHRange)
    ///   - title: 곡 제목
    ///   - artist: 아티스트
    func addItemWithRange(
        signature: SHSignature,
        range: Range<TimeInterval>,
        title: String,
        artist: String
    ) throws {
        // SHRange 사용하여 시간 범위 설정
        // 참고: SHRange는 매칭 결과에서 사용되며, 
        // 카탈로그에 추가 시에는 전체 시그니처가 사용됨
        
        try addItem(
            signature: signature,
            title: title,
            artist: artist,
            customProperties: [
                "rangeStart": String(range.lowerBound),
                "rangeEnd": String(range.upperBound)
            ]
        )
    }
    
    // MARK: - 항목 삭제
    /// 카탈로그에서 항목 삭제
    /// - Parameter item: 삭제할 항목
    func removeItem(_ item: CatalogItem) throws {
        guard let metadata = currentMetadata else {
            throw CustomCatalogError.catalogNotFound
        }
        
        let catalogPath = catalogsDirectory.appendingPathComponent(metadata.id.uuidString, isDirectory: true)
        
        // 시그니처 파일 삭제
        let signaturesPath = catalogPath.appendingPathComponent("signatures", isDirectory: true)
        let signaturePath = signaturesPath.appendingPathComponent(item.signatureDataFileName)
        try? FileManager.default.removeItem(at: signaturePath)
        
        // 아이템 목록에서 제거
        currentCatalogItems.removeAll { $0.id == item.id }
        
        // 저장
        try saveItems(currentCatalogItems, to: catalogPath)
        
        // 카탈로그 재구성 필요 (SHCustomCatalog는 항목 제거를 지원하지 않음)
        try loadCatalog(id: metadata.id)
        
        // 메타데이터 업데이트
        var updatedMetadata = metadata
        updatedMetadata.modifiedAt = Date()
        updatedMetadata.itemCount = currentCatalogItems.count
        try saveMetadata(updatedMetadata, to: catalogPath)
        currentMetadata = updatedMetadata
    }
    
    // MARK: - 카탈로그 삭제
    /// 카탈로그 삭제
    /// - Parameter id: 카탈로그 ID
    func deleteCatalog(id: UUID) throws {
        let catalogPath = catalogsDirectory.appendingPathComponent(id.uuidString, isDirectory: true)
        
        try FileManager.default.removeItem(at: catalogPath)
        
        // 현재 카탈로그였다면 초기화
        if currentMetadata?.id == id {
            currentCatalog = nil
            currentCatalogItems = []
            currentMetadata = nil
        }
        
        // 목록에서 제거
        catalogs.removeAll { $0.id == id }
    }
    
    // MARK: - 내보내기/가져오기
    /// 카탈로그를 파일로 내보내기
    /// - Parameter id: 카탈로그 ID
    /// - Returns: 내보낸 파일 URL
    func exportCatalog(id: UUID) throws -> URL {
        guard let metadata = catalogs.first(where: { $0.id == id }) else {
            throw CustomCatalogError.catalogNotFound
        }
        
        let catalogPath = catalogsDirectory.appendingPathComponent(id.uuidString, isDirectory: true)
        
        // ZIP으로 압축 (간단 구현: 디렉토리 복사)
        let exportPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(metadata.name).shazamcatalog")
        
        // 기존 파일 삭제
        try? FileManager.default.removeItem(at: exportPath)
        
        // 복사
        try FileManager.default.copyItem(at: catalogPath, to: exportPath)
        
        return exportPath
    }
    
    /// 카탈로그 파일 가져오기
    /// - Parameter url: 카탈로그 파일 URL
    /// - Returns: 가져온 카탈로그 메타데이터
    @discardableResult
    func importCatalog(from url: URL) throws -> CatalogMetadata {
        // 새 ID로 가져오기
        let newId = UUID()
        let catalogPath = catalogsDirectory.appendingPathComponent(newId.uuidString, isDirectory: true)
        
        // 복사
        try FileManager.default.copyItem(at: url, to: catalogPath)
        
        // 메타데이터 로드 및 ID 업데이트
        var metadata = try loadMetadata(from: catalogPath)
        metadata = CatalogMetadata(
            id: newId,
            name: metadata.name + " (가져옴)",
            description: metadata.description,
            createdAt: Date(),
            modifiedAt: Date(),
            itemCount: metadata.itemCount,
            totalDuration: metadata.totalDuration,
            version: metadata.version
        )
        
        try saveMetadata(metadata, to: catalogPath)
        
        // 목록에 추가
        catalogs.append(metadata)
        
        return metadata
    }
    
    // MARK: - Private 헬퍼
    /// 카탈로그 목록 로드
    private func loadCatalogsList() {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: catalogsDirectory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ) else {
            return
        }
        
        catalogs = contents.compactMap { url -> CatalogMetadata? in
            guard url.hasDirectoryPath else { return nil }
            return try? loadMetadata(from: url)
        }
        .sorted { $0.modifiedAt > $1.modifiedAt }
    }
    
    /// 메타데이터 저장
    private func saveMetadata(_ metadata: CatalogMetadata, to catalogPath: URL) throws {
        let metadataPath = catalogPath.appendingPathComponent("metadata.json")
        let data = try JSONEncoder().encode(metadata)
        try data.write(to: metadataPath)
    }
    
    /// 메타데이터 로드
    private func loadMetadata(from catalogPath: URL) throws -> CatalogMetadata {
        let metadataPath = catalogPath.appendingPathComponent("metadata.json")
        let data = try Data(contentsOf: metadataPath)
        return try JSONDecoder().decode(CatalogMetadata.self, from: data)
    }
    
    /// 아이템 목록 저장
    private func saveItems(_ items: [CatalogItem], to catalogPath: URL) throws {
        let itemsPath = catalogPath.appendingPathComponent("items.json")
        let data = try JSONEncoder().encode(items)
        try data.write(to: itemsPath)
    }
    
    /// 아이템 목록 로드
    private func loadItems(from catalogPath: URL) throws -> [CatalogItem] {
        let itemsPath = catalogPath.appendingPathComponent("items.json")
        
        guard FileManager.default.fileExists(atPath: itemsPath.path) else {
            return []
        }
        
        let data = try Data(contentsOf: itemsPath)
        return try JSONDecoder().decode([CatalogItem].self, from: data)
    }
    
    /// 시그니처 로드
    private func loadSignature(item: CatalogItem, catalogPath: URL) throws -> SHSignature {
        let signaturesPath = catalogPath.appendingPathComponent("signatures", isDirectory: true)
        let signaturePath = signaturesPath.appendingPathComponent(item.signatureDataFileName)
        let data = try Data(contentsOf: signaturePath)
        return try SHSignature(dataRepresentation: data)
    }
    
    /// CatalogItem에서 SHMediaItem 생성
    private func createMediaItem(from item: CatalogItem) -> SHMediaItem {
        var properties: [SHMediaItemProperty: Any] = [
            .title: item.title,
            .artist: item.artist
        ]
        
        if !item.genres.isEmpty {
            properties[.genres] = item.genres
        }
        
        if let artworkURL = item.artworkURL {
            properties[.artworkURL] = artworkURL
        }
        
        return SHMediaItem(properties: properties)
    }
    
    // MARK: - 현재 카탈로그 가져오기
    /// 현재 로드된 SHCustomCatalog 반환
    func getCurrentCatalog() -> SHCustomCatalog? {
        return currentCatalog
    }
    
    /// SHCatalog 기본 클래스로 반환 (세션 설정용)
    func getCatalogAsBase() -> SHCatalog? {
        return currentCatalog
    }
}

// MARK: - 미리보기 데이터
extension CustomCatalogManager {
    /// 미리보기용 샘플 카탈로그
    static var previewCatalogs: [CatalogMetadata] {
        [
            CatalogMetadata(
                name: "내 음악 컬렉션",
                description: "개인적으로 녹음한 음악들",
                itemCount: 15,
                totalDuration: 3600
            ),
            CatalogMetadata(
                name: "팟캐스트 인트로",
                description: "팟캐스트 인트로 음악 모음",
                itemCount: 5,
                totalDuration: 300
            )
        ]
    }
    
    /// 미리보기용 샘플 아이템
    static var previewItems: [CatalogItem] {
        [
            CatalogItem(
                title: "Morning Coffee",
                artist: "My Band",
                genres: ["Acoustic", "Chill"],
                signatureDataFileName: "sample1.shazamsignature"
            ),
            CatalogItem(
                title: "Sunset Drive",
                artist: "My Band",
                genres: ["Electronic"],
                signatureDataFileName: "sample2.shazamsignature"
            )
        ]
    }
}
