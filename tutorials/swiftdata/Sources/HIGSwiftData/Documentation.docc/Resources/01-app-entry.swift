import SwiftUI
import SwiftData

// TaskMaster 앱 진입점
// 아직 SwiftData 설정 없이 기본 구조만 준비

@main
struct TaskMasterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // 다음 챕터에서 여기에 .modelContainer 추가 예정
    }
}

// ─────────────────────────────────────────

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green.gradient)
                
                Text("TaskMaster")
                    .font(.largeTitle.bold())
                
                Text("SwiftData로 만드는 할 일 관리 앱")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("🚀 튜토리얼 시작 준비 완료!")
                    .font(.headline)
                    .padding()
                    .background(.green.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .navigationTitle("환영합니다")
        }
    }
}

#Preview {
    ContentView()
}
