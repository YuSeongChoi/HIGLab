import Observation
import SwiftUI

/// 저장 프로퍼티는 자동으로 관찰됩니다
@Observable
class UserProfile {
    // ✅ 저장 프로퍼티 - 자동 추적
    var name: String = ""
    var age: Int = 0
    var email: String = ""
    var isVerified: Bool = false
    
    // ✅ 옵셔널도 자동 추적
    var avatarURL: URL?
    
    // ✅ 컬렉션도 자동 추적
    var tags: [String] = []
}

struct ProfileView: View {
    var profile: UserProfile
    
    var body: some View {
        let _ = Self._printChanges() // 디버깅용
        
        VStack {
            // name만 읽음 → name 변경 시에만 업데이트
            Text(profile.name)
                .font(.title)
            
            // age만 읽음 → age 변경 시에만 업데이트
            Text("\(profile.age)세")
        }
    }
}

// 💡 팁: Self._printChanges()로 뷰가 언제 업데이트되는지 확인하세요!
// email이 바뀌어도 위 뷰는 업데이트되지 않습니다.
