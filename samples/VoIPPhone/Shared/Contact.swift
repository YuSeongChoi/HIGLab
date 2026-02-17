import Foundation
import SwiftUI

// MARK: - 연락처 모델
// 앱 내에서 사용하는 연락처 정보를 관리

/// 연락처 모델
struct Contact: Identifiable, Codable, Hashable {
    let id: UUID                    // 고유 식별자
    var name: String                // 이름
    var phoneNumber: String         // 전화번호
    var email: String?              // 이메일 (선택)
    var avatarColor: AvatarColor    // 아바타 배경색
    var isFavorite: Bool            // 즐겨찾기 여부
    
    /// 이니셜 (아바타에 표시)
    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = components.first?.prefix(1) ?? ""
            let last = components.last?.prefix(1) ?? ""
            return "\(first)\(last)".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
    
    /// 포맷된 전화번호
    var formattedPhoneNumber: String {
        // 간단한 포맷팅: 010-1234-5678 형식
        let digits = phoneNumber.filter { $0.isNumber }
        if digits.count == 11 {
            let start = digits.prefix(3)
            let middle = digits.dropFirst(3).prefix(4)
            let end = digits.suffix(4)
            return "\(start)-\(middle)-\(end)"
        }
        return phoneNumber
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        phoneNumber: String,
        email: String? = nil,
        avatarColor: AvatarColor = .random,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.avatarColor = avatarColor
        self.isFavorite = isFavorite
    }
}

// MARK: - 아바타 색상
// 연락처 아바타에 사용할 색상 정의

/// 아바타 배경색 열거형
enum AvatarColor: String, Codable, CaseIterable {
    case blue
    case green
    case orange
    case purple
    case red
    case teal
    case pink
    case indigo
    
    /// SwiftUI Color로 변환
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .red: return .red
        case .teal: return .teal
        case .pink: return .pink
        case .indigo: return .indigo
        }
    }
    
    /// 랜덤 색상 선택
    static var random: AvatarColor {
        AvatarColor.allCases.randomElement() ?? .blue
    }
}

// MARK: - 연락처 저장소
// UserDefaults를 활용한 연락처 영구 저장

/// 연락처 저장소 클래스
class ContactStore: ObservableObject {
    static let shared = ContactStore()
    
    @Published var contacts: [Contact] = []
    
    private let storageKey = "voipphone_contacts"
    
    private init() {
        loadContacts()
        
        // 샘플 데이터가 없으면 추가
        if contacts.isEmpty {
            addSampleContacts()
        }
    }
    
    /// 연락처 불러오기
    func loadContacts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Contact].self, from: data) else {
            return
        }
        contacts = decoded
    }
    
    /// 연락처 저장
    func saveContacts() {
        guard let data = try? JSONEncoder().encode(contacts) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    /// 연락처 추가
    func addContact(_ contact: Contact) {
        contacts.append(contact)
        saveContacts()
    }
    
    /// 연락처 삭제
    func deleteContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        saveContacts()
    }
    
    /// 연락처 업데이트
    func updateContact(_ contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
            saveContacts()
        }
    }
    
    /// 전화번호로 연락처 찾기
    func findContact(byPhoneNumber phoneNumber: String) -> Contact? {
        let digits = phoneNumber.filter { $0.isNumber }
        return contacts.first { contact in
            contact.phoneNumber.filter { $0.isNumber } == digits
        }
    }
    
    /// 이름으로 연락처 검색
    func searchContacts(query: String) -> [Contact] {
        guard !query.isEmpty else { return contacts }
        return contacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(query) ||
            contact.phoneNumber.contains(query)
        }
    }
    
    /// 즐겨찾기 연락처 목록
    var favoriteContacts: [Contact] {
        contacts.filter { $0.isFavorite }
    }
    
    /// 샘플 연락처 추가
    private func addSampleContacts() {
        let samples = [
            Contact(name: "김철수", phoneNumber: "01012345678", avatarColor: .blue, isFavorite: true),
            Contact(name: "이영희", phoneNumber: "01023456789", avatarColor: .green),
            Contact(name: "박민수", phoneNumber: "01034567890", avatarColor: .orange, isFavorite: true),
            Contact(name: "정수진", phoneNumber: "01045678901", avatarColor: .purple),
            Contact(name: "최동현", phoneNumber: "01056789012", avatarColor: .red),
            Contact(name: "강미영", phoneNumber: "01067890123", avatarColor: .teal),
            Contact(name: "윤재호", phoneNumber: "01078901234", avatarColor: .pink),
            Contact(name: "한소연", phoneNumber: "01089012345", avatarColor: .indigo, isFavorite: true)
        ]
        contacts = samples
        saveContacts()
    }
}

// MARK: - 연락처 아바타 뷰
// 연락처 이니셜을 표시하는 원형 아바타

/// 연락처 아바타 뷰
struct ContactAvatar: View {
    let contact: Contact
    var size: CGFloat = 50
    
    var body: some View {
        ZStack {
            Circle()
                .fill(contact.avatarColor.color)
            
            Text(contact.initials)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}
