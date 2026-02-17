import SwiftUI
import ShazamKit

// MARK: - MatchResultView
/// 인식 결과를 표시하는 뷰
/// ShazamMatchResult의 SHMatchedMediaItem 정보 활용

struct MatchResultView: View {
    // MARK: - 프로퍼티
    let result: ShazamMatchResult
    
    // MARK: - 환경
    @Environment(HistoryStore.self) private var historyStore
    @Environment(ShazamLibraryService.self) private var libraryService
    @Environment(MusicKitService.self) private var musicKitService
    @Environment(AppSettings.self) private var settings
    
    // MARK: - 상태
    @State private var showDetail = false
    @State private var appeared = false
    @State private var isAddingToLibrary = false
    @State private var showingToast = false
    @State private var toastMessage = ""
    
    // MARK: - 계산 프로퍼티
    private var mediaItem: SHMatchedMediaItem {
        result.matchedItem
    }
    
    private var title: String {
        mediaItem.title ?? "알 수 없는 곡"
    }
    
    private var artist: String {
        mediaItem.artist ?? "알 수 없는 아티스트"
    }
    
    private var genres: [String] {
        mediaItem.genres
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - 성공 아이콘
            successIcon
            
            // MARK: - 앨범 아트
            artworkView
            
            // MARK: - 곡 정보
            songInfoView
            
            // MARK: - 매칭 정보
            matchInfoView
            
            // MARK: - 액션 버튼
            actionButtons
        }
        .padding()
        .onAppear {
            withAnimation {
                appeared = true
            }
            
            // 히스토리에 저장
            saveToHistory()
        }
        .sheet(isPresented: $showDetail) {
            SongDetailView(result: result)
        }
        .overlay(alignment: .bottom) {
            if showingToast {
                ToastView(message: toastMessage)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - 성공 아이콘
    private var successIcon: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 50))
            .foregroundStyle(.green)
            .scaleEffect(appeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appeared)
    }
    
    // MARK: - 앨범 아트워크
    private var artworkView: some View {
        AsyncImage(url: mediaItem.artworkURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                artworkPlaceholder
            case .empty:
                artworkPlaceholder
                    .overlay {
                        ProgressView()
                    }
            @unknown default:
                artworkPlaceholder
            }
        }
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 15, y: 10)
        .scaleEffect(appeared ? 1 : 0.5)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
    
    // MARK: - 곡 정보
    private var songInfoView: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(artist)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            // 장르 태그
            if settings.showGenreTags && !genres.isEmpty {
                HStack(spacing: 8) {
                    ForEach(genres.prefix(3), id: \.self) { genre in
                        Text(genre)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }
            }
            
            // 명시적 콘텐츠 표시
            if mediaItem.explicitContent {
                Label("Explicit", systemImage: "e.square.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .offset(y: appeared ? 0 : 20)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
    }
    
    // MARK: - 매칭 정보
    private var matchInfoView: some View {
        VStack(spacing: 4) {
            // 매칭 오프셋 (곡의 어느 부분에서 인식되었는지)
            if result.matchedItem.matchOffset > 0 {
                let offset = result.matchedItem.matchOffset
                let minutes = Int(offset) / 60
                let seconds = Int(offset) % 60
                
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.caption)
                    Text("곡 \(minutes):\(String(format: "%02d", seconds))에서 인식됨")
                        .font(.caption)
                }
                .foregroundStyle(.tertiary)
            }
            
            // 인식 시간
            Text(result.matchedAt, style: .time)
                .font(.caption2)
                .foregroundStyle(.quaternary)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.25), value: appeared)
    }
    
    // MARK: - 액션 버튼
    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Apple Music 열기
                if let url = mediaItem.appleMusicURL {
                    Link(destination: url) {
                        Label("Apple Music", systemImage: "play.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.pink)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // 상세 보기
                Button {
                    showDetail = true
                } label: {
                    Label("상세", systemImage: "info.circle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.gray.opacity(0.2))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            // Shazam 라이브러리에 추가
            Button {
                Task {
                    await addToShazamLibrary()
                }
            } label: {
                HStack {
                    if isAddingToLibrary {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "plus.circle")
                    }
                    Text("Shazam 라이브러리에 추가")
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.blue.opacity(0.1))
                .foregroundStyle(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isAddingToLibrary)
        }
        .offset(y: appeared ? 0 : 30)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
    }
    
    // MARK: - 앨범 아트 플레이스홀더
    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.gray.opacity(0.2))
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
            }
    }
    
    // MARK: - 히스토리 저장
    private func saveToHistory() {
        historyStore.add(from: result.matchedItem)
    }
    
    // MARK: - Shazam 라이브러리에 추가
    private func addToShazamLibrary() async {
        isAddingToLibrary = true
        
        do {
            try await libraryService.addToLibrary(result.matchedItem)
            showToast("라이브러리에 추가되었습니다")
        } catch {
            showToast("추가 실패: \(error.localizedDescription)")
        }
        
        isAddingToLibrary = false
    }
    
    // MARK: - 토스트 표시
    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation {
            showingToast = true
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation {
                showingToast = false
            }
        }
    }
}

// MARK: - ToastView
/// 토스트 알림 뷰

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 5)
            .padding(.bottom, 30)
    }
}

// MARK: - MatchedItemInfo
/// 매칭된 아이템의 상세 정보 뷰

struct MatchedItemInfo: View {
    let item: SHMatchedMediaItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 제목
            if let title = item.title {
                InfoRow(label: "제목", value: title)
            }
            
            // 아티스트
            if let artist = item.artist {
                InfoRow(label: "아티스트", value: artist)
            }
            
            // 부제목
            if let subtitle = item.subtitle {
                InfoRow(label: "부제목", value: subtitle)
            }
            
            // ISRC
            if let isrc = item.isrc {
                InfoRow(label: "ISRC", value: isrc)
            }
            
            // Shazam ID
            if let shazamID = item.shazamID {
                InfoRow(label: "Shazam ID", value: shazamID)
            }
            
            // 매칭 오프셋
            let offset = item.matchOffset
            if offset > 0 {
                let formatted = String(format: "%.1f초", offset)
                InfoRow(label: "매칭 위치", value: formatted)
            }
            
            // 주파수 스큐 범위 (SHRange)
            if let range = item.frequencySkewRanges.first {
                let rangeStr = String(format: "%.2f - %.2f", range.lowerBound, range.upperBound)
                InfoRow(label: "주파수 범위", value: rangeStr)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    // 미리보기용 목업 결과
    let mediaItem = SHMediaItem(properties: [
        .title: "Blinding Lights",
        .artist: "The Weeknd",
        .genres: ["Pop", "Synth-pop"]
    ])
    
    // SHMatch와 SHMatchedMediaItem은 직접 생성 불가하므로 
    // 미리보기에서는 간단한 뷰만 표시
    VStack {
        Text("MatchResultView Preview")
            .font(.headline)
        Text("실제 매칭 결과로만 표시됩니다")
            .foregroundStyle(.secondary)
    }
    .environment(HistoryStore.shared)
    .environment(ShazamLibraryService.shared)
    .environment(MusicKitService.shared)
    .environment(AppSettings.shared)
}
