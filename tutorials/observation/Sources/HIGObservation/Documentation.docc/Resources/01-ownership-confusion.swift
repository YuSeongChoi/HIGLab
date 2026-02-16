import SwiftUI

class UserSettings: ObservableObject {
    @Published var theme: String = "light"
}

/// ❓ @StateObject vs @ObservedObject - 어떤 걸 써야 하나요?
/// 
/// @StateObject: 뷰가 객체를 "소유"할 때 (생성 책임)
/// @ObservedObject: 뷰가 객체를 "참조"할 때 (외부에서 주입)
///
/// 잘못 선택하면 문제 발생!

struct ParentView: View {
    // ✅ 여기서 객체를 생성하므로 @StateObject 사용
    @StateObject private var settings = UserSettings()
    
    var body: some View {
        ChildView(settings: settings)
    }
}

struct ChildView: View {
    // ✅ 외부에서 받았으므로 @ObservedObject 사용
    @ObservedObject var settings: UserSettings
    
    var body: some View {
        Text(settings.theme)
    }
}

/// ❌ 흔한 실수: 매번 새 객체 생성
struct BuggyView: View {
    // 💥 @ObservedObject로 직접 생성하면 뷰가 다시 그려질 때마다 새 객체!
    @ObservedObject var settings = UserSettings() // 버그!
    
    var body: some View {
        Text(settings.theme)
    }
}
