import SwiftUI
import UserNotifications

// MARK: - 알림 권한 요청 뷰
// 앱 최초 실행 시 사용자에게 알림 권한을 안내하고 요청합니다.
// 권한의 종류와 용도를 명확하게 설명하여 허용률을 높입니다.

struct PermissionView: View {
    @Binding var status: UNAuthorizationStatus
    @State private var isRequesting = false
    @State private var currentPage = 0
    
    /// 온보딩 페이지 정보
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            symbol: "bell.badge.fill",
            title: "스마트 알림",
            description: "중요한 일정과 리마인더를\n적시에 알려드립니다.",
            color: .blue
        ),
        OnboardingPage(
            symbol: "location.fill",
            title: "위치 기반 알림",
            description: "특정 장소에 도착하거나 떠날 때\n자동으로 알림을 받으세요.",
            color: .green
        ),
        OnboardingPage(
            symbol: "sparkles",
            title: "맞춤 카테고리",
            description: "건강, 업무, 소셜 등\n카테고리별로 알림을 관리하세요.",
            color: .purple
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 온보딩 페이지
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    onboardingPageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 400)
            
            // 페이지 인디케이터
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.bottom, 32)
            
            // 권한 설명
            VStack(alignment: .leading, spacing: 12) {
                permissionRow(
                    symbol: "app.badge",
                    title: "배지",
                    description: "읽지 않은 알림 개수 표시"
                )
                permissionRow(
                    symbol: "speaker.wave.2",
                    title: "사운드",
                    description: "알림음으로 알려드림"
                )
                permissionRow(
                    symbol: "rectangle.topthird.inset.filled",
                    title: "배너",
                    description: "화면 상단에 알림 표시"
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            
            Spacer()
            
            // 권한 요청 버튼
            VStack(spacing: 12) {
                Button {
                    requestPermission()
                } label: {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("알림 허용하기")
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isRequesting)
                
                Button {
                    skipPermission()
                } label: {
                    Text("나중에 설정하기")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
    
    // MARK: - 온보딩 페이지 뷰
    
    private func onboardingPageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.symbol)
                    .font(.system(size: 60))
                    .foregroundStyle(page.color)
            }
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(page.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - 권한 설명 행
    
    private func permissionRow(symbol: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
    
    // MARK: - 액션
    
    private func requestPermission() {
        isRequesting = true
        
        Task {
            do {
                let granted = try await NotificationService.shared.requestAuthorization()
                
                await MainActor.run {
                    isRequesting = false
                    status = granted ? .authorized : .denied
                }
            } catch {
                await MainActor.run {
                    isRequesting = false
                    status = .denied
                }
            }
        }
    }
    
    private func skipPermission() {
        // provisional 상태로 진행 (조용한 알림만 받음)
        Task {
            do {
                _ = try await NotificationService.shared.requestAuthorization()
            } catch {
                print("권한 요청 실패: \(error)")
            }
            
            await MainActor.run {
                // 권한이 결정되지 않았어도 앱 사용 허용
                status = .provisional
            }
        }
    }
}

// MARK: - 온보딩 페이지 데이터

struct OnboardingPage {
    let symbol: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Preview

#Preview {
    PermissionView(status: .constant(.notDetermined))
}
