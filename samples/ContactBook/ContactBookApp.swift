import SwiftUI

// MARK: - ContactBook 앱 진입점
// Contacts Framework를 활용한 연락처 관리 앱
// CNContactStore를 통해 시스템 연락처에 접근하고 관리합니다

@main
struct ContactBookApp: App {
    // MARK: - Properties
    
    /// 연락처 서비스 - 앱 전체에서 공유
    @StateObject private var contactService = ContactService()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contactService)
        }
    }
}

// MARK: - ContentView
// 앱의 메인 컨테이너 뷰

struct ContentView: View {
    // MARK: - Properties
    
    @EnvironmentObject var contactService: ContactService
    
    /// 현재 선택된 탭
    @State private var selectedTab = 0
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 연락처 목록 탭
            ContactListView()
                .tabItem {
                    Label("연락처", systemImage: "person.crop.circle")
                }
                .tag(0)
            
            // 그룹 관리 탭
            GroupListView()
                .tabItem {
                    Label("그룹", systemImage: "person.3")
                }
                .tag(1)
            
            // 연락처 선택기 탭 (CNContactPicker 데모)
            ContactPickerDemoView()
                .tabItem {
                    Label("선택기", systemImage: "person.crop.circle.badge.checkmark")
                }
                .tag(2)
        }
        .onAppear {
            // 앱 시작 시 권한 요청
            contactService.requestAccess()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(ContactService())
}
