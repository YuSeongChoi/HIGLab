import SwiftUI

struct HistoryView: View {
    @State private var selectedPeriod: Period = .week
    @State private var workouts: [WorkoutRecord] = WorkoutRecord.samples
    
    enum Period: String, CaseIterable {
        case week = "주"
        case month = "월"
        case year = "년"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 기간 선택
                Picker("기간", selection: $selectedPeriod) {
                    ForEach(Period.allCases, id: \.self) { period in
                        Text(period.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 통계 요약
                summaryCard
                    .padding(.horizontal)
                
                // 운동 기록 목록
                List(workouts) { workout in
                    WorkoutHistoryRow(workout: workout)
                }
                .listStyle(.plain)
            }
            .navigationTitle("기록")
        }
    }
    
    private var summaryCard: some View {
        HStack(spacing: 20) {
            SummaryStatView(
                title: "총 운동",
                value: "\(workouts.count)회",
                icon: "flame.fill",
                color: .orange
            )
            
            SummaryStatView(
                title: "총 거리",
                value: String(format: "%.1f km", totalDistance),
                icon: "figure.run",
                color: .blue
            )
            
            SummaryStatView(
                title: "총 시간",
                value: formattedTotalTime,
                icon: "clock.fill",
                color: .green
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var totalDistance: Double {
        workouts.reduce(0) { $0 + $1.distance } / 1000
    }
    
    private var formattedTotalTime: String {
        let totalMinutes = workouts.reduce(0) { $0 + Int($1.duration / 60) }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)시간 \(minutes)분"
    }
}

// MARK: - Summary Stat View
struct SummaryStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Workout History Row
struct WorkoutHistoryRow: View {
    let workout: WorkoutRecord
    
    var body: some View {
        HStack(spacing: 16) {
            // 아이콘
            Image(systemName: workout.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(workout.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.type)
                    .font(.headline)
                
                Text(workout.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 통계
            VStack(alignment: .trailing, spacing: 4) {
                Text(workout.formattedDistance)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(workout.formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Workout Record Model
struct WorkoutRecord: Identifiable {
    let id = UUID()
    let type: String
    let date: Date
    let duration: TimeInterval
    let distance: Double // meters
    let calories: Double
    
    var icon: String {
        switch type {
        case "달리기": return "figure.run"
        case "걷기": return "figure.walk"
        case "자전거": return "figure.outdoor.cycle"
        default: return "figure.mixed.cardio"
        }
    }
    
    var color: Color {
        switch type {
        case "달리기": return .green
        case "걷기": return .blue
        case "자전거": return .orange
        default: return .purple
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    var formattedDistance: String {
        String(format: "%.2f km", distance / 1000)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration / 60)
        return "\(minutes)분"
    }
}

// MARK: - Sample Data
extension WorkoutRecord {
    static let samples: [WorkoutRecord] = [
        WorkoutRecord(type: "달리기", date: Date(), duration: 1800, distance: 5200, calories: 320),
        WorkoutRecord(type: "걷기", date: Date().addingTimeInterval(-86400), duration: 2400, distance: 3500, calories: 180),
        WorkoutRecord(type: "자전거", date: Date().addingTimeInterval(-172800), duration: 3600, distance: 15000, calories: 450),
        WorkoutRecord(type: "달리기", date: Date().addingTimeInterval(-259200), duration: 2100, distance: 6100, calories: 380),
        WorkoutRecord(type: "걷기", date: Date().addingTimeInterval(-345600), duration: 1800, distance: 2800, calories: 150),
    ]
}

#Preview {
    HistoryView()
}
