import Foundation
import SwiftUI

// MARK: - 비밀 데이터 모델
/// 보안 금고에 저장할 비밀 항목을 나타내는 모델
/// Keychain에 저장될 때 Codable을 통해 직렬화됨
/// - Note: 민감한 content 필드는 CryptoService를 통해 추가 암호화 가능

struct SecretItem: Identifiable, Codable, Hashable, Sendable {
    
    // MARK: - 기본 속성
    
    /// 고유 식별자
    let id: UUID
    
    /// 비밀 항목 제목 (예: "은행 비밀번호", "서버 접속 정보")
    var title: String
    
    /// 실제 비밀 내용
    var content: String
    
    /// 카테고리 분류
    var category: Category
    
    /// 생성 일시
    let createdAt: Date
    
    /// 마지막 수정 일시
    var modifiedAt: Date
    
    /// 마지막 열람 일시
    var lastAccessedAt: Date?
    
    /// 즐겨찾기 여부
    var isFavorite: Bool
    
    /// 고정 여부 (목록 상단 표시)
    var isPinned: Bool
    
    /// 보관함으로 이동됨 (삭제 전 단계)
    var isArchived: Bool
    
    // MARK: - 보안 속성
    
    /// 추가 암호화 적용 여부
    var isEncrypted: Bool
    
    /// 암호화에 사용된 키 식별자 (Keychain key name)
    var encryptionKeyId: String?
    
    /// 암호화 nonce (AES-GCM용)
    var encryptionNonce: Data?
    
    /// 인증 태그 (AES-GCM 무결성 검증용)
    var authTag: Data?
    
    /// 콘텐츠 해시 (무결성 확인용, SHA256)
    var contentHash: String?
    
    // MARK: - 메타데이터
    
    /// 태그 목록 (검색 및 필터링용)
    var tags: [String]
    
    /// 사용자 정의 필드
    var customFields: [CustomField]
    
    /// URL (관련 웹사이트)
    var url: URL?
    
    /// 메모 (추가 설명)
    var notes: String?
    
    /// 만료일 (설정 시 만료 알림)
    var expiresAt: Date?
    
    /// 열람 횟수
    var accessCount: Int
    
    // MARK: - 카테고리 열거형
    
    /// 비밀 항목의 분류 카테고리
    enum Category: String, Codable, CaseIterable, Identifiable, Sendable {
        case password = "비밀번호"
        case note = "메모"
        case card = "카드 정보"
        case bankAccount = "계좌 정보"
        case identity = "신분증"
        case license = "라이선스"
        case server = "서버 정보"
        case wifi = "Wi-Fi"
        case apiKey = "API 키"
        case recoveryCode = "복구 코드"
        case other = "기타"
        
        var id: String { rawValue }
        
        /// SF Symbols 아이콘 이름
        var iconName: String {
            switch self {
            case .password:
                return "key.fill"
            case .note:
                return "note.text"
            case .card:
                return "creditcard.fill"
            case .bankAccount:
                return "building.columns.fill"
            case .identity:
                return "person.text.rectangle.fill"
            case .license:
                return "checkmark.seal.fill"
            case .server:
                return "server.rack"
            case .wifi:
                return "wifi"
            case .apiKey:
                return "key.horizontal.fill"
            case .recoveryCode:
                return "shield.lefthalf.filled"
            case .other:
                return "folder.fill"
            }
        }
        
        /// 카테고리별 색상
        var color: Color {
            switch self {
            case .password:
                return .blue
            case .note:
                return .yellow
            case .card:
                return .purple
            case .bankAccount:
                return .green
            case .identity:
                return .orange
            case .license:
                return .pink
            case .server:
                return .gray
            case .wifi:
                return .cyan
            case .apiKey:
                return .red
            case .recoveryCode:
                return .indigo
            case .other:
                return .secondary
            }
        }
        
        /// 카테고리 설명
        var description: String {
            switch self {
            case .password:
                return "웹사이트, 앱 비밀번호"
            case .note:
                return "보안이 필요한 텍스트 메모"
            case .card:
                return "신용카드, 체크카드 정보"
            case .bankAccount:
                return "은행 계좌번호"
            case .identity:
                return "주민등록번호, 여권 등"
            case .license:
                return "소프트웨어 라이선스 키"
            case .server:
                return "SSH, FTP, 데이터베이스 접속 정보"
            case .wifi:
                return "Wi-Fi 비밀번호"
            case .apiKey:
                return "API 키, 시크릿"
            case .recoveryCode:
                return "2FA 백업 코드"
            case .other:
                return "기타 민감한 정보"
            }
        }
        
        /// 카테고리별 템플릿 필드
        var templateFields: [CustomField] {
            switch self {
            case .password:
                return [
                    CustomField(name: "사용자명", value: "", fieldType: .text),
                    CustomField(name: "이메일", value: "", fieldType: .email),
                    CustomField(name: "비밀번호", value: "", fieldType: .password)
                ]
            case .card:
                return [
                    CustomField(name: "카드 번호", value: "", fieldType: .creditCard),
                    CustomField(name: "유효기간", value: "", fieldType: .text),
                    CustomField(name: "CVV", value: "", fieldType: .password),
                    CustomField(name: "카드사", value: "", fieldType: .text)
                ]
            case .bankAccount:
                return [
                    CustomField(name: "은행명", value: "", fieldType: .text),
                    CustomField(name: "계좌번호", value: "", fieldType: .text),
                    CustomField(name: "예금주", value: "", fieldType: .text)
                ]
            case .server:
                return [
                    CustomField(name: "호스트", value: "", fieldType: .text),
                    CustomField(name: "포트", value: "", fieldType: .number),
                    CustomField(name: "사용자명", value: "", fieldType: .text),
                    CustomField(name: "비밀번호", value: "", fieldType: .password)
                ]
            case .wifi:
                return [
                    CustomField(name: "네트워크 이름", value: "", fieldType: .text),
                    CustomField(name: "비밀번호", value: "", fieldType: .password),
                    CustomField(name: "보안 유형", value: "", fieldType: .text)
                ]
            default:
                return []
            }
        }
    }
    
    // MARK: - 사용자 정의 필드
    
    /// 사용자가 추가할 수 있는 커스텀 필드
    struct CustomField: Codable, Hashable, Identifiable, Sendable {
        let id: UUID
        var name: String
        var value: String
        var fieldType: FieldType
        var isHidden: Bool
        
        init(
            id: UUID = UUID(),
            name: String,
            value: String,
            fieldType: FieldType = .text,
            isHidden: Bool = false
        ) {
            self.id = id
            self.name = name
            self.value = value
            self.fieldType = fieldType
            self.isHidden = isHidden
        }
        
        /// 필드 유형
        enum FieldType: String, Codable, CaseIterable, Sendable {
            case text = "텍스트"
            case password = "비밀번호"
            case email = "이메일"
            case url = "URL"
            case number = "숫자"
            case date = "날짜"
            case phone = "전화번호"
            case creditCard = "카드번호"
            
            /// 키보드 타입 힌트
            var keyboardType: UIKeyboardType {
                switch self {
                case .text, .password:
                    return .default
                case .email:
                    return .emailAddress
                case .url:
                    return .URL
                case .number:
                    return .numberPad
                case .phone:
                    return .phonePad
                case .date:
                    return .default
                case .creditCard:
                    return .numberPad
                }
            }
            
            /// 마스킹 필요 여부
            var shouldMask: Bool {
                switch self {
                case .password, .creditCard:
                    return true
                default:
                    return false
                }
            }
        }
    }
    
    // MARK: - 초기화
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        category: Category = .other,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        lastAccessedAt: Date? = nil,
        isFavorite: Bool = false,
        isPinned: Bool = false,
        isArchived: Bool = false,
        isEncrypted: Bool = false,
        encryptionKeyId: String? = nil,
        encryptionNonce: Data? = nil,
        authTag: Data? = nil,
        contentHash: String? = nil,
        tags: [String] = [],
        customFields: [CustomField] = [],
        url: URL? = nil,
        notes: String? = nil,
        expiresAt: Date? = nil,
        accessCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.lastAccessedAt = lastAccessedAt
        self.isFavorite = isFavorite
        self.isPinned = isPinned
        self.isArchived = isArchived
        self.isEncrypted = isEncrypted
        self.encryptionKeyId = encryptionKeyId
        self.encryptionNonce = encryptionNonce
        self.authTag = authTag
        self.contentHash = contentHash
        self.tags = tags
        self.customFields = customFields
        self.url = url
        self.notes = notes
        self.expiresAt = expiresAt
        self.accessCount = accessCount
    }
    
    // MARK: - 편의 메서드
    
    /// 수정된 복사본 생성
    func modified(with content: String? = nil, title: String? = nil) -> SecretItem {
        var copy = self
        if let content = content {
            copy.content = content
        }
        if let title = title {
            copy.title = title
        }
        copy.modifiedAt = Date()
        return copy
    }
    
    /// 열람 기록 업데이트
    mutating func recordAccess() {
        lastAccessedAt = Date()
        accessCount += 1
    }
    
    /// 만료 여부
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return expiresAt < Date()
    }
    
    /// 만료 예정 (7일 이내)
    var isExpiringSoon: Bool {
        guard let expiresAt = expiresAt else { return false }
        let sevenDaysFromNow = Date().addingTimeInterval(7 * 24 * 60 * 60)
        return expiresAt < sevenDaysFromNow && expiresAt > Date()
    }
    
    /// 검색 가능한 텍스트 (제목, 태그, 메모 결합)
    var searchableText: String {
        let parts = [title] + tags + [notes].compactMap { $0 }
        return parts.joined(separator: " ").lowercased()
    }
    
    /// 마스킹된 콘텐츠 미리보기
    var maskedContentPreview: String {
        if content.isEmpty {
            return "(비어 있음)"
        }
        let visibleCount = min(4, content.count)
        let visible = String(content.prefix(visibleCount))
        let maskCount = max(0, content.count - visibleCount)
        return visible + String(repeating: "•", count: min(maskCount, 8))
    }
}

// MARK: - 정렬 옵션
extension SecretItem {
    /// 정렬 기준
    enum SortOption: String, CaseIterable, Identifiable {
        case title = "제목"
        case createdAt = "생성일"
        case modifiedAt = "수정일"
        case lastAccessedAt = "최근 열람"
        case category = "카테고리"
        case accessCount = "열람 횟수"
        
        var id: String { rawValue }
        
        /// 아이콘
        var iconName: String {
            switch self {
            case .title: return "textformat"
            case .createdAt: return "calendar.badge.plus"
            case .modifiedAt: return "calendar.badge.clock"
            case .lastAccessedAt: return "eye"
            case .category: return "folder"
            case .accessCount: return "number"
            }
        }
    }
    
    /// 정렬 방향
    enum SortDirection: String, CaseIterable {
        case ascending = "오름차순"
        case descending = "내림차순"
    }
}

// MARK: - 필터 옵션
extension SecretItem {
    /// 필터 조건
    struct FilterCriteria: Equatable {
        var categories: Set<Category> = []
        var isFavoriteOnly: Bool = false
        var isPinnedOnly: Bool = false
        var includeArchived: Bool = false
        var tags: Set<String> = []
        var searchQuery: String = ""
        var showExpiredOnly: Bool = false
        var showExpiringSoonOnly: Bool = false
        
        var isEmpty: Bool {
            categories.isEmpty &&
            !isFavoriteOnly &&
            !isPinnedOnly &&
            !includeArchived &&
            tags.isEmpty &&
            searchQuery.isEmpty &&
            !showExpiredOnly &&
            !showExpiringSoonOnly
        }
        
        static let `default` = FilterCriteria()
    }
}

// MARK: - 배열 확장
extension Array where Element == SecretItem {
    /// 필터 적용
    func filtered(by criteria: SecretItem.FilterCriteria) -> [SecretItem] {
        filter { item in
            // 보관함 필터
            if !criteria.includeArchived && item.isArchived {
                return false
            }
            
            // 카테고리 필터
            if !criteria.categories.isEmpty && !criteria.categories.contains(item.category) {
                return false
            }
            
            // 즐겨찾기 필터
            if criteria.isFavoriteOnly && !item.isFavorite {
                return false
            }
            
            // 고정 필터
            if criteria.isPinnedOnly && !item.isPinned {
                return false
            }
            
            // 태그 필터
            if !criteria.tags.isEmpty {
                let hasMatchingTag = criteria.tags.contains(where: { item.tags.contains($0) })
                if !hasMatchingTag {
                    return false
                }
            }
            
            // 검색어 필터
            if !criteria.searchQuery.isEmpty {
                let query = criteria.searchQuery.lowercased()
                if !item.searchableText.contains(query) {
                    return false
                }
            }
            
            // 만료 필터
            if criteria.showExpiredOnly && !item.isExpired {
                return false
            }
            
            // 만료 예정 필터
            if criteria.showExpiringSoonOnly && !item.isExpiringSoon {
                return false
            }
            
            return true
        }
    }
    
    /// 정렬 적용
    func sorted(by option: SecretItem.SortOption, direction: SecretItem.SortDirection) -> [SecretItem] {
        // 고정 항목은 항상 상단
        let pinned = filter { $0.isPinned }
        let unpinned = filter { !$0.isPinned }
        
        let sortedUnpinned = unpinned.sorted { lhs, rhs in
            let comparison: Bool
            
            switch option {
            case .title:
                comparison = lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            case .createdAt:
                comparison = lhs.createdAt < rhs.createdAt
            case .modifiedAt:
                comparison = lhs.modifiedAt < rhs.modifiedAt
            case .lastAccessedAt:
                let lhsDate = lhs.lastAccessedAt ?? Date.distantPast
                let rhsDate = rhs.lastAccessedAt ?? Date.distantPast
                comparison = lhsDate < rhsDate
            case .category:
                comparison = lhs.category.rawValue < rhs.category.rawValue
            case .accessCount:
                comparison = lhs.accessCount < rhs.accessCount
            }
            
            return direction == .ascending ? comparison : !comparison
        }
        
        return pinned.sorted(by: { $0.title < $1.title }) + sortedUnpinned
    }
    
    /// 카테고리별 그룹화
    func groupedByCategory() -> [SecretItem.Category: [SecretItem]] {
        Dictionary(grouping: self, by: { $0.category })
    }
    
    /// 모든 태그 추출
    var allTags: Set<String> {
        Set(flatMap { $0.tags })
    }
    
    /// 통계 정보
    var statistics: Statistics {
        Statistics(
            total: count,
            favorites: filter { $0.isFavorite }.count,
            archived: filter { $0.isArchived }.count,
            expired: filter { $0.isExpired }.count,
            expiringSoon: filter { $0.isExpiringSoon }.count,
            encrypted: filter { $0.isEncrypted }.count,
            byCategory: Dictionary(grouping: self, by: { $0.category }).mapValues { $0.count }
        )
    }
    
    struct Statistics {
        let total: Int
        let favorites: Int
        let archived: Int
        let expired: Int
        let expiringSoon: Int
        let encrypted: Int
        let byCategory: [SecretItem.Category: Int]
    }
}

// MARK: - 샘플 데이터
extension SecretItem {
    /// 미리보기 및 테스트용 샘플 데이터
    static let samples: [SecretItem] = [
        SecretItem(
            title: "Gmail 비밀번호",
            content: "super_secret_123!",
            category: .password,
            isFavorite: true,
            tags: ["구글", "이메일"],
            customFields: [
                CustomField(name: "이메일", value: "example@gmail.com", fieldType: .email),
                CustomField(name: "2FA 활성화", value: "예", fieldType: .text)
            ],
            url: URL(string: "https://gmail.com")
        ),
        SecretItem(
            title: "신한카드 번호",
            content: "1234-5678-9012-3456",
            category: .card,
            tags: ["신한", "신용카드"],
            customFields: [
                CustomField(name: "CVV", value: "123", fieldType: .password),
                CustomField(name: "유효기간", value: "12/28", fieldType: .text),
                CustomField(name: "결제일", value: "15일", fieldType: .text)
            ]
        ),
        SecretItem(
            title: "급여 계좌",
            content: "카카오뱅크 3333-12-1234567",
            category: .bankAccount,
            isFavorite: true,
            isPinned: true,
            tags: ["카카오뱅크", "급여"],
            customFields: [
                CustomField(name: "은행명", value: "카카오뱅크", fieldType: .text),
                CustomField(name: "예금주", value: "홍길동", fieldType: .text)
            ]
        ),
        SecretItem(
            title: "회사 VPN",
            content: "vpn.company.com",
            category: .server,
            tags: ["회사", "VPN"],
            customFields: [
                CustomField(name: "사용자명", value: "john.doe", fieldType: .text),
                CustomField(name: "비밀번호", value: "corp_pass_2024", fieldType: .password),
                CustomField(name: "포트", value: "443", fieldType: .number)
            ],
            notes: "매월 1일 비밀번호 변경 필요"
        ),
        SecretItem(
            title: "집 Wi-Fi",
            content: "MyHomeNetwork_5G",
            category: .wifi,
            tags: ["집", "와이파이"],
            customFields: [
                CustomField(name: "비밀번호", value: "home_wifi_pass!", fieldType: .password),
                CustomField(name: "보안", value: "WPA3", fieldType: .text)
            ]
        ),
        SecretItem(
            title: "GitHub API 토큰",
            content: "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
            category: .apiKey,
            isEncrypted: true,
            tags: ["GitHub", "개발"],
            expiresAt: Date().addingTimeInterval(30 * 24 * 60 * 60), // 30일 후 만료
            notes: "repo, workflow 권한 포함"
        ),
        SecretItem(
            title: "iCloud 복구 코드",
            content: "XXXX-XXXX-XXXX-XXXX-XXXX-XXXX",
            category: .recoveryCode,
            isFavorite: true,
            tags: ["Apple", "iCloud"],
            notes: "절대 분실하지 말 것!"
        ),
        SecretItem(
            title: "만료된 라이선스",
            content: "XXXX-XXXX-XXXX-XXXX",
            category: .license,
            tags: ["소프트웨어"],
            expiresAt: Date().addingTimeInterval(-7 * 24 * 60 * 60), // 7일 전 만료됨
            isArchived: true
        )
    ]
    
    /// 단일 샘플
    static let sample = samples[0]
    
    /// 빈 항목 (새 항목 생성용)
    static let empty = SecretItem(title: "", content: "", category: .other)
}

// MARK: - Codable 커스터마이즈
extension SecretItem {
    enum CodingKeys: String, CodingKey {
        case id, title, content, category
        case createdAt, modifiedAt, lastAccessedAt
        case isFavorite, isPinned, isArchived
        case isEncrypted, encryptionKeyId, encryptionNonce, authTag, contentHash
        case tags, customFields, url, notes, expiresAt, accessCount
    }
}
