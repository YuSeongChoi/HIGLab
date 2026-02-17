//
//  ContentView.swift
//  DeliveryTracker
//
//  주문 시뮬레이션을 위한 메인 화면
//  Live Activity의 시작, 업데이트, 종료를 테스트할 수 있습니다.
//

import SwiftUI
import ActivityKit

/// 메인 컨텐츠 뷰
/// 배달 주문 시뮬레이션과 Live Activity 제어를 담당합니다.
struct ContentView: View {
    
    // MARK: - State Properties
    
    /// 현재 활성화된 Live Activity
    @State private var currentActivity: Activity<DeliveryAttributes>?
    
    /// 현재 배달 상태
    @State private var currentState: DeliveryState = .previewOrdered
    
    /// 주문 활성화 여부
    @State private var isOrderActive: Bool = false
    
    /// 에러 메시지
    @State private var errorMessage: String?
    
    /// 자동 진행 타이머 활성화 여부
    @State private var isAutoProgressEnabled: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더 섹션
                    headerSection
                    
                    // Live Activity 지원 여부 표시
                    activitySupportBanner
                    
                    // 주문 상태 카드
                    if isOrderActive {
                        OrderStatusView(
                            attributes: .preview,
                            state: currentState
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                    
                    // 제어 버튼 섹션
                    controlSection
                    
                    // 수동 상태 변경 버튼들
                    if isOrderActive && currentState.status != .delivered {
                        manualControlSection
                    }
                    
                    // 에러 메시지
                    if let error = errorMessage {
                        errorBanner(message: error)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("배달 추적")
            .animation(.spring(response: 0.4), value: isOrderActive)
            .animation(.easeInOut, value: currentState.status)
        }
    }
    
    // MARK: - View Components
    
    /// 헤더 섹션 - 앱 설명
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "bicycle")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("ActivityKit 데모")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
    }
    
    /// Live Activity 지원 여부 배너
    private var activitySupportBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: areActivitiesEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(areActivitiesEnabled ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Live Activity")
                    .font(.subheadline.weight(.semibold))
                Text(areActivitiesEnabled ? "사용 가능" : "비활성화됨")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    /// 메인 제어 버튼 섹션
    private var controlSection: some View {
        VStack(spacing: 12) {
            if !isOrderActive {
                // 주문 시작 버튼
                Button {
                    startOrder()
                } label: {
                    Label("주문하기", systemImage: "cart.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!areActivitiesEnabled)
            } else {
                // 자동 진행 토글
                Toggle(isOn: $isAutoProgressEnabled) {
                    Label("자동 진행", systemImage: "timer")
                }
                .toggleStyle(.switch)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .onChange(of: isAutoProgressEnabled) { _, newValue in
                    if newValue {
                        startAutoProgress()
                    }
                }
                
                // 주문 취소 버튼
                Button(role: .destructive) {
                    endOrder()
                } label: {
                    Label("주문 취소", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    /// 수동 상태 변경 버튼 섹션
    private var manualControlSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("상태 변경")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(DeliveryStatus.allCases, id: \.self) { status in
                    Button {
                        updateStatus(to: status)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: status.iconName)
                                .font(.title2)
                            Text(status.rawValue)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(currentState.status == status ? .blue : .gray)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    /// 에러 메시지 배너
    private func errorBanner(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(message)
                .font(.subheadline)
            Spacer()
            Button {
                errorMessage = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Computed Properties
    
    /// Live Activity 활성화 가능 여부
    private var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    // MARK: - Actions
    
    /// 주문 시작 및 Live Activity 생성
    private func startOrder() {
        // 초기 상태 설정
        currentState = DeliveryState(
            status: .ordered,
            remainingMinutes: 30
        )
        
        // Activity 속성 생성
        let attributes = DeliveryAttributes.preview
        
        // Activity 콘텐츠 구성
        let content = ActivityContent(
            state: currentState,
            staleDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        )
        
        do {
            // Live Activity 요청
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil  // 푸시 업데이트를 사용하려면 .token으로 변경
            )
            
            isOrderActive = true
            errorMessage = nil
            
            print("✅ Live Activity 시작: \(currentActivity?.id ?? "unknown")")
            
        } catch {
            errorMessage = "Live Activity 시작 실패: \(error.localizedDescription)"
            print("❌ Live Activity 시작 실패: \(error)")
        }
    }
    
    /// 상태 업데이트
    private func updateStatus(to status: DeliveryStatus) {
        // 남은 시간 계산
        let remainingMinutes: Int
        switch status {
        case .ordered:
            remainingMinutes = 30
        case .preparing:
            remainingMinutes = 25
        case .ready:
            remainingMinutes = 15
        case .pickedUp:
            remainingMinutes = 10
        case .delivered:
            remainingMinutes = 0
        }
        
        // 새 상태 생성
        currentState = DeliveryState(
            status: status,
            remainingMinutes: remainingMinutes,
            driverName: status == .pickedUp || status == .delivered ? "김배달" : nil
        )
        
        // Live Activity 업데이트
        Task {
            let content = ActivityContent(
                state: currentState,
                staleDate: nil
            )
            
            await currentActivity?.update(content)
            
            // 배달 완료 시 Activity 종료
            if status == .delivered {
                try? await Task.sleep(for: .seconds(3))
                await endActivityGracefully()
            }
        }
    }
    
    /// 자동 진행 시작
    private func startAutoProgress() {
        Task {
            while isAutoProgressEnabled && isOrderActive {
                // 5초 대기
                try? await Task.sleep(for: .seconds(5))
                
                guard isAutoProgressEnabled && isOrderActive else { break }
                
                // 다음 상태로 전환
                if let nextStatus = currentState.status.next {
                    await MainActor.run {
                        updateStatus(to: nextStatus)
                    }
                    
                    // 배달 완료되면 자동 진행 종료
                    if nextStatus == .delivered {
                        await MainActor.run {
                            isAutoProgressEnabled = false
                        }
                        break
                    }
                } else {
                    await MainActor.run {
                        isAutoProgressEnabled = false
                    }
                    break
                }
            }
        }
    }
    
    /// 주문 종료
    private func endOrder() {
        isAutoProgressEnabled = false
        
        Task {
            await endActivityGracefully()
            
            await MainActor.run {
                isOrderActive = false
                currentState = .previewOrdered
            }
        }
    }
    
    /// Live Activity 우아하게 종료
    private func endActivityGracefully() async {
        let finalContent = ActivityContent(
            state: DeliveryState(status: .delivered, remainingMinutes: 0),
            staleDate: nil
        )
        
        await currentActivity?.end(
            finalContent,
            dismissalPolicy: .default
        )
        
        await MainActor.run {
            currentActivity = nil
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
