import SwiftUI
import ShazamKit

// MARK: - ContentView
/// 메인 화면: 탭 기반 네비게이션
/// 인식, 기록, 라이브러리, 설정 탭 제공

struct ContentView: View {
    // MARK: - 환경
    @Environment(ShazamEngine.self) private var engine
    @Environment(AppSettings.self) private var settings
    
    // MARK: - 상태
    @State private var selectedTab: AppTab = .recognize
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - 인식 탭
            Tab(value: .recognize) {
                NavigationStack {
                    ShazamView()
                        .navigationTitle("SoundMatch")
                }
            } label: {
                Label("인식", systemImage: "shazam.logo.fill")
            }
            
            // MARK: - 기록 탭
            Tab(value: .history) {
                NavigationStack {
                    HistoryView()
                        .navigationTitle("인식 기록")
                }
            } label: {
                Label("기록", systemImage: "clock.fill")
            }
            
            // MARK: - 라이브러리 탭
            Tab(value: .library) {
                NavigationStack {
                    LibraryView()
                        .navigationTitle("라이브러리")
                }
            } label: {
                Label("라이브러리", systemImage: "music.note.list")
            }
            
            // MARK: - 설정 탭
            Tab(value: .settings) {
                NavigationStack {
                    SettingsView()
                        .navigationTitle("설정")
                }
            } label: {
                Label("설정", systemImage: "gearshape.fill")
            }
        }
        .preferredColorScheme(for: settings.appearance)
    }
}

// MARK: - AppTab
/// 앱 탭 열거형

enum AppTab: Hashable {
    case recognize   // 인식
    case history     // 기록
    case library     // 라이브러리
    case settings    // 설정
}

// MARK: - ShazamView
/// Shazam 인식 화면

struct ShazamView: View {
    @Environment(ShazamEngine.self) private var engine
    @Environment(HistoryStore.self) private var historyStore
    @Environment(AppSettings.self) private var settings
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // MARK: - 상태별 뷰
            Group {
                switch engine.state {
                case .idle:
                    IdleStateView()
                    
                case .preparingAudio:
                    PreparingView()
                    
                case .listening:
                    ListeningView()
                    
                case .processingSignature, .matching:
                    ProcessingView()
                    
                case .matched:
                    if let result = engine.lastMatchResult {
                        MatchResultView(result: result)
                    }
                    
                case .noMatch:
                    NoMatchView()
                    
                case .error(let error):
                    ErrorStateView(error: error)
                }
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
            .ignoresSafeArea()
        )
    }
}

// MARK: - IdleStateView
/// 대기 상태 뷰

struct IdleStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse)
            
            Text("버튼을 눌러 음악을 인식하세요")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("주변에서 재생 중인 음악을 찾아드립니다")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - PreparingView
/// 오디오 준비 중 뷰

struct PreparingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("오디오 준비 중...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - ProcessingView
/// 처리 중 뷰

struct ProcessingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("음악 분석 중...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - NoMatchView
/// 매칭 실패 뷰

struct NoMatchView: View {
    @Environment(ShazamEngine.self) private var engine
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text("곡을 찾을 수 없습니다")
                .font(.headline)
            
            Text("더 가까이에서 다시 시도해 보세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                engine.reset()
            } label: {
                Text("다시 시도")
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - ErrorStateView
/// 오류 상태 뷰

struct ErrorStateView: View {
    let error: ShazamEngineError
    @Environment(ShazamEngine.self) private var engine
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            
            Text("오류가 발생했습니다")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 권한 오류인 경우 설정 열기 버튼
            if case .microphoneAccessDenied = error {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("설정 열기", systemImage: "gear")
                        .font(.subheadline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
            
            Button {
                engine.reset()
            } label: {
                Text("다시 시도")
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.gray.opacity(0.2))
                    .foregroundStyle(.primary)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - ShazamButton
/// 인식 시작/중지 버튼

struct ShazamButton: View {
    @Environment(ShazamEngine.self) private var engine
    @Environment(AppSettings.self) private var settings
    
    private var isActive: Bool {
        engine.state.isActive
    }
    
    var body: some View {
        Button {
            Task {
                if isActive {
                    engine.stopListening()
                } else {
                    engine.reset()
                    engine.autoStopOnMatch = settings.autoStopOnMatch
                    try? await engine.startListening()
                }
            }
        } label: {
            ZStack {
                // 외부 링
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundStyle(isActive ? .red.opacity(0.5) : .blue.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isActive ? 1.1 : 1)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isActive)
                
                // 배경 원
                Circle()
                    .fill(isActive ? .red : .blue)
                    .frame(width: 100, height: 100)
                    .shadow(color: isActive ? .red.opacity(0.4) : .blue.opacity(0.4), radius: 10)
                
                // 아이콘
                Image(systemName: isActive ? "stop.fill" : "shazam.logo.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact, trigger: isActive)
        .disabled(engine.state == .preparingAudio)
    }
}

// MARK: - LibraryView
/// 라이브러리 뷰 (Shazam Library & Custom Catalogs)

struct LibraryView: View {
    @Environment(ShazamLibraryService.self) private var libraryService
    @Environment(CustomCatalogManager.self) private var catalogManager
    
    @State private var selectedSection: LibrarySection = .shazamLibrary
    @State private var isLoading = false
    @State private var showingCatalogSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 섹션 선택기
            Picker("섹션", selection: $selectedSection) {
                ForEach(LibrarySection.allCases) { section in
                    Text(section.title).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // 선택된 섹션 뷰
            switch selectedSection {
            case .shazamLibrary:
                ShazamLibrarySection()
                
            case .customCatalogs:
                CustomCatalogSection()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if selectedSection == .shazamLibrary {
                    Button {
                        Task {
                            isLoading = true
                            await libraryService.sync()
                            isLoading = false
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                } else {
                    Button {
                        showingCatalogSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCatalogSheet) {
            NewCatalogSheet()
        }
    }
}

enum LibrarySection: String, CaseIterable, Identifiable {
    case shazamLibrary = "shazam"
    case customCatalogs = "custom"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .shazamLibrary: return "Shazam 라이브러리"
        case .customCatalogs: return "커스텀 카탈로그"
        }
    }
}

// MARK: - ShazamLibrarySection

struct ShazamLibrarySection: View {
    @Environment(ShazamLibraryService.self) private var service
    
    var body: some View {
        Group {
            if service.items.isEmpty {
                ContentUnavailableView(
                    "라이브러리가 비어 있습니다",
                    systemImage: "music.note.list",
                    description: Text("Shazam한 곡들이 여기에 표시됩니다")
                )
            } else {
                List(service.items) { item in
                    LibraryItemRow(item: item)
                }
                .listStyle(.plain)
            }
        }
    }
}

struct LibraryItemRow: View {
    let item: ShazamLibraryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 아트워크
            AsyncImage(url: item.artworkURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Color.gray.opacity(0.2)
                        .overlay {
                            Image(systemName: "music.note")
                                .foregroundStyle(.gray)
                        }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(item.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Apple Music 링크
            if let url = item.appleMusicURL {
                Link(destination: url) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.pink)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - CustomCatalogSection

struct CustomCatalogSection: View {
    @Environment(CustomCatalogManager.self) private var manager
    
    var body: some View {
        Group {
            if manager.catalogs.isEmpty {
                ContentUnavailableView(
                    "커스텀 카탈로그가 없습니다",
                    systemImage: "folder.badge.plus",
                    description: Text("오프라인 인식을 위한 나만의 음악 카탈로그를 만들어보세요")
                )
            } else {
                List(manager.catalogs) { catalog in
                    CatalogRow(catalog: catalog)
                }
                .listStyle(.plain)
            }
        }
    }
}

struct CatalogRow: View {
    let catalog: CatalogMetadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(catalog.name)
                .font(.headline)
            
            HStack {
                Text("\(catalog.itemCount)곡")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .foregroundStyle(.tertiary)
                
                Text(catalog.modifiedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - NewCatalogSheet

struct NewCatalogSheet: View {
    @Environment(CustomCatalogManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    
    @State private var catalogName = ""
    @State private var catalogDescription = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("카탈로그 정보") {
                    TextField("이름", text: $catalogName)
                    TextField("설명 (선택)", text: $catalogDescription)
                }
            }
            .navigationTitle("새 카탈로그")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("생성") {
                        try? manager.createCatalog(
                            name: catalogName,
                            description: catalogDescription
                        )
                        dismiss()
                    }
                    .disabled(catalogName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(ShazamEngine())
        .environment(HistoryStore.shared)
        .environment(MusicKitService.shared)
        .environment(ShazamLibraryService.shared)
        .environment(SignatureManager.shared)
        .environment(CustomCatalogManager.shared)
        .environment(AppSettings.shared)
}
