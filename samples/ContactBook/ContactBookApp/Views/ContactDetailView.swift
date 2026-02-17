import SwiftUI
import MessageUI

// MARK: - ContactDetailView
// 연락처 상세 정보를 표시하는 뷰
// 전화, 메시지, 이메일 등 빠른 액션 제공

struct ContactDetailView: View {
    // MARK: - Properties
    
    @EnvironmentObject var contactService: ContactService
    @Environment(\.dismiss) private var dismiss
    
    /// 표시할 연락처
    let contact: Contact
    
    /// 편집 시트 표시 여부
    @State private var showingEditSheet = false
    
    /// 삭제 확인 알림 표시 여부
    @State private var showingDeleteAlert = false
    
    /// 공유 시트 표시 여부
    @State private var showingShareSheet = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 프로필 헤더
                    profileHeader
                    
                    // 빠른 액션 버튼
                    quickActions
                    
                    // 상세 정보 섹션들
                    detailSections
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("연락처")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("편집", systemImage: "pencil")
                        }
                        
                        Button {
                            showingShareSheet = true
                        } label: {
                            Label("공유", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                ContactEditView(mode: .edit(contact))
            }
            .alert("연락처 삭제", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    deleteContact()
                }
            } message: {
                Text("\(contact.displayName) 연락처를 삭제하시겠습니까?")
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 프로필 헤더
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // 프로필 이미지
            profileImageView
            
            // 이름
            Text(contact.displayName)
                .font(.title)
                .fontWeight(.bold)
            
            // 조직/직함
            if !contact.organizationName.isEmpty || !contact.jobTitle.isEmpty {
                VStack(spacing: 4) {
                    if !contact.jobTitle.isEmpty {
                        Text(contact.jobTitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    if !contact.organizationName.isEmpty {
                        Text(contact.organizationName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
    }
    
    /// 프로필 이미지 뷰
    @ViewBuilder
    private var profileImageView: some View {
        if let imageData = contact.imageData ?? contact.thumbnailImageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .shadow(radius: 4)
        } else {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .overlay {
                    Text(contact.initials)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                }
                .shadow(radius: 4)
        }
    }
    
    /// 빠른 액션 버튼들
    private var quickActions: some View {
        HStack(spacing: 20) {
            // 전화
            if let phone = contact.primaryPhone {
                QuickActionButton(
                    icon: "phone.fill",
                    title: "전화",
                    color: .green
                ) {
                    callPhone(phone)
                }
            }
            
            // 메시지
            if let phone = contact.primaryPhone {
                QuickActionButton(
                    icon: "message.fill",
                    title: "메시지",
                    color: .green
                ) {
                    sendMessage(to: phone)
                }
            }
            
            // 이메일
            if let email = contact.primaryEmail {
                QuickActionButton(
                    icon: "envelope.fill",
                    title: "메일",
                    color: .blue
                ) {
                    sendEmail(to: email)
                }
            }
            
            // FaceTime
            if let phone = contact.primaryPhone {
                QuickActionButton(
                    icon: "video.fill",
                    title: "FaceTime",
                    color: .green
                ) {
                    startFaceTime(with: phone)
                }
            }
        }
        .padding(.horizontal)
    }
    
    /// 상세 정보 섹션들
    private var detailSections: some View {
        VStack(spacing: 16) {
            // 전화번호 섹션
            if !contact.phoneNumbers.isEmpty {
                DetailSection(title: "전화") {
                    ForEach(contact.phoneNumbers) { phone in
                        DetailRow(
                            label: phone.label.isEmpty ? "전화" : phone.label,
                            value: phone.number,
                            icon: "phone.fill",
                            iconColor: .green
                        ) {
                            callPhone(phone.number)
                        }
                    }
                }
            }
            
            // 이메일 섹션
            if !contact.emails.isEmpty {
                DetailSection(title: "이메일") {
                    ForEach(contact.emails) { email in
                        DetailRow(
                            label: email.label.isEmpty ? "이메일" : email.label,
                            value: email.address,
                            icon: "envelope.fill",
                            iconColor: .blue
                        ) {
                            sendEmail(to: email.address)
                        }
                    }
                }
            }
            
            // 주소 섹션
            if !contact.addresses.isEmpty {
                DetailSection(title: "주소") {
                    ForEach(contact.addresses) { address in
                        DetailRow(
                            label: address.label.isEmpty ? "주소" : address.label,
                            value: address.fullAddress,
                            icon: "map.fill",
                            iconColor: .red
                        ) {
                            openInMaps(address: address.fullAddress)
                        }
                    }
                }
            }
            
            // 생일 섹션
            if let birthday = contact.birthday,
               let date = Calendar.current.date(from: birthday) {
                DetailSection(title: "생일") {
                    DetailRow(
                        label: "생일",
                        value: formatDate(date),
                        icon: "gift.fill",
                        iconColor: .pink
                    )
                }
            }
            
            // 메모 섹션
            if !contact.note.isEmpty {
                DetailSection(title: "메모") {
                    Text(contact.note)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
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
    
    /// 메시지 보내기
    private func sendMessage(to number: String) {
        let cleanNumber = number.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        if let url = URL(string: "sms://\(cleanNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    /// 이메일 보내기
    private func sendEmail(to email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    /// FaceTime 시작
    private func startFaceTime(with number: String) {
        let cleanNumber = number.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        if let url = URL(string: "facetime://\(cleanNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    /// 지도에서 열기
    private func openInMaps(address: String) {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
    
    /// 날짜 포맷팅
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    /// 연락처 삭제
    private func deleteContact() {
        Task {
            let success = await contactService.deleteContact(contact)
            if success {
                dismiss()
            }
        }
    }
}

// MARK: - QuickActionButton
// 빠른 액션 버튼 컴포넌트

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DetailSection
// 상세 정보 섹션 컨테이너

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 1) {
                content
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - DetailRow
// 상세 정보 행 컴포넌트

struct DetailRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    var iconColor: Color = .accentColor
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(iconColor)
                        .frame(width: 32)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(value)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding()
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

// MARK: - Preview

#Preview("연락처 상세") {
    ContactDetailView(contact: .sample)
        .environmentObject(ContactService())
}
