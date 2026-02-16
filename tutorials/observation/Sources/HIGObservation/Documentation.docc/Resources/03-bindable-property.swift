import SwiftUI
import Observation

/// 패턴 1: 프로퍼티에서 @Bindable 사용
/// 가장 일반적인 패턴입니다.

@Observable
class Profile {
    var name: String = ""
    var bio: String = ""
    var isPublic: Bool = true
}

struct ProfileEditorView: View {
    // ✅ 프로퍼티에 @Bindable 붙이기
    @Bindable var profile: Profile
    
    var body: some View {
        Form {
            Section("기본 정보") {
                TextField("이름", text: $profile.name)
                TextField("소개", text: $profile.bio, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section("공개 설정") {
                Toggle("프로필 공개", isOn: $profile.isPublic)
            }
        }
    }
}

// 사용 예시
struct ProfileScreen: View {
    @State private var profile = Profile()
    
    var body: some View {
        NavigationStack {
            // Profile을 전달하면 ProfileEditorView에서 @Bindable로 받음
            ProfileEditorView(profile: profile)
                .navigationTitle("프로필 수정")
        }
    }
}
