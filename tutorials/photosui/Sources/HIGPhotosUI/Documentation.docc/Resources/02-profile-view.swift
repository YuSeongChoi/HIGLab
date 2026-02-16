// 완성된 프로필 화면

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @State private var profileImage: Image?
    @State private var name: String = "사용자"
    @State private var bio: String = "안녕하세요!"
    
    var body: some View {
        NavigationStack {
            Form {
                // 프로필 이미지 섹션
                Section {
                    HStack {
                        Spacer()
                        ProfileImagePicker(image: $profileImage, size: 100)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                // 기본 정보
                Section("기본 정보") {
                    TextField("이름", text: $name)
                    TextField("소개", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // 계정 설정
                Section("계정") {
                    Label("이메일 변경", systemImage: "envelope")
                    Label("비밀번호 변경", systemImage: "lock")
                    Label("알림 설정", systemImage: "bell")
                }
                
                // 저장 버튼
                Section {
                    Button {
                        saveProfile()
                    } label: {
                        Text("저장하기")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("프로필 편집")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveProfile() {
        // 프로필 저장 로직
        print("프로필 저장: \(name)")
    }
}

#Preview {
    ProfileView()
}
