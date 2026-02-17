import Foundation

// MARK: - 비밀 데이터 모델
/// 보안 금고에 저장할 비밀 항목을 나타내는 모델
/// Keychain에 저장될 때 Codable을 통해 직렬화됨

struct SecretItem: Identifiable, Codable, Hashable {
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
    
    /// 즐겨찾기 여부
    var isFavorite: Bool
    
    // MARK: - 카테고리 열거형
    /// 비밀 항목의 분류 카테고리
    enum Category: String, Codable, CaseIterable {
        case password = "비밀번호"
        case note = "메모"
        case card = "카드 정보"
        case bankAccount = "계좌 정보"
        case other = "기타"
        
        /// SF Symbols 아이콘 이름
        var iconName: String {
            switch self {
            case .password: return "key.fill"
            case .note: return "note.text"
            case .card: return "creditcard.fill"
            case .bankAccount: return "building.columns.fill"
            case .other: return "folder.fill"
            }
        }
        
        /// 카테고리별 색상
        var color: String {
            switch self {
            case .password: return "blue"
            case .note: return "yellow"
            case .card: return "purple"
            case .bankAccount: return "green"
            case .other: return "gray"
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
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.isFavorite = isFavorite
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
            isFavorite: true
        ),
        SecretItem(
            title: "신한카드 번호",
            content: "1234-5678-9012-3456\nCVV: 123\n유효기간: 12/28",
            category: .card
        ),
        SecretItem(
            title: "급여 계좌",
            content: "카카오뱅크\n3333-12-1234567",
            category: .bankAccount,
            isFavorite: true
        ),
        SecretItem(
            title: "서버 접속 정보",
            content: "Host: 192.168.1.100\nUser: admin\nPW: admin1234",
            category: .note
        )
    ]
}
