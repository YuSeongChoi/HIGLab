import SwiftUI

// MARK: - 태그 쓰기 뷰

/// NFC 태그에 데이터를 쓰는 화면
struct WriteTagView: View {
    @EnvironmentObject var nfcManager: NFCManager
    
    /// 선택된 쓰기 타입
    @State private var selectedType: WriteType = .url
    
    /// 쓰기 완료 알림
    @State private var showWriteSuccess = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // NFC 지원 여부 체크
                    if !nfcManager.isNFCSupported {
                        NFCNotSupportedView()
                    } else {
                        // 타입 선택기
                        writeTypePicker
                        
                        // 선택된 타입에 따른 입력 폼
                        writeForm
                    }
                }
                .padding()
            }
            .background(Color.nfcBackground)
            .navigationTitle("태그 쓰기")
            .alert("쓰기 완료", isPresented: $showWriteSuccess) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("태그에 성공적으로 데이터를 썼습니다")
            }
            .onChange(of: nfcManager.scanState) { _, newState in
                if case .success = newState, nfcManager.scanState == .success {
                    // 쓰기 성공
                    showWriteSuccess = true
                    nfcManager.resetState()
                }
            }
        }
    }
    
    // MARK: - 타입 선택기
    
    private var writeTypePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("쓰기 유형 선택")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WriteType.allCases, id: \.self) { type in
                        WriteTypeButton(
                            type: type,
                            isSelected: selectedType == type
                        ) {
                            withAnimation {
                                selectedType = type
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    // MARK: - 쓰기 폼
    
    @ViewBuilder
    private var writeForm: some View {
        switch selectedType {
        case .url:
            URLWriteForm()
        case .text:
            TextWriteForm()
        case .phone:
            PhoneWriteForm()
        case .email:
            EmailWriteForm()
        case .contact:
            ContactWriteForm()
        }
    }
}

// MARK: - 쓰기 타입 열거형

/// 쓰기 가능한 데이터 타입
enum WriteType: String, CaseIterable {
    case url = "URL"
    case text = "텍스트"
    case phone = "전화번호"
    case email = "이메일"
    case contact = "연락처"
    
    var iconName: String {
        switch self {
        case .url: return "globe"
        case .text: return "text.alignleft"
        case .phone: return "phone"
        case .email: return "envelope"
        case .contact: return "person.crop.circle"
        }
    }
}

// MARK: - 타입 선택 버튼

/// 쓰기 타입 선택 버튼
struct WriteTypeButton: View {
    let type: WriteType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.iconName)
                    .font(.title2)
                
                Text(type.rawValue)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .foregroundColor(isSelected ? .white : .nfcPrimary)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.nfcPrimary : Color.nfcPrimary.opacity(0.1))
            )
        }
    }
}

// MARK: - URL 쓰기 폼

/// URL 쓰기 폼
struct URLWriteForm: View {
    @EnvironmentObject var nfcManager: NFCManager
    
    @State private var urlString = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("URL 입력")
                .font(.headline)
            
            TextField("https://example.com", text: $urlString)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            // 자주 사용하는 프로토콜
            HStack(spacing: 8) {
                ForEach(["https://", "http://", "tel:", "mailto:"], id: \.self) { prefix in
                    Button(prefix) {
                        if !urlString.contains("://") && !urlString.hasPrefix("tel:") && !urlString.hasPrefix("mailto:") {
                            urlString = prefix + urlString
                        }
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // 미리보기
            if !urlString.isEmpty {
                previewCard(title: "URL", value: urlString, icon: "globe")
            }
            
            Spacer().frame(height: 8)
            
            // 쓰기 버튼
            Button {
                nfcManager.writeURL(urlString)
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("태그에 쓰기")
                }
            }
            .primaryButtonStyle(isEnabled: isValidURL)
            .disabled(!isValidURL)
        }
        .cardStyle()
    }
    
    private var isValidURL: Bool {
        !urlString.isEmpty && (
            urlString.hasPrefix("http://") ||
            urlString.hasPrefix("https://") ||
            urlString.hasPrefix("tel:") ||
            urlString.hasPrefix("mailto:")
        )
    }
}

// MARK: - 텍스트 쓰기 폼

/// 텍스트 쓰기 폼
struct TextWriteForm: View {
    @EnvironmentObject var nfcManager: NFCManager
    
    @State private var textContent = ""
    @State private var languageCode = "ko"
    
    let languageCodes = [
        ("ko", "한국어"),
        ("en", "English"),
        ("ja", "日本語"),
        ("zh", "中文")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("텍스트 입력")
                .font(.headline)
            
            // 언어 선택
            HStack {
                Text("언어:")
                    .foregroundColor(.secondary)
                
                Picker("언어", selection: $languageCode) {
                    ForEach(languageCodes, id: \.0) { code, name in
                        Text(name).tag(code)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // 텍스트 입력
            TextEditor(text: $textContent)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            // 글자 수
            HStack {
                Spacer()
                Text("\(textContent.count)자")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 미리보기
            if !textContent.isEmpty {
                previewCard(title: "텍스트 (\(languageCode))", value: textContent, icon: "text.alignleft")
            }
            
            // 쓰기 버튼
            Button {
                let records = NDEFMessageBuilder()
                    .addTextRecord(textContent, languageCode: languageCode)
                    .build()
                nfcManager.startWriting(records: records)
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("태그에 쓰기")
                }
            }
            .primaryButtonStyle(isEnabled: !textContent.isEmpty)
            .disabled(textContent.isEmpty)
        }
        .cardStyle()
    }
}

// MARK: - 전화번호 쓰기 폼

/// 전화번호 쓰기 폼
struct PhoneWriteForm: View {
    @EnvironmentObject var nfcManager: NFCManager
    
    @State private var phoneNumber = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("전화번호 입력")
                .font(.headline)
            
            TextField("010-1234-5678", text: $phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
            
            // 미리보기
            if !phoneNumber.isEmpty {
                previewCard(title: "전화번호", value: "tel:\(phoneNumber)", icon: "phone")
            }
            
            // 쓰기 버튼
            Button {
                let records = NDEFMessageBuilder.phoneMessage(phoneNumber: phoneNumber)
                nfcManager.startWriting(records: records)
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("태그에 쓰기")
                }
            }
            .primaryButtonStyle(isEnabled: !phoneNumber.isEmpty)
            .disabled(phoneNumber.isEmpty)
        }
        .cardStyle()
    }
}

// MARK: - 이메일 쓰기 폼

/// 이메일 쓰기 폼
struct EmailWriteForm: View {
    @EnvironmentObject var nfcManager: NFCManager
    
    @State private var email = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("이메일 입력")
                .font(.headline)
            
            TextField("example@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            // 미리보기
            if !email.isEmpty {
                previewCard(title: "이메일", value: "mailto:\(email)", icon: "envelope")
            }
            
            // 쓰기 버튼
            Button {
                let records = NDEFMessageBuilder.emailMessage(email: email)
                nfcManager.startWriting(records: records)
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("태그에 쓰기")
                }
            }
            .primaryButtonStyle(isEnabled: isValidEmail)
            .disabled(!isValidEmail)
        }
        .cardStyle()
    }
    
    private var isValidEmail: Bool {
        email.contains("@") && email.contains(".")
    }
}

// MARK: - 연락처 쓰기 폼

/// 연락처(vCard) 쓰기 폼
struct ContactWriteForm: View {
    @EnvironmentObject var nfcManager: NFCManager
    
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var organization = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("연락처 정보 입력")
                .font(.headline)
            
            // 이름 (필수)
            VStack(alignment: .leading, spacing: 4) {
                Text("이름 *")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("홍길동", text: $name)
                    .textFieldStyle(.roundedBorder)
            }
            
            // 전화번호
            VStack(alignment: .leading, spacing: 4) {
                Text("전화번호")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("010-1234-5678", text: $phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
            }
            
            // 이메일
            VStack(alignment: .leading, spacing: 4) {
                Text("이메일")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("example@email.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
            
            // 조직
            VStack(alignment: .leading, spacing: 4) {
                Text("회사/조직")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("ABC 주식회사", text: $organization)
                    .textFieldStyle(.roundedBorder)
            }
            
            // 미리보기
            if !name.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("미리보기")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.nfcPrimary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name)
                                .font(.headline)
                            
                            if !organization.isEmpty {
                                Text(organization)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // 쓰기 버튼
            Button {
                nfcManager.writeContact(
                    name: name,
                    phone: phone.isEmpty ? nil : phone,
                    email: email.isEmpty ? nil : email,
                    organization: organization.isEmpty ? nil : organization
                )
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("태그에 쓰기")
                }
            }
            .primaryButtonStyle(isEnabled: !name.isEmpty)
            .disabled(name.isEmpty)
        }
        .cardStyle()
    }
}

// MARK: - 미리보기 카드 헬퍼

/// 미리보기 카드 생성 함수
func previewCard(title: String, value: String, icon: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text("미리보기")
            .font(.caption)
            .foregroundColor(.secondary)
        
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.nfcPrimary)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - 프리뷰

#Preview {
    WriteTagView()
        .environmentObject(NFCManager())
}
