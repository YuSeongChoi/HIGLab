import Foundation
import AppIntents
import SwiftUI

// MARK: - 태그 모델
/// 할일에 부착할 수 있는 태그
/// 분류 및 필터링에 사용
struct Tag: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String           // 태그 이름
    var colorHex: String       // 색상 (Hex)
    var createdAt: Date        // 생성 시간
    
    // MARK: - 초기화
    
    init(id: UUID = UUID(), name: String, colorHex: String = "#007AFF") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
    }
    
    // MARK: - 기본 태그
    
    /// 시스템 기본 태그
    static let defaultTags: [Tag] = [
        Tag(name: "개인", colorHex: "#34C759"),
        Tag(name: "업무", colorHex: "#007AFF"),
        Tag(name: "쇼핑", colorHex: "#FF9500"),
        Tag(name: "건강", colorHex: "#FF2D55"),
        Tag(name: "학습", colorHex: "#AF52DE")
    ]
    
    // MARK: - 색상 변환
    
    /// SwiftUI Color로 변환
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

// MARK: - AppEntity 준수
extension Tag: AppEntity {
    
    /// 타입 표시 정보
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: "태그",
            numericFormat: "\(placeholder: .int)개 태그"
        )
    }
    
    /// 개별 태그 표시 정보
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: nil,
            image: .init(systemName: "tag.fill")
        )
    }
    
    /// 기본 쿼리
    static var defaultQuery: TagQuery {
        TagQuery()
    }
}

// MARK: - 태그 쿼리
/// Siri에서 태그를 검색하는 쿼리
struct TagQuery: EntityQuery {
    
    /// ID로 태그 조회
    func entities(for identifiers: [UUID]) async throws -> [Tag] {
        await TagStore.shared.tags.filter { identifiers.contains($0.id) }
    }
    
    /// 추천 태그 (자주 사용하는 태그)
    func suggestedEntities() async throws -> [Tag] {
        await TagStore.shared.tags
    }
}

// MARK: - 문자열 검색 지원
extension TagQuery: EntityStringQuery {
    
    /// 문자열로 태그 검색
    func entities(matching string: String) async throws -> [Tag] {
        let allTags = await TagStore.shared.tags
        
        guard !string.isEmpty else {
            return allTags
        }
        
        return allTags.filter { tag in
            tag.name.localizedCaseInsensitiveContains(string)
        }
    }
}

// MARK: - 태그 저장소
/// 태그를 관리하는 싱글톤 저장소
@MainActor
final class TagStore: ObservableObject {
    
    // MARK: - 싱글톤
    static let shared = TagStore()
    
    // MARK: - 속성
    @Published var tags: [Tag] = [] {
        didSet { save() }
    }
    
    // MARK: - 저장소 키
    private let storageKey = "SiriTodo.tags"
    private let userDefaults = UserDefaults.standard
    
    // MARK: - 초기화
    private init() {
        load()
    }
    
    // MARK: - CRUD
    
    /// 새 태그 추가
    @discardableResult
    func add(name: String, colorHex: String = "#007AFF") -> Tag {
        let tag = Tag(name: name, colorHex: colorHex)
        tags.append(tag)
        return tag
    }
    
    /// 태그 삭제
    func delete(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
    }
    
    /// 이름으로 태그 찾기
    func find(byName name: String) -> Tag? {
        tags.first { $0.name.lowercased() == name.lowercased() }
    }
    
    // MARK: - 영구 저장
    
    private func save() {
        guard let data = try? JSONEncoder().encode(tags) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
    
    private func load() {
        guard let data = userDefaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Tag].self, from: data) else {
            // 기본 태그로 초기화
            tags = Tag.defaultTags
            return
        }
        tags = decoded
    }
}

// MARK: - Color 확장 (Hex 지원)
extension Color {
    
    /// Hex 문자열로부터 Color 생성
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
