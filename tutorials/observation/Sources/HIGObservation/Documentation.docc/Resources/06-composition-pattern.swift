import SwiftUI
import Observation

// MARK: - 패턴 3: 컴포지션 패턴
// 여러 Observable을 조합하여 복잡한 상태 관리

@Observable
class UserProfile {
    var name: String
    var email: String
    var avatarURL: String?
    
    init(name: String, email: String, avatarURL: String? = nil) {
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
    }
}

@Observable
class UserPreferences {
    var theme: String
    var notificationsEnabled: Bool
    var language: String
    
    init(theme: String = "system", notificationsEnabled: Bool = true, language: String = "ko") {
        self.theme = theme
        self.notificationsEnabled = notificationsEnabled
        self.language = language
    }
}

@Observable
class UserStats {
    var orderCount: Int
    var totalSpent: Decimal
    var memberSince: Date
    
    init(orderCount: Int = 0, totalSpent: Decimal = 0, memberSince: Date = .now) {
        self.orderCount = orderCount
        self.totalSpent = totalSpent
        self.memberSince = memberSince
    }
}

// MARK: - 컴포지션: 여러 Observable 조합

@Observable
class UserAccount {
    var profile: UserProfile
    var preferences: UserPreferences
    var stats: UserStats
    
    init(
        profile: UserProfile,
        preferences: UserPreferences = UserPreferences(),
        stats: UserStats = UserStats()
    ) {
        self.profile = profile
        self.preferences = preferences
        self.stats = stats
    }
}

// MARK: - 분리된 뷰

struct ProfileSection: View {
    @Bindable var profile: UserProfile
    
    var body: some View {
        Section("프로필") {
            TextField("이름", text: $profile.name)
            TextField("이메일", text: $profile.email)
        }
    }
}

struct PreferencesSection: View {
    @Bindable var preferences: UserPreferences
    
    var body: some View {
        Section("설정") {
            Picker("테마", selection: $preferences.theme) {
                Text("시스템").tag("system")
                Text("라이트").tag("light")
                Text("다크").tag("dark")
            }
            Toggle("알림", isOn: $preferences.notificationsEnabled)
        }
    }
}

struct StatsSection: View {
    var stats: UserStats
    
    var body: some View {
        Section("활동") {
            LabeledContent("주문 횟수", value: "\(stats.orderCount)회")
            LabeledContent("총 구매액", value: "\(stats.totalSpent)원")
        }
    }
}

// MARK: - 통합 뷰

struct AccountView: View {
    var account: UserAccount
    
    var body: some View {
        Form {
            // 각 섹션이 독립적으로 업데이트됨
            ProfileSection(profile: account.profile)
            PreferencesSection(preferences: account.preferences)
            StatsSection(stats: account.stats)
        }
        .navigationTitle("계정")
    }
}
