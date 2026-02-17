import SwiftUI
import TipKit

/// 이벤트 기반 팁 예제 화면
/// 특정 조건(이벤트)이 충족되어야만 표시되는 팁을 보여줍니다.
struct EventTipView: View {
    // 이벤트 기반 팁 인스턴스
    private let proTip = ProTip()
    
    @State private var eventCount = 0
    @State private var showingTip = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // MARK: - 설명 섹션
                VStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.orange)
                    
                    Text("이벤트 기반 팁")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("특정 조건이 충족되면 팁이 표시됩니다.\n아래 버튼을 3번 이상 누르면 프로 팁이 나타납니다!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // MARK: - 이벤트 카운터
                VStack(spacing: 16) {
                    Text("이벤트 횟수")
                        .font(.headline)
                    
                    // 현재 이벤트 횟수 표시
                    Text("\(eventCount)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                    
                    // 진행 상태 표시
                    ProgressView(value: min(Double(eventCount) / 3.0, 1.0))
                        .tint(eventCount >= 3 ? .green : .blue)
                        .padding(.horizontal, 40)
                    
                    Text(eventCount >= 3 ? "✅ 조건 충족!" : "3회까지 \(3 - eventCount)번 남음")
                        .font(.caption)
                        .foregroundStyle(eventCount >= 3 ? .green : .secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // MARK: - 이벤트 기록 버튼
                Button {
                    // 이벤트 기록
                    Task {
                        // ProTip의 이벤트 donate
                        await ProTip.appOpenedEvent.donate()
                        eventCount += 1
                    }
                } label: {
                    Label("이벤트 기록", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - 프로 팁 표시 영역
                // 이벤트 조건이 충족되면 표시됩니다.
                VStack {
                    TipView(proTip)
                        .tipBackground(.yellow.opacity(0.2))
                }
                .padding()
            }
            .padding()
            .navigationTitle("이벤트 팁")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // 이벤트 리셋 버튼
                    Button {
                        eventCount = 0
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
        }
    }
}

// MARK: - 팁 상태 확인 방법 설명
/*
 TipKit 팁의 상태 확인:
 
 1. tip.status - 팁의 현재 상태 확인
    - .pending: 규칙이 아직 충족되지 않음
    - .available: 표시 가능
    - .invalidated: 이미 표시되었거나 무효화됨
 
 2. tip.shouldDisplay - 팁을 표시해야 하는지 여부
    - true: 표시 조건 충족
    - false: 표시하지 않음
 
 예시:
 if proTip.status == .available {
     // 팁 표시 가능
 }
 */

#Preview {
    EventTipView()
        .task {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}
