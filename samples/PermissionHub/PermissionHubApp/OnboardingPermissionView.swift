// OnboardingPermissionView.swift
// PermissionHub - iOS 26 PermissionKit 샘플
// 온보딩 권한 요청 화면

import SwiftUI
import PermissionKit

// MARK: - 온보딩 권한 요청 뷰
struct OnboardingPermissionView: View {
    @Environment(PermissionManager.self) private var permissionManager
    @Binding var hasCompletedOnboarding: Bool
    
    /// 현재 페이지 인덱스
    @State private var currentPage = 0
    
    /// 권한 요청 중 여부
    @State private var isRequesting = false
    
    /// 모든 필수 권한 요청 완료 여부
    @State private var hasRequestedAllEssential = false
    
    /// 애니메이션 효과
    @State private var animateIcon = false
    
    /// 온보딩에서 요청할 권한 목록
    private let onboardingPermissions: [PermissionType] = [
        .notifications,
        .camera,
        .microphone,
        .photoLibrary,
        .location
    ]
    
    var body: some View {
        ZStack {
            // 배경 그라데이션
            backgroundGradient
            
            VStack(spacing: 0) {
                // 페이지 인디케이터
                pageIndicator
                    .padding(.top, 20)
                
                // 메인 컨텐츠
                TabView(selection: $currentPage) {
                    // 환영 페이지
                    welcomePage
                        .tag(0)
                    
                    // 권한 요청 페이지들
                    ForEach(Array(onboardingPermissions.enumerated()), id: \.element) { index, permission in
                        PermissionRequestPage(
                            permission: permission,
                            isRequesting: $isRequesting,
                            onComplete: {
                                moveToNextPage()
                            }
                        )
                        .tag(index + 1)
                    }
                    
                    // 완료 페이지
                    completionPage
                        .tag(onboardingPermissions.count + 1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // 하단 버튼
                bottomButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            animateIcon = true
        }
    }
    
    // MARK: - 배경 그라데이션
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.3),
                Color.purple.opacity(0.2),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - 페이지 인디케이터
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring, value: currentPage)
            }
        }
    }
    
    private var totalPages: Int {
        onboardingPermissions.count + 2 // 환영 + 권한들 + 완료
    }
    
    // MARK: - 환영 페이지
    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // 앱 아이콘
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .blue.opacity(0.3), radius: 20, y: 10)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(.white)
                    .scaleEffect(animateIcon ? 1 : 0.8)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.6)
                        .repeatForever(autoreverses: true),
                        value: animateIcon
                    )
            }
            
            VStack(spacing: 16) {
                Text("Permission Hub에\n오신 것을 환영합니다")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("최상의 앱 경험을 위해\n몇 가지 권한이 필요합니다")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // 권한 미리보기
            VStack(spacing: 12) {
                ForEach(onboardingPermissions.prefix(3), id: \.self) { permission in
                    HStack(spacing: 12) {
                        Image(systemName: permission.iconName)
                            .font(.title3)
                            .foregroundStyle(.blue)
                            .frame(width: 32)
                        
                        Text(permission.displayName)
                            .font(.subheadline)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.8))
                    }
                }
                
                if onboardingPermissions.count > 3 {
                    Text("외 \(onboardingPermissions.count - 3)개 더...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - 완료 페이지
    private var completionPage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // 완료 아이콘
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
            }
            
            VStack(spacing: 16) {
                Text("준비 완료!")
                    .font(.title.bold())
                
                Text("모든 권한 설정이 완료되었습니다.\n이제 앱을 사용할 수 있습니다.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // 권한 요약
            permissionSummary
            
            Spacer()
        }
    }
    
    // MARK: - 권한 요약
    private var permissionSummary: some View {
        VStack(spacing: 12) {
            Text("권한 요약")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(onboardingPermissions, id: \.self) { type in
                    let info = permissionManager.permissionInfo(for: type)
                    HStack {
                        Image(systemName: info.iconName)
                            .foregroundStyle(.blue)
                            .frame(width: 24)
                        
                        Text(info.displayName)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Image(systemName: info.status.iconName)
                            .foregroundStyle(info.status.isGranted ? .green : .orange)
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - 하단 버튼
    private var bottomButton: some View {
        Group {
            if currentPage == 0 {
                // 시작 버튼
                Button {
                    withAnimation {
                        currentPage = 1
                    }
                } label: {
                    Text("시작하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
            } else if currentPage == totalPages - 1 {
                // 완료 버튼
                Button {
                    completeOnboarding()
                } label: {
                    Text("앱 시작하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
            } else {
                // 건너뛰기 & 다음 버튼
                HStack(spacing: 16) {
                    Button {
                        moveToNextPage()
                    } label: {
                        Text("건너뛰기")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        moveToNextPage()
                    } label: {
                        HStack {
                            Text("다음")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isRequesting)
                }
            }
        }
    }
    
    // MARK: - 액션
    private func moveToNextPage() {
        withAnimation {
            if currentPage < totalPages - 1 {
                currentPage += 1
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

// MARK: - 권한 요청 페이지
struct PermissionRequestPage: View {
    let permission: PermissionType
    @Binding var isRequesting: Bool
    let onComplete: () -> Void
    
    @Environment(PermissionManager.self) private var permissionManager
    
    /// 요청 완료 여부
    @State private var hasRequested = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // 권한 아이콘
            permissionIcon
            
            // 권한 정보
            VStack(spacing: 16) {
                Text(permission.displayName)
                    .font(.title.bold())
                
                Text(permission.usageDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            // 권한 상태 표시
            if hasRequested {
                currentStatusView
            }
            
            Spacer()
            
            // 요청 버튼
            requestButton
                .padding(.horizontal, 24)
        }
    }
    
    // MARK: - 권한 아이콘
    private var permissionIcon: some View {
        ZStack {
            Circle()
                .fill(themeColor.opacity(0.15))
                .frame(width: 100, height: 100)
            
            Image(systemName: permission.iconName)
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(themeColor)
        }
    }
    
    private var themeColor: Color {
        switch permission.themeColor {
        case "systemBlue": return .blue
        case "systemRed": return .red
        case "systemGreen": return .green
        case "systemOrange": return .orange
        case "systemPurple": return .purple
        case "systemPink": return .pink
        case "systemYellow": return .yellow
        default: return .blue
        }
    }
    
    // MARK: - 현재 상태 뷰
    private var currentStatusView: some View {
        let info = permissionManager.permissionInfo(for: permission)
        
        return HStack {
            Image(systemName: info.status.iconName)
            Text(info.status.displayText)
        }
        .font(.headline)
        .foregroundStyle(info.status.isGranted ? .green : .orange)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            Capsule()
                .fill(info.status.isGranted ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
        }
    }
    
    // MARK: - 요청 버튼
    private var requestButton: some View {
        let info = permissionManager.permissionInfo(for: permission)
        
        return Group {
            if info.status.canRequest {
                Button {
                    requestPermission()
                } label: {
                    if isRequesting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        Text("권한 허용하기")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRequesting)
            } else if info.status.isGranted {
                Label("권한이 허용되었습니다", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    }
            } else {
                VStack(spacing: 12) {
                    Text("설정 앱에서 권한을 변경할 수 있습니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        SettingsHelper.openAppSettings()
                    } label: {
                        Label("설정 열기", systemImage: "gear")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    // MARK: - 권한 요청
    private func requestPermission() {
        isRequesting = true
        
        Task {
            _ = await permissionManager.requestPermission(for: permission)
            hasRequested = true
            isRequesting = false
            
            // 잠시 후 다음 페이지로 이동
            try? await Task.sleep(for: .seconds(0.5))
            onComplete()
        }
    }
}

// MARK: - 권한 요청 모달
/// 특정 권한을 요청하는 모달 뷰 (온보딩 외에서 사용)
struct PermissionRequestModal: View {
    let permission: PermissionType
    let onDismiss: () -> Void
    
    @Environment(PermissionManager.self) private var permissionManager
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 24) {
            // 핸들
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // 아이콘
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: permission.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)
            }
            
            // 제목 및 설명
            VStack(spacing: 8) {
                Text("\(permission.displayName) 권한 필요")
                    .font(.title2.bold())
                
                Text(permission.usageDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 버튼들
            VStack(spacing: 12) {
                Button {
                    requestPermission()
                } label: {
                    if isRequesting {
                        ProgressView()
                    } else {
                        Text("허용하기")
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(isRequesting)
                
                Button {
                    onDismiss()
                } label: {
                    Text("나중에")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
    
    private func requestPermission() {
        isRequesting = true
        Task {
            _ = await permissionManager.requestPermission(for: permission)
            isRequesting = false
            onDismiss()
        }
    }
}

// MARK: - Preview
#Preview("온보딩") {
    OnboardingPermissionView(hasCompletedOnboarding: .constant(false))
        .environment(PermissionManager())
}

#Preview("권한 요청 페이지") {
    PermissionRequestPage(
        permission: .camera,
        isRequesting: .constant(false),
        onComplete: {}
    )
    .environment(PermissionManager())
}
