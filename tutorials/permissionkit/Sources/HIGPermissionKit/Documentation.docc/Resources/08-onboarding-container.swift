#if canImport(PermissionKit)
import PermissionKit
import SwiftUI

// 페이지 기반 온보딩 컨테이너
struct OnboardingContainer: View {
    @State private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            // 배경
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                // 진행 표시기
                ProgressIndicator(
                    totalSteps: OnboardingViewModel.OnboardingStep.allCases.count,
                    currentStep: viewModel.currentStep.rawValue
                )
                .padding()
                
                // 현재 단계 콘텐츠
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView(onContinue: { viewModel.goToNextStep() })
                        .tag(OnboardingViewModel.OnboardingStep.welcome)
                    
                    NotificationStepView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.notifications)
                    
                    CameraStepView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.camera)
                    
                    LocationStepView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.location)
                    
                    CompleteStepView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.complete)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)
            }
        }
    }
}

// 진행 표시기
struct ProgressIndicator: View {
    let totalSteps: Int
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(height: 4)
            }
        }
    }
}

// 환영 화면
struct WelcomeStepView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
            Text("환영합니다!")
                .font(.largeTitle.bold())
            
            Text("앱을 최대한 활용하기 위해\n몇 가지 권한을 설정해주세요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button("시작하기", action: onContinue)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding()
    }
}

// 알림 권한 화면
struct NotificationStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        PrePermissionView(
            icon: "bell.badge.fill",
            iconColor: .red,
            title: "알림 받기",
            description: "중요한 소식을 놓치지 마세요",
            benefits: [
                .init(icon: "gift.fill", text: "특별 이벤트 알림"),
                .init(icon: "clock.fill", text: "리마인더"),
                .init(icon: "star.fill", text: "새 기능 안내")
            ],
            primaryButtonTitle: "알림 허용하기",
            secondaryButtonTitle: "나중에",
            onPrimaryAction: {
                requestNotificationPermission()
            },
            onSecondaryAction: {
                viewModel.goToNextStep()
            }
        )
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            Task { @MainActor in
                viewModel.refreshAllStatuses()
                viewModel.goToNextStep()
            }
        }
    }
}

// 카메라 권한 화면
struct CameraStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        PrePermissionView(
            icon: "camera.fill",
            iconColor: .blue,
            title: "카메라 접근",
            description: "사진 촬영과 QR 스캔에 사용됩니다",
            benefits: [
                .init(icon: "person.crop.circle", text: "프로필 사진 촬영"),
                .init(icon: "qrcode.viewfinder", text: "QR 코드 스캔")
            ],
            primaryButtonTitle: "카메라 허용하기",
            secondaryButtonTitle: "건너뛰기",
            onPrimaryAction: {
                Task {
                    await AVCaptureDevice.requestAccess(for: .video)
                    await MainActor.run {
                        viewModel.refreshAllStatuses()
                        viewModel.goToNextStep()
                    }
                }
            },
            onSecondaryAction: {
                viewModel.goToNextStep()
            }
        )
    }
}

// 위치 권한 화면
struct LocationStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    @State private var locationManager = CLLocationManager()
    
    var body: some View {
        PrePermissionView(
            icon: "location.fill",
            iconColor: .green,
            title: "위치 정보",
            description: "주변 서비스를 찾을 때 사용됩니다",
            benefits: [
                .init(icon: "map.fill", text: "가까운 매장 찾기"),
                .init(icon: "car.fill", text: "배달 현황 확인")
            ],
            primaryButtonTitle: "위치 허용하기",
            secondaryButtonTitle: "건너뛰기",
            onPrimaryAction: {
                locationManager.requestWhenInUseAuthorization()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewModel.refreshAllStatuses()
                    viewModel.goToNextStep()
                }
            },
            onSecondaryAction: {
                viewModel.goToNextStep()
            }
        )
    }
}

// 완료 화면
struct CompleteStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("설정 완료!")
                .font(.largeTitle.bold())
            
            Text("이제 앱을 사용할 준비가 되었습니다.")
                .foregroundStyle(.secondary)
            
            // 권한 상태 요약
            VStack(alignment: .leading, spacing: 12) {
                PermissionStatusRow(
                    icon: "bell.fill",
                    title: "알림",
                    isGranted: viewModel.notificationStatus == .authorized
                )
                PermissionStatusRow(
                    icon: "camera.fill",
                    title: "카메라",
                    isGranted: viewModel.cameraStatus == .authorized
                )
                PermissionStatusRow(
                    icon: "location.fill",
                    title: "위치",
                    isGranted: viewModel.locationStatus == .authorizedWhenInUse ||
                              viewModel.locationStatus == .authorizedAlways
                )
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer()
            
            Button("시작하기") {
                viewModel.completeOnboarding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

struct PermissionStatusRow: View {
    let icon: String
    let title: String
    let isGranted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
            Spacer()
            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(isGranted ? .green : .secondary)
        }
    }
}

import AVFoundation
import CoreLocation
import UserNotifications

// iOS 26 PermissionKit - HIG Lab
#endif
