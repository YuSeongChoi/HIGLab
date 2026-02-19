#if canImport(PermissionKit)
import PermissionKit
import HealthKit
import SwiftUI

// HealthKit 읽기 권한 관리
@Observable
final class HealthReadPermissionManager {
    private let healthStore = HKHealthStore()
    
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    var authorizationRequested = false
    
    /// 읽기 권한 요청
    /// 주의: HealthKit은 거부 상태를 앱에서 확인할 수 없음
    func requestReadAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw HealthPermissionError.notAvailable
        }
        
        try await healthStore.requestAuthorization(
            toShare: [],  // 쓰기 권한 없음
            read: HealthDataTypes.readTypes
        )
        
        await MainActor.run {
            authorizationRequested = true
        }
    }
    
    /// 특정 데이터 유형의 권한 상태 확인
    /// 주의: .sharingDenied는 실제로 거부됨을 의미하지 않을 수 있음
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        healthStore.authorizationStatus(for: type)
    }
}

enum HealthPermissionError: LocalizedError {
    case notAvailable
    case denied
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "이 기기에서는 건강 데이터를 사용할 수 없습니다."
        case .denied:
            return "건강 데이터 접근이 거부되었습니다."
        }
    }
}

// 건강 데이터 읽기 권한 요청 뷰
struct HealthReadPermissionView: View {
    @State private var manager = HealthReadPermissionManager()
    @State private var errorMessage: String?
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundStyle(.pink.gradient)
            
            Text("건강 데이터 접근")
                .font(.title2.bold())
            
            // 접근할 데이터 유형 목록
            VStack(alignment: .leading, spacing: 8) {
                Text("다음 데이터에 접근합니다:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HealthTypeRow(icon: "figure.walk", title: "걸음 수", subtitle: "일일 활동량 분석")
                HealthTypeRow(icon: "heart.fill", title: "심박수", subtitle: "운동 강도 측정")
                HealthTypeRow(icon: "bed.double.fill", title: "수면", subtitle: "수면 패턴 분석")
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if !manager.isHealthDataAvailable {
                Label("이 기기에서는 건강 데이터를 사용할 수 없습니다",
                      systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            } else if manager.authorizationRequested {
                Label("권한 요청 완료", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Button("건강 데이터 접근 허용") {
                    Task {
                        await requestPermission()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRequesting)
            }
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }
    
    private func requestPermission() async {
        isRequesting = true
        errorMessage = nil
        
        do {
            try await manager.requestReadAuthorization()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isRequesting = false
    }
}

struct HealthTypeRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.pink)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
