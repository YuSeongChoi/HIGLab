import SwiftUI
import PhotosUI

// MARK: - ContactEditView
// 연락처 추가/편집 뷰
// 폼 기반 UI로 연락처 정보 입력

struct ContactEditView: View {
    // MARK: - Mode
    
    /// 편집 모드 (추가 또는 수정)
    enum Mode {
        case add
        case edit(Contact)
        
        var title: String {
            switch self {
            case .add: return "새 연락처"
            case .edit: return "연락처 편집"
            }
        }
        
        var contact: Contact {
            switch self {
            case .add: return Contact()
            case .edit(let contact): return contact
            }
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var contactService: ContactService
    @Environment(\.dismiss) private var dismiss
    
    let mode: Mode
    
    /// 편집 중인 연락처 데이터
    @State private var editingContact: Contact
    
    /// 사진 선택기 표시 여부
    @State private var showingPhotoPicker = false
    
    /// 선택된 사진
    @State private var selectedPhoto: PhotosPickerItem?
    
    /// 저장 중 여부
    @State private var isSaving = false
    
    /// 에러 메시지
    @State private var errorMessage: String?
    
    // MARK: - Initialization
    
    init(mode: Mode) {
        self.mode = mode
        _editingContact = State(initialValue: mode.contact)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                // 프로필 사진 섹션
                photoSection
                
                // 기본 정보 섹션
                basicInfoSection
                
                // 전화번호 섹션
                phoneNumbersSection
                
                // 이메일 섹션
                emailsSection
                
                // 주소 섹션
                addressesSection
                
                // 추가 정보 섹션
                additionalInfoSection
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        saveContact()
                    }
                    .disabled(isSaving || !isValid)
                    .fontWeight(.semibold)
                }
            }
            .disabled(isSaving)
            .overlay {
                if isSaving {
                    ProgressView("저장 중...")
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .alert("오류", isPresented: .constant(errorMessage != nil)) {
                Button("확인") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .onChange(of: selectedPhoto) { _, newValue in
                loadPhoto(from: newValue)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// 유효성 검사
    private var isValid: Bool {
        // 이름 또는 조직명 중 하나는 필수
        !editingContact.givenName.isEmpty ||
        !editingContact.familyName.isEmpty ||
        !editingContact.organizationName.isEmpty
    }
    
    // MARK: - Sections
    
    /// 프로필 사진 섹션
    private var photoSection: some View {
        Section {
            HStack {
                Spacer()
                
                VStack(spacing: 12) {
                    // 사진 미리보기
                    photoPreview
                    
                    // 사진 선택/변경 버튼
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text(editingContact.imageData == nil ? "사진 추가" : "사진 변경")
                            .font(.subheadline)
                    }
                    
                    // 사진 삭제 버튼
                    if editingContact.imageData != nil {
                        Button("사진 삭제", role: .destructive) {
                            editingContact.imageData = nil
                            editingContact.thumbnailImageData = nil
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.vertical, 8)
                
                Spacer()
            }
        }
    }
    
    /// 사진 미리보기
    @ViewBuilder
    private var photoPreview: some View {
        if let imageData = editingContact.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.accent)
                }
        }
    }
    
    /// 기본 정보 섹션
    private var basicInfoSection: some View {
        Section("기본 정보") {
            TextField("성", text: $editingContact.familyName)
                .textContentType(.familyName)
            
            TextField("이름", text: $editingContact.givenName)
                .textContentType(.givenName)
            
            TextField("회사", text: $editingContact.organizationName)
                .textContentType(.organizationName)
            
            TextField("직함", text: $editingContact.jobTitle)
                .textContentType(.jobTitle)
        }
    }
    
    /// 전화번호 섹션
    private var phoneNumbersSection: some View {
        Section {
            ForEach($editingContact.phoneNumbers) { $phone in
                HStack {
                    // 레이블 선택
                    Menu {
                        ForEach(["휴대전화", "집", "직장", "기타"], id: \.self) { label in
                            Button(label) {
                                phone.label = label
                            }
                        }
                    } label: {
                        Text(phone.label.isEmpty ? "레이블" : phone.label)
                            .foregroundStyle(phone.label.isEmpty ? .secondary : .primary)
                            .frame(width: 80, alignment: .leading)
                    }
                    
                    TextField("전화번호", text: $phone.number)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
            }
            .onDelete { indexSet in
                editingContact.phoneNumbers.remove(atOffsets: indexSet)
            }
            
            Button {
                editingContact.phoneNumbers.append(PhoneNumber(label: "휴대전화", number: ""))
            } label: {
                Label("전화번호 추가", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("전화번호")
        }
    }
    
    /// 이메일 섹션
    private var emailsSection: some View {
        Section {
            ForEach($editingContact.emails) { $email in
                HStack {
                    Menu {
                        ForEach(["집", "직장", "기타"], id: \.self) { label in
                            Button(label) {
                                email.label = label
                            }
                        }
                    } label: {
                        Text(email.label.isEmpty ? "레이블" : email.label)
                            .foregroundStyle(email.label.isEmpty ? .secondary : .primary)
                            .frame(width: 80, alignment: .leading)
                    }
                    
                    TextField("이메일", text: $email.address)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .onDelete { indexSet in
                editingContact.emails.remove(atOffsets: indexSet)
            }
            
            Button {
                editingContact.emails.append(Email(label: "집", address: ""))
            } label: {
                Label("이메일 추가", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("이메일")
        }
    }
    
    /// 주소 섹션
    private var addressesSection: some View {
        Section {
            ForEach($editingContact.addresses) { $address in
                VStack(alignment: .leading, spacing: 8) {
                    Menu {
                        ForEach(["집", "직장", "기타"], id: \.self) { label in
                            Button(label) {
                                address.label = label
                            }
                        }
                    } label: {
                        HStack {
                            Text(address.label.isEmpty ? "레이블 선택" : address.label)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                        }
                        .foregroundStyle(address.label.isEmpty ? .secondary : .primary)
                    }
                    
                    TextField("도로명 주소", text: $address.street)
                        .textContentType(.streetAddressLine1)
                    
                    HStack {
                        TextField("시/군/구", text: $address.city)
                            .textContentType(.addressCity)
                        
                        TextField("도/주", text: $address.state)
                            .textContentType(.addressState)
                    }
                    
                    HStack {
                        TextField("우편번호", text: $address.postalCode)
                            .textContentType(.postalCode)
                            .keyboardType(.numberPad)
                        
                        TextField("국가", text: $address.country)
                            .textContentType(.countryName)
                    }
                }
                .padding(.vertical, 4)
            }
            .onDelete { indexSet in
                editingContact.addresses.remove(atOffsets: indexSet)
            }
            
            Button {
                editingContact.addresses.append(PostalAddress(label: "집"))
            } label: {
                Label("주소 추가", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("주소")
        }
    }
    
    /// 추가 정보 섹션
    private var additionalInfoSection: some View {
        Section("추가 정보") {
            // 생일
            DatePicker(
                "생일",
                selection: Binding(
                    get: {
                        if let birthday = editingContact.birthday,
                           let date = Calendar.current.date(from: birthday) {
                            return date
                        }
                        return Date()
                    },
                    set: { newDate in
                        editingContact.birthday = Calendar.current.dateComponents(
                            [.year, .month, .day],
                            from: newDate
                        )
                    }
                ),
                displayedComponents: .date
            )
            
            // 메모
            VStack(alignment: .leading) {
                Text("메모")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextEditor(text: $editingContact.note)
                    .frame(minHeight: 100)
            }
        }
    }
    
    // MARK: - Methods
    
    /// 사진 로드
    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                // 원본 이미지
                editingContact.imageData = data
                
                // 썸네일 생성
                if let uiImage = UIImage(data: data) {
                    let thumbnailSize = CGSize(width: 100, height: 100)
                    let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
                    let thumbnail = renderer.image { _ in
                        uiImage.draw(in: CGRect(origin: .zero, size: thumbnailSize))
                    }
                    editingContact.thumbnailImageData = thumbnail.jpegData(compressionQuality: 0.8)
                }
            }
        }
    }
    
    /// 연락처 저장
    private func saveContact() {
        // 빈 항목 제거
        editingContact.phoneNumbers.removeAll { $0.number.isEmpty }
        editingContact.emails.removeAll { $0.address.isEmpty }
        editingContact.addresses.removeAll { $0.fullAddress.isEmpty }
        
        isSaving = true
        
        Task {
            let success: Bool
            
            switch mode {
            case .add:
                success = await contactService.addContact(editingContact)
            case .edit:
                success = await contactService.updateContact(editingContact)
            }
            
            isSaving = false
            
            if success {
                dismiss()
            } else {
                errorMessage = contactService.errorMessage ?? "저장에 실패했습니다."
            }
        }
    }
}

// MARK: - Preview

#Preview("새 연락처 추가") {
    ContactEditView(mode: .add)
        .environmentObject(ContactService())
}

#Preview("연락처 편집") {
    ContactEditView(mode: .edit(.sample))
        .environmentObject(ContactService())
}
