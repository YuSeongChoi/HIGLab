import PermissionKit
import SwiftUI

// 완성된 온보딩 경험
struct CompleteOnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 배경 그라디언트
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 헤더: 진행 표시기
                HStack {
                    ProgressView(value: progressValue)
                        .tint(.accentColor)
                    
                    Text("\(viewModel.currentStep.rawValue + 1)/\(OnboardingViewModel.OnboardingStep.allCases.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 40)
                }
                .padding()
                
                // 콘텐츠 영역
                TabView(selection: $viewModel.currentStep) {
                    ForEach(OnboardingViewModel.OnboardingStep.allCases, id: \.self) { step in
                        OnboardingStepContent(step: step, viewModel: viewModel)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.currentStep)
            }
        }
        .interactiveDismissDisabled(!viewModel.isOnboardingComplete)
        .onChange(of: viewModel.isOnboardingComplete) { _, isComplete in
            if isComplete {
                dismiss()
            }
        }
    }
    
    private var progressValue: Double {
        Double(viewModel.currentStep.rawValue) / Double(OnboardingViewModel.OnboardingStep.allCases.count - 1)
    }
}

// 각 단계별 콘텐츠
struct OnboardingStepContent: View {
    let step: OnboardingViewModel.OnboardingStep
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack {
            switch step {
            case .welcome:
                AnimatedWelcomeView {
                    viewModel.goToNextStep()
                }
                
            case .notifications:
                AnimatedPermissionView(
                    explanation: .notification,
                    onAllow: {
                        requestNotificationPermission()
                    },
                    onSkip: {
                        viewModel.goToNextStep()
                    }
                )
                
            case .camera:
                AnimatedPermissionView(
                    explanation: .camera,
                    onAllow: {
                        Task {
                            await AVCaptureDevice.requestAccess(for: .video)
                            await MainActor.run {
                                viewModel.refreshAllStatuses()
                                viewModel.goToNextStep()
                            }
                        }
                    },
                    onSkip: {
                        viewModel.goToNextStep()
                    }
                )
                
            case .location:
                AnimatedPermissionView(
                    explanation: .location,
                    onAllow: {
                        CLLocationManager().requestWhenInUseAuthorization()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            viewModel.refreshAllStatuses()
                            viewModel.goToNextStep()
                        }
                    },
                    onSkip: {
                        viewModel.goToNextStep()
                    }
                )
                
            case .complete:
                AnimatedCompleteView(viewModel: viewModel) {
                    viewModel.completeOnboarding()
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            Task { @MainActor in
                viewModel.refreshAllStatuses()
                viewModel.goToNextStep()
            }
        }
    }
}

// 애니메이션이 적용된 환영 화면
struct AnimatedWelcomeView: View {
    let onContinue: () -> Void
    @State private var isAnimated = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
                .scaleEffect(isAnimated ? 1 : 0.5)
                .opacity(isAnimated ? 1 : 0)
            
            VStack(spacing: 12) {
                Text("환영합니다!")
                    .font(.largeTitle.bold())
                    .offset(y: isAnimated ? 0 : 20)
                    .opacity(isAnimated ? 1 : 0)
                
                Text("최고의 경험을 위해 몇 가지 설정이 필요합니다")
                    .foregroundStyle(.secondary)
                    .offset(y: isAnimated ? 0 : 20)
                    .opacity(isAnimated ? 1 : 0)
            }
            
            Spacer()
            
            Button("시작하기", action: onContinue)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .opacity(isAnimated ? 1 : 0)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isAnimated = true
            }
        }
    }
}

// 애니메이션이 적용된 권한 요청 화면
struct AnimatedPermissionView: View {
    let explanation: PermissionExplanation
    let onAllow: () -> Void
    let onSkip: () -> Void
    
    @State private var isAnimated = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: explanation.icon)
                .font(.system(size: 70))
                .foregroundStyle(explanation.iconColor.gradient)
                .rotationEffect(.degrees(isAnimated ? 0 : -10))
                .scaleEffect(isAnimated ? 1 : 0.8)
            
            Text(explanation.title)
                .font(.title.bold())
            
            Text(explanation.description)
                .foregroundStyle(.secondary)
            
            // 혜택 목록
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(explanation.benefits.enumerated()), id: \.element.id) { index, benefit in
                    HStack(spacing: 12) {
                        Image(systemName: benefit.icon)
                            .foregroundStyle(explanation.iconColor)
                            .frame(width: 24)
                        Text(benefit.text)
                    }
                    .offset(x: isAnimated ? 0 : -50)
                    .opacity(isAnimated ? 1 : 0)
                    .animation(.spring(response: 0.6).delay(Double(index) * 0.1), value: isAnimated)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer()
            
            VStack(spacing: 12) {
                Button("허용하기", action: onAllow)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                
                Button("나중에", action: onSkip)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6)) {
                isAnimated = true
            }
        }
        .onDisappear {
            isAnimated = false
        }
    }
}

// 애니메이션이 적용된 완료 화면
struct AnimatedCompleteView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onComplete: () -> Void
    
    @State private var showConfetti = false
    @State private var isAnimated = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                    .scaleEffect(isAnimated ? 1 : 0)
            }
            
            Text("준비 완료!")
                .font(.largeTitle.bold())
                .opacity(isAnimated ? 1 : 0)
            
            // 설정된 권한 요약
            VStack(spacing: 12) {
                SummaryRow(
                    icon: "bell.fill",
                    title: "알림",
                    isEnabled: viewModel.notificationStatus == .authorized
                )
                SummaryRow(
                    icon: "camera.fill",
                    title: "카메라",
                    isEnabled: viewModel.cameraStatus == .authorized
                )
                SummaryRow(
                    icon: "location.fill",
                    title: "위치",
                    isEnabled: viewModel.locationStatus == .authorizedWhenInUse ||
                              viewModel.locationStatus == .authorizedAlways
                )
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .opacity(isAnimated ? 1 : 0)
            
            Text("설정은 언제든 변경할 수 있습니다")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button("시작하기", action: onComplete)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                isAnimated = true
            }
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let title: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
            Text(title)
            Spacer()
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isEnabled ? .green : .secondary)
        }
    }
}

import AVFoundation
import CoreLocation
import UserNotifications

// iOS 26 PermissionKit - HIG Lab
