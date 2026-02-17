import SwiftUI
import TipKit

/// 설정 화면
/// TipKit 디버깅 및 팁 리셋 기능을 제공합니다.
struct SettingsView: View {
    @State private var showResetAlert = false
    @State private var resetCompleted = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - TipKit 정보 섹션
                Section {
                    InfoRow(title: "TipKit 버전", value: "iOS 17+")
                    InfoRow(title: "데이터 저장 위치", value: "앱 기본 위치")
                } header: {
                    Text("TipKit 정보")
                }
                
                // MARK: - 디버그 섹션
                Section {
                    // 모든 팁 리셋 버튼
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("모든 팁 초기화")
                        }
                    }
                    
                    // 특정 팁만 리셋하는 예제
                    Button {
                        resetSpecificTip()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("즐겨찾기 팁만 리셋")
                        }
                    }
                    
                    // 테스트용: 모든 팁 표시
                    Button {
                        showAllTipsForTesting()
                    } label: {
                        HStack {
                            Image(systemName: "eye.fill")
                            Text("모든 팁 강제 표시 (테스트)")
                        }
                    }
                } header: {
                    Text("디버그 도구")
                } footer: {
                    Text("개발 및 테스트 목적으로 팁 상태를 관리합니다.")
                }
                
                // MARK: - 팁 사용법 섹션
                Section {
                    TipUsageRow(
                        icon: "text.bubble.fill",
                        title: "TipView",
                        description: "화면에 인라인으로 팁 표시"
                    )
                    
                    TipUsageRow(
                        icon: "bubble.left.fill",
                        title: ".popoverTip()",
                        description: "UI 요소에 팝오버로 팁 연결"
                    )
                    
                    TipUsageRow(
                        icon: "bell.fill",
                        title: "이벤트 기반",
                        description: "조건 충족 시 팁 표시"
                    )
                    
                    TipUsageRow(
                        icon: "hand.tap.fill",
                        title: "액션 팁",
                        description: "사용자 선택 가능한 버튼 포함"
                    )
                } header: {
                    Text("TipKit 사용법")
                }
            }
            .navigationTitle("설정")
            .alert("팁 초기화", isPresented: $showResetAlert) {
                Button("취소", role: .cancel) { }
                Button("초기화", role: .destructive) {
                    resetAllTips()
                }
            } message: {
                Text("모든 팁이 초기 상태로 되돌아갑니다. 팁들이 다시 표시됩니다.")
            }
            .alert("완료", isPresented: $resetCompleted) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("팁이 성공적으로 초기화되었습니다.")
            }
        }
    }
    
    // MARK: - 팁 리셋 함수들
    
    /// 모든 팁 데이터 초기화
    private func resetAllTips() {
        Task {
            do {
                // 전체 팁 데이터스토어 리셋
                try Tips.resetDatastore()
                
                await MainActor.run {
                    resetCompleted = true
                }
                print("✅ 모든 팁이 리셋되었습니다.")
            } catch {
                print("❌ 팁 리셋 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// 특정 팁만 리셋
    private func resetSpecificTip() {
        // 특정 팁의 상태만 초기화하려면 해당 팁 타입으로 리셋
        let favoriteTip = FavoriteTip()
        favoriteTip.invalidate(reason: .tipClosed)
        print("✅ 즐겨찾기 팁이 리셋되었습니다.")
    }
    
    /// 테스트용: 모든 팁 강제 표시 설정
    private func showAllTipsForTesting() {
        Task {
            // 테스트를 위해 팁 표시 빈도를 즉시로 설정
            try? Tips.configure([
                .displayFrequency(.immediate)
            ])
            print("✅ 테스트 모드: 모든 팁이 즉시 표시됩니다.")
        }
    }
}

// MARK: - 헬퍼 뷰들

/// 정보 행 뷰
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

/// 팁 사용법 설명 행 뷰
struct TipUsageRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
}
