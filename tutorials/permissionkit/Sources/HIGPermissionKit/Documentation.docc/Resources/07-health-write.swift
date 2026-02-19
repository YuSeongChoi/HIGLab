#if canImport(PermissionKit)
import PermissionKit
import HealthKit
import SwiftUI

// HealthKit 읽기 + 쓰기 권한 관리
@Observable
final class HealthFullPermissionManager {
    private let healthStore = HKHealthStore()
    
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    /// 읽기와 쓰기 권한 동시 요청
    func requestFullAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw HealthPermissionError.notAvailable
        }
        
        try await healthStore.requestAuthorization(
            toShare: HealthDataTypes.writeTypes,
            read: HealthDataTypes.readTypes
        )
    }
    
    /// 특정 쓰기 권한 확인
    /// 쓰기 권한은 정확하게 확인 가능
    func canWrite(_ type: HKSampleType) -> Bool {
        healthStore.authorizationStatus(for: type) == .sharingAuthorized
    }
    
    var healthStore_: HKHealthStore {
        healthStore
    }
}

// 복합 권한 요청 뷰
struct HealthFullPermissionView: View {
    @State private var manager = HealthFullPermissionManager()
    @State private var isRequesting = false
    @State private var authorizationComplete = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 60))
                .foregroundStyle(.pink.gradient)
            
            Text("건강 데이터 전체 접근")
                .font(.title2.bold())
            
            // 읽기/쓰기 권한 구분 표시
            VStack(spacing: 16) {
                PermissionSection(
                    title: "읽기 권한",
                    icon: "arrow.down.circle.fill",
                    items: ["걸음 수", "심박수", "수면 분석"]
                )
                
                PermissionSection(
                    title: "쓰기 권한",
                    icon: "arrow.up.circle.fill",
                    items: ["운동 기록", "활동 칼로리"]
                )
            }
            
            if authorizationComplete {
                Label("권한 설정 완료", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Button("건강 데이터 권한 설정") {
                    Task {
                        await requestAuthorization()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRequesting || !manager.isHealthDataAvailable)
            }
        }
        .padding()
    }
    
    private func requestAuthorization() async {
        isRequesting = true
        
        do {
            try await manager.requestFullAuthorization()
            authorizationComplete = true
        } catch {
            print("권한 요청 실패: \(error)")
        }
        
        isRequesting = false
    }
}

struct PermissionSection: View {
    let title: String
    let icon: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
            
            ForEach(items, id: \.self) { item in
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(.secondary)
                    Text(item)
                        .font(.subheadline)
                }
                .padding(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
