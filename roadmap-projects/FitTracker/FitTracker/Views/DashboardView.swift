import SwiftUI

struct DashboardView: View {
    @Environment(HealthManager.self) private var healthManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 걸음수 원형 프로그레스
                    stepsCard
                    
                    // 통계 그리드
                    statsGrid
                    
                    // 심박수 카드
                    heartRateCard
                }
                .padding()
            }
            .navigationTitle("오늘")
            .refreshable {
                await healthManager.fetchTodayStats()
            }
        }
    }
    
    // MARK: - Steps Card
    private var stepsCard: some View {
        VStack(spacing: 16) {
            ZStack {
                // 배경 원
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                // 프로그레스 원
                Circle()
                    .trim(from: 0, to: healthManager.stepsProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring, value: healthManager.stepsProgress)
                
                // 중앙 텍스트
                VStack(spacing: 4) {
                    Image(systemName: "figure.walk")
                        .font(.title)
                        .foregroundStyle(.green)
                    
                    Text("\(healthManager.todaySteps)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    
                    Text("/ 10,000 걸음")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 200)
            .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                icon: "flame.fill",
                iconColor: .orange,
                title: "활동 칼로리",
                value: healthManager.formattedCalories
            )
            
            StatCard(
                icon: "figure.walk.motion",
                iconColor: .blue,
                title: "이동 거리",
                value: healthManager.formattedDistance
            )
            
            StatCard(
                icon: "clock.fill",
                iconColor: .green,
                title: "운동 시간",
                value: "\(healthManager.todayActiveMinutes)분"
            )
            
            StatCard(
                icon: "trophy.fill",
                iconColor: .yellow,
                title: "목표 달성",
                value: "\(Int(healthManager.stepsProgress * 100))%"
            )
        }
    }
    
    // MARK: - Heart Rate Card
    private var heartRateCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Label("심박수", systemImage: "heart.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(healthManager.heartRate)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                    
                    Text("BPM")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 심박수 애니메이션
            HeartBeatView()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

// MARK: - Heart Beat Animation
struct HeartBeatView: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 50))
            .foregroundStyle(.red)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.2
                }
            }
    }
}

#Preview {
    DashboardView()
        .environment(HealthManager())
}
