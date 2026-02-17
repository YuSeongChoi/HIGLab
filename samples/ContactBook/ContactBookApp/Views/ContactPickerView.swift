import SwiftUI
import ContactsUI

// MARK: - ContactPickerDemoView
// CNContactPickerViewController를 SwiftUI에서 사용하는 데모 뷰
// 시스템 연락처 선택기 활용 방법 시연

struct ContactPickerDemoView: View {
    // MARK: - Properties
    
    @EnvironmentObject var contactService: ContactService
    
    /// 선택된 연락처 목록
    @State private var selectedContacts: [Contact] = []
    
    /// 단일 선택 모드 표시 여부
    @State private var showingSinglePicker = false
    
    /// 다중 선택 모드 표시 여부
    @State private var showingMultiplePicker = false
    
    /// 속성 선택 모드 표시 여부
    @State private var showingPropertyPicker = false
    
    /// 선택된 속성 값
    @State private var selectedProperty: String?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                // 설명 섹션
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("CNContactPickerViewController", systemImage: "info.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.accent)
                        
                        Text("시스템에서 제공하는 연락처 선택기입니다. 일관된 UX와 프라이버시 보호를 제공합니다.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                // 선택 모드 섹션
                Section("선택 모드") {
                    // 단일 연락처 선택
                    Button {
                        showingSinglePicker = true
                    } label: {
                        HStack {
                            Label("단일 연락처 선택", systemImage: "person.crop.circle")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    // 다중 연락처 선택
                    Button {
                        showingMultiplePicker = true
                    } label: {
                        HStack {
                            Label("다중 연락처 선택", systemImage: "person.2.crop.square.stack")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    // 속성 선택
                    Button {
                        showingPropertyPicker = true
                    } label: {
                        HStack {
                            Label("전화번호 선택", systemImage: "phone.circle")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
                
                // 선택된 속성 섹션
                if let property = selectedProperty {
                    Section("선택된 전화번호") {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(.green)
                            Text(property)
                                .font(.body.monospaced())
                            Spacer()
                            Button {
                                callPhone(property)
                            } label: {
                                Text("전화 걸기")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                        }
                    }
                }
                
                // 선택된 연락처 섹션
                if !selectedContacts.isEmpty {
                    Section("선택된 연락처 (\(selectedContacts.count))") {
                        ForEach(selectedContacts) { contact in
                            HStack(spacing: 12) {
                                // 프로필 이미지
                                if let imageData = contact.thumbnailImageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Text(contact.initials)
                                                .font(.subheadline)
                                                .foregroundStyle(.accent)
                                        }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(contact.displayName)
                                        .font(.body)
                                    if let phone = contact.primaryPhone {
                                        Text(phone)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            selectedContacts.remove(atOffsets: indexSet)
                        }
                        
                        Button(role: .destructive) {
                            selectedContacts.removeAll()
                        } label: {
                            Label("모두 지우기", systemImage: "trash")
                        }
                    }
                }
                
                // 사용 가이드 섹션
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        GuideItem(
                            icon: "1.circle.fill",
                            title: "단일 선택",
                            description: "사용자가 하나의 연락처만 선택할 수 있습니다."
                        )
                        
                        GuideItem(
                            icon: "2.circle.fill",
                            title: "다중 선택",
                            description: "여러 연락처를 한 번에 선택할 수 있습니다."
                        )
                        
                        GuideItem(
                            icon: "3.circle.fill",
                            title: "속성 선택",
                            description: "전화번호나 이메일 등 특정 속성만 선택합니다."
                        )
                        
                        GuideItem(
                            icon: "lock.shield.fill",
                            title: "프라이버시",
                            description: "선택된 정보만 앱에 전달되어 안전합니다."
                        )
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("사용 가이드")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("연락처 선택기")
            .sheet(isPresented: $showingSinglePicker) {
                ContactPickerRepresentable(
                    mode: .single,
                    onSelectContact: { contact in
                        selectedContacts = [contact]
                    }
                )
            }
            .sheet(isPresented: $showingMultiplePicker) {
                ContactPickerRepresentable(
                    mode: .multiple,
                    onSelectContacts: { contacts in
                        selectedContacts = contacts
                    }
                )
            }
            .sheet(isPresented: $showingPropertyPicker) {
                ContactPickerRepresentable(
                    mode: .property(.phoneNumber),
                    onSelectProperty: { value in
                        selectedProperty = value
                    }
                )
            }
        }
    }
    
    // MARK: - Methods
    
    /// 전화 걸기
    private func callPhone(_ number: String) {
        let cleanNumber = number.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(cleanNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - GuideItem
// 가이드 항목 컴포넌트

struct GuideItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.accent)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - ContactPickerRepresentable
// CNContactPickerViewController를 SwiftUI에서 사용하기 위한 래퍼

struct ContactPickerRepresentable: UIViewControllerRepresentable {
    // MARK: - Mode
    
    /// 선택 모드
    enum Mode {
        case single                     // 단일 연락처 선택
        case multiple                   // 다중 연락처 선택
        case property(PropertyType)     // 속성 선택
    }
    
    /// 속성 타입
    enum PropertyType {
        case phoneNumber
        case email
        
        var predicate: NSPredicate {
            switch self {
            case .phoneNumber:
                return NSPredicate(format: "phoneNumbers.@count > 0")
            case .email:
                return NSPredicate(format: "emailAddresses.@count > 0")
            }
        }
        
        var displayedPropertyKey: String {
            switch self {
            case .phoneNumber:
                return CNContactPhoneNumbersKey
            case .email:
                return CNContactEmailAddressesKey
            }
        }
    }
    
    // MARK: - Properties
    
    let mode: Mode
    var onSelectContact: ((Contact) -> Void)?
    var onSelectContacts: (([Contact]) -> Void)?
    var onSelectProperty: ((String) -> Void)?
    var onCancel: (() -> Void)?
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        
        // 모드에 따른 설정
        switch mode {
        case .single:
            // 기본 설정 사용
            break
            
        case .multiple:
            // 다중 선택 허용
            break
            
        case .property(let propertyType):
            // 특정 속성이 있는 연락처만 표시
            picker.predicateForEnablingContact = propertyType.predicate
            // 선택할 속성 지정
            picker.displayedPropertyKeys = [propertyType.displayedPropertyKey]
            // 속성 선택 시 바로 반환
            picker.predicateForSelectionOfProperty = NSPredicate(value: true)
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {
        // 업데이트 필요 없음
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerRepresentable
        
        init(_ parent: ContactPickerRepresentable) {
            self.parent = parent
        }
        
        // 단일 연락처 선택
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let selectedContact = Contact(from: contact)
            parent.onSelectContact?(selectedContact)
        }
        
        // 다중 연락처 선택
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
            let selectedContacts = contacts.map { Contact(from: $0) }
            
            switch parent.mode {
            case .multiple:
                parent.onSelectContacts?(selectedContacts)
            case .single:
                if let first = selectedContacts.first {
                    parent.onSelectContact?(first)
                }
            default:
                break
            }
        }
        
        // 속성 선택 (전화번호, 이메일 등)
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
            var value: String?
            
            if let phoneNumber = contactProperty.value as? CNPhoneNumber {
                value = phoneNumber.stringValue
            } else if let email = contactProperty.value as? String {
                value = email
            }
            
            if let value = value {
                parent.onSelectProperty?(value)
            }
        }
        
        // 취소
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.onCancel?()
        }
    }
}

// MARK: - ContactPickerButton
// 간단한 연락처 선택 버튼 컴포넌트

struct ContactPickerButton: View {
    // MARK: - Properties
    
    /// 버튼 레이블
    let label: String
    
    /// 버튼 아이콘
    let icon: String
    
    /// 선택 완료 콜백
    let onSelect: (Contact) -> Void
    
    /// 선택기 표시 여부
    @State private var showingPicker = false
    
    // MARK: - Body
    
    var body: some View {
        Button {
            showingPicker = true
        } label: {
            Label(label, systemImage: icon)
        }
        .sheet(isPresented: $showingPicker) {
            ContactPickerRepresentable(
                mode: .single,
                onSelectContact: onSelect
            )
        }
    }
}

// MARK: - Preview

#Preview("연락처 선택기 데모") {
    ContactPickerDemoView()
        .environmentObject(ContactService())
}
