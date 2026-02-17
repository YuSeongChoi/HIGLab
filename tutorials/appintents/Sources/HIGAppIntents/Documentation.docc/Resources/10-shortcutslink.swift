import SwiftUI
import AppIntents

struct SettingsView: View {
    var body: some View {
        Form {
            Section("일반") {
                // 일반 설정...
            }
            
            Section("Siri & 단축어") {
                // 단축어 앱으로 이동하는 링크
                ShortcutsLink()
                
                // 또는 앱별 단축어로 이동
                ShortcutsLink(action: .open)
                
                // 설명 추가
                VStack(alignment: .leading, spacing: 4) {
                    ShortcutsLink()
                    Text("단축어 앱에서 더 많은 자동화를 설정하세요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                // Siri 음성 명령 안내
                SiriTipView(intent: SearchBooksIntent())
            } header: {
                Text("음성으로 사용하기")
            }
        }
        .navigationTitle("설정")
    }
}
