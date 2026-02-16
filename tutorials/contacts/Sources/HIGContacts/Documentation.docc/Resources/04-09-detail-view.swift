import SwiftUI

struct ContactDetailView: View {
    let contact: ContactModel
    
    var body: some View {
        List {
            // 프로필 이미지
            Section {
                HStack {
                    Spacer()
                    if let imageData = contact.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
            }
            
            // 전화번호
            Section("전화번호") {
                ForEach(contact.phoneNumbers, id: \.number) { phone in
                    LabeledContent(phone.label, value: phone.number)
                }
            }
            
            // 이메일
            Section("이메일") {
                ForEach(contact.emails, id: \.self) { email in
                    Text(email)
                }
            }
        }
        .navigationTitle(contact.fullName)
    }
}
