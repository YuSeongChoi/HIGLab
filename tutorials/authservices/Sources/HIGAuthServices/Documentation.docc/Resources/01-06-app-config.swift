// Apple Developer 포털 설정

// 1. developer.apple.com > Certificates, IDs & Profiles
// 2. Identifiers > 앱 선택
// 3. Capabilities에서 "Sign in with Apple" 활성화
// 4. "Edit" 클릭하여 세부 설정:
//    - "Enable as a primary App ID" 선택
//    - 또는 그룹으로 묶을 경우 "Group with an existing primary App ID"

// App ID 예시
struct AppConfiguration {
    static let bundleID = "com.example.myapp"
    static let teamID = "ABC123XYZ"
    
    // Sign in with Apple은 Team ID + Bundle ID로 
    // 앱을 식별합니다
}
