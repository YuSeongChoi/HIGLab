// ProcessingView.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 활용

import SwiftUI

/// 이미지 처리 중 상태를 표시하는 뷰
/// 프로그레스 인디케이터와 상태 메시지를 보여줍니다
struct ProcessingView: View {
    /// 현재 처리 상태
    let state: ProcessingState
    
    /// 애니메이션을 위한 회전 각도
    @State private var rotationAngle: Double = 0
    
    /// 펄스 애니메이션 스케일
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 32) {
            // 애니메이션 아이콘
            animatedIcon
            
            // 진행률 표시
            progressSection
            
            // 상태 메시지
            statusMessage
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 20)
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - 애니메이션 아이콘
    
    private var animatedIcon: some View {
        ZStack {
            // 외부 링
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [.blue, .purple, .pink, .blue],
                        center: .center
                    ),
                    lineWidth: 4
                )
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(rotationAngle))
            
            // 내부 아이콘
            Group {
                switch state {
                case .loading:
                    Image(systemName: "photo")
                case .analyzingSubject:
                    Image(systemName: "person.and.background.dotted")
                case .croppingSubject:
                    Image(systemName: "crop")
                case .removingBackground:
                    Image(systemName: "person.crop.rectangle.badge.plus")
                case .extending:
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                default:
                    Image(systemName: "wand.and.stars")
                }
            }
            .font(.system(size: 36))
            .foregroundStyle(.primary)
            .scaleEffect(pulseScale)
        }
    }
    
    // MARK: - 진행률 섹션
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            // 진행률 바
            ProgressView(value: state.progress)
                .progressViewStyle(CustomProgressStyle())
                .frame(width: 200)
            
            // 진행률 퍼센트
            Text("\(Int(state.progress * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
    
    // MARK: - 상태 메시지
    
    private var statusMessage: some View {
        VStack(spacing: 4) {
            Text(state.message)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(stateDescription)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// 상태별 추가 설명
    private var stateDescription: String {
        switch state {
        case .loading:
            return "이미지를 메모리에 로드하고 있습니다"
        case .analyzingSubject:
            return "AI가 이미지 속 피사체를 분석하고 있습니다"
        case .croppingSubject:
            return "피사체에 맞춰 최적의 크롭 영역을 계산 중입니다"
        case .removingBackground:
            return "피사체와 배경을 분리하고 있습니다"
        case .extending:
            return "이미지 영역을 자연스럽게 확장하고 있습니다"
        default:
            return ""
        }
    }
    
    // MARK: - 애니메이션
    
    private func startAnimations() {
        // 회전 애니메이션
        withAnimation(
            .linear(duration: 2)
            .repeatForever(autoreverses: false)
        ) {
            rotationAngle = 360
        }
        
        // 펄스 애니메이션
        withAnimation(
            .easeInOut(duration: 1)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.1
        }
    }
}

// MARK: - 커스텀 프로그레스 스타일

/// 그라데이션 프로그레스 바 스타일
struct CustomProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray5))
                    .frame(height: 12)
                
                // 진행률 바
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * (configuration.fractionCompleted ?? 0),
                        height: 12
                    )
                    .animation(.easeInOut(duration: 0.3), value: configuration.fractionCompleted)
            }
        }
        .frame(height: 12)
    }
}

// MARK: - 처리 오류 뷰

/// 처리 실패 시 표시되는 뷰
struct ProcessingErrorView: View {
    /// 발생한 오류
    let error: ProcessingError
    
    /// 재시도 액션
    let retryAction: () -> Void
    
    /// 취소 액션
    let cancelAction: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // 오류 아이콘
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            // 오류 메시지
            VStack(spacing: 8) {
                Text("처리 실패")
                    .font(.headline)
                
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // 액션 버튼
            HStack(spacing: 16) {
                Button("취소", action: cancelAction)
                    .buttonStyle(.bordered)
                
                Button("다시 시도", action: retryAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - 미리보기

#Preview("처리 중") {
    ProcessingView(state: .analyzingSubject)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
}

#Preview("오류") {
    ProcessingErrorView(
        error: .noSubjectFound,
        retryAction: {},
        cancelAction: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
}
