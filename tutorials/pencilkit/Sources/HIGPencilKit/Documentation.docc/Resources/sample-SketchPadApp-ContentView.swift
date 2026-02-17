import SwiftUI

// MARK: - ContentView
// 드로잉 목록을 표시하는 메인 뷰

struct ContentView: View {
    // MARK: - 환경
    
    @Environment(DrawingStore.self) private var store
    
    // MARK: - 상태
    
    /// 선택된 드로잉 (네비게이션)
    @State private var selectedDrawing: Drawing?
    
    /// 새 드로잉 이름 입력 다이얼로그
    @State private var showingNewDrawingDialog = false
    @State private var newDrawingName = ""
    
    /// 정렬 옵션
    @State private var sortOption: SortOption = .modifiedDate
    
    // MARK: - 정렬 옵션
    
    enum SortOption: String, CaseIterable {
        case modifiedDate = "수정일"
        case createdDate = "생성일"
        case name = "이름"
    }
    
    // MARK: - 본문
    
    var body: some View {
        NavigationSplitView {
            // 드로잉 목록 (사이드바)
            drawingList
                .navigationTitle("SketchPad")
                .toolbar {
                    toolbarContent
                }
        } detail: {
            // 드로잉 편집 뷰
            if let drawing = selectedDrawing {
                DrawingView(drawing: binding(for: drawing))
            } else {
                emptyState
            }
        }
        .alert("새 드로잉", isPresented: $showingNewDrawingDialog) {
            TextField("드로잉 이름", text: $newDrawingName)
            Button("취소", role: .cancel) {
                newDrawingName = ""
            }
            Button("생성") {
                createNewDrawing()
            }
        } message: {
            Text("새 드로잉의 이름을 입력하세요.")
        }
    }
    
    // MARK: - 드로잉 목록
    
    private var drawingList: some View {
        Group {
            if store.isLoading {
                ProgressView("로딩 중...")
            } else if store.drawings.isEmpty {
                ContentUnavailableView(
                    "드로잉 없음",
                    systemImage: "scribble",
                    description: Text("+ 버튼을 눌러 새 드로잉을 만드세요")
                )
            } else {
                List(selection: $selectedDrawing) {
                    ForEach(store.drawings) { drawing in
                        DrawingRow(drawing: drawing)
                            .tag(drawing)
                    }
                    .onDelete { offsets in
                        store.deleteDrawings(at: offsets)
                    }
                }
            }
        }
    }
    
    // MARK: - 빈 상태
    
    private var emptyState: some View {
        ContentUnavailableView(
            "드로잉 선택",
            systemImage: "hand.draw",
            description: Text("왼쪽 목록에서 드로잉을 선택하거나\n새 드로잉을 만드세요")
        )
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 새 드로잉 버튼
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingNewDrawingDialog = true
            } label: {
                Label("새 드로잉", systemImage: "plus")
            }
        }
        
        // 정렬 메뉴
        ToolbarItem(placement: .secondaryAction) {
            Menu {
                Picker("정렬", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                Label("정렬", systemImage: "arrow.up.arrow.down")
            }
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    /// Drawing에 대한 바인딩 생성
    private func binding(for drawing: Drawing) -> Binding<Drawing> {
        Binding(
            get: {
                store.drawings.first { $0.id == drawing.id } ?? drawing
            },
            set: { newValue in
                store.updateDrawing(newValue)
            }
        )
    }
    
    /// 새 드로잉 생성
    private func createNewDrawing() {
        let name = newDrawingName.isEmpty ? "새 드로잉" : newDrawingName
        let drawing = store.createDrawing(name: name)
        selectedDrawing = drawing
        newDrawingName = ""
    }
}

// MARK: - DrawingRow
// 목록의 각 드로잉 항목

struct DrawingRow: View {
    let drawing: Drawing
    
    /// 날짜 포맷터
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 12) {
            // 썸네일
            thumbnailView
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(drawing.name)
                    .font(.headline)
                
                Text(dateFormatter.string(from: drawing.modifiedAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    /// 썸네일 뷰
    @ViewBuilder
    private var thumbnailView: some View {
        if let data = drawing.thumbnailData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "scribble")
                        .foregroundStyle(.secondary)
                }
        }
    }
}

// MARK: - 미리보기

#Preview {
    ContentView()
        .environment(DrawingStore.preview)
        .environment(ToolPalette.preview)
}
