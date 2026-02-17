import SwiftUI

// MARK: - ContentView
// 메인 화면: 인식 버튼과 기록 탭

struct ContentView: View {
    @Environment(ShazamManager.self) private var manager
    
    var body: some View {
        TabView {
            // MARK: - 인식 탭
            Tab("인식", systemImage: "shazam.logo.fill") {
                NavigationStack {
                    ShazamView()
                        .navigationTitle("SoundMatch")
                }
            }
            
            // MARK: - 기록 탭
            Tab("기록", systemImage: "clock.fill") {
                NavigationStack {
                    HistoryView()
                        .navigationTitle("인식 기록")
                }
            }
        }
    }
}

// MARK: - ShazamView
// Shazam 인식 화면

struct ShazamView: View {
    @Environment(ShazamManager.self) private var manager
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // MARK: - 상태별 뷰
            switch manager.state {
            case .idle:
                IdleView()
                
            case .listening:
                ListeningView()
                
            case .matched:
                if let song = manager.matchedSong {
                    MatchResultView(song: song)
                }
                
            case .noMatch:
                NoMatchView()
                
            case .error(let message):
                ErrorView(message: message)
            }
            
            Spacer()
            
            // MARK: - 인식 버튼
            ShazamButton()
                .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - IdleView
// 대기 상태 뷰

struct IdleView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("버튼을 눌러 음악을 인식하세요")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - NoMatchView
// 매칭 실패 뷰

struct NoMatchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text("곡을 찾을 수 없습니다")
                .font(.headline)
            
            Text("다시 시도해 보세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - ErrorView
// 오류 상태 뷰

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            
            Text("오류가 발생했습니다")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - ShazamButton
// 인식 시작/중지 버튼

struct ShazamButton: View {
    @Environment(ShazamManager.self) private var manager
    
    private var isListening: Bool {
        manager.state == .listening
    }
    
    var body: some View {
        Button {
            Task {
                if isListening {
                    manager.stopListening()
                } else {
                    manager.reset()
                    await manager.startListening()
                }
            }
        } label: {
            ZStack {
                // 배경 원
                Circle()
                    .fill(isListening ? .red : .blue)
                    .frame(width: 100, height: 100)
                    .shadow(color: isListening ? .red.opacity(0.4) : .blue.opacity(0.4), radius: 10)
                
                // 아이콘
                Image(systemName: isListening ? "stop.fill" : "shazam.logo.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact, trigger: isListening)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(ShazamManager())
        .environment(MatchHistory.shared)
}
