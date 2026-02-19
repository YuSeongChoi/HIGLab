#if canImport(PermissionKit)
import PermissionKit
import CoreMotion
import SwiftUI

// 모션 & 피트니스 권한 관리
@Observable
final class MotionPermissionManager {
    private let motionManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    
    var authorizationStatus: CMAuthorizationStatus = .notDetermined
    
    var isMotionAvailable: Bool {
        CMMotionActivityManager.isActivityAvailable()
    }
    
    var isPedometerAvailable: Bool {
        CMPedometer.isStepCountingAvailable()
    }
    
    init() {
        authorizationStatus = CMMotionActivityManager.authorizationStatus()
    }
    
    /// 모션 데이터 권한 요청 (실제 데이터 요청 시 자동으로 권한 다이얼로그 표시)
    func requestMotionPermission() {
        guard isMotionAvailable else { return }
        
        // 권한 요청은 데이터 접근 시 자동으로 트리거됨
        motionManager.queryActivityStarting(
            from: Date(),
            to: Date(),
            to: .main
        ) { [weak self] _, error in
            if let error = error as? CMError {
                print("모션 권한 에러: \(error)")
            }
            self?.authorizationStatus = CMMotionActivityManager.authorizationStatus()
        }
    }
    
    /// 오늘의 걸음 수 가져오기
    func fetchTodaySteps() async throws -> Int {
        guard isPedometerAvailable else {
            throw MotionError.notAvailable
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        return try await withCheckedThrowingContinuation { continuation in
            pedometer.queryPedometerData(from: startOfDay, to: Date()) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = data?.numberOfSteps.intValue ?? 0
                continuation.resume(returning: steps)
            }
        }
    }
}

enum MotionError: LocalizedError {
    case notAvailable
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "이 기기에서는 모션 데이터를 사용할 수 없습니다."
        }
    }
}

// 모션 권한 뷰
struct MotionPermissionView: View {
    @State private var manager = MotionPermissionManager()
    @State private var todaySteps: Int = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.walk.motion")
                .font(.system(size: 60))
                .foregroundStyle(.orange.gradient)
            
            Text("모션 & 피트니스")
                .font(.title2.bold())
            
            statusView
            
            if manager.authorizationStatus == .authorized {
                stepsView
            } else {
                Button("모션 권한 허용") {
                    manager.requestMotionPermission()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .task {
            if manager.authorizationStatus == .authorized {
                await loadSteps()
            }
        }
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch manager.authorizationStatus {
        case .notDetermined:
            Label("권한 요청 필요", systemImage: "questionmark.circle")
                .foregroundStyle(.secondary)
        case .authorized:
            Label("권한 허용됨", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .denied:
            Label("권한 거부됨 - 설정에서 변경", systemImage: "xmark.circle.fill")
                .foregroundStyle(.red)
        case .restricted:
            Label("사용 제한됨", systemImage: "lock.fill")
                .foregroundStyle(.orange)
        @unknown default:
            EmptyView()
        }
    }
    
    private var stepsView: some View {
        VStack(spacing: 8) {
            Text("오늘의 걸음")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("\(todaySteps)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            
            Text("걸음")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func loadSteps() async {
        do {
            todaySteps = try await manager.fetchTodaySteps()
        } catch {
            print("걸음 수 로드 실패: \(error)")
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
