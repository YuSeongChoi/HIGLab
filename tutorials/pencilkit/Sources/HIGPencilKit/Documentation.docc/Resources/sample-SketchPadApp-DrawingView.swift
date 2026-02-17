import SwiftUI
import PencilKit

// MARK: - DrawingView
// 캔버스와 도구 툴바를 포함하는 드로잉 편집 뷰

struct DrawingView: View {
    // MARK: - 환경
    
    @Environment(DrawingStore.self) private var store
    @Environment(ToolPalette.self) private var palette
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 바인딩
    
    /// 편집 중인 드로잉
    @Binding var drawing: Drawing
    
    // MARK: - 상태
    
    /// 내부 PKDrawing 상태
    @State private var pkDrawing: PKDrawing = PKDrawing()
    
    /// 도구 선택 시트 표시
    @State private var showingToolPicker = false
    
    /// 내보내기 시트 표시
    @State private var showingExport = false
    
    /// 이름 변경 다이얼로그
    @State private var showingRename = false
    @State private var newName = ""
    
    /// 되돌리기 관리자
    @State private var undoManager: UndoManager?
    
    /// 시스템 도구 픽커 사용 여부
    @State private var useSystemToolPicker = false
    
    // MARK: - 본문
    
    var body: some View {
        VStack(spacing: 0) {
            // 캔버스
            canvas
            
            // 하단 도구 바
            if !useSystemToolPicker {
                bottomToolbar
            }
        }
        .navigationTitle(drawing.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .onAppear {
            // Drawing 모델에서 PKDrawing 로드
            pkDrawing = drawing.pkDrawing
            newName = drawing.name
        }
        .onChange(of: pkDrawing) { _, newDrawing in
            // PKDrawing이 변경되면 Drawing 모델 업데이트
            drawing.pkDrawing = newDrawing
        }
        .sheet(isPresented: $showingToolPicker) {
            ToolPickerView()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingExport) {
            ExportView(drawing: pkDrawing, name: drawing.name)
                .presentationDetents([.medium, .large])
        }
        .alert("이름 변경", isPresented: $showingRename) {
            TextField("이름", text: $newName)
            Button("취소", role: .cancel) { }
            Button("변경") {
                drawing.name = newName
            }
        }
    }
    
    // MARK: - 캔버스
    
    @ViewBuilder
    private var canvas: some View {
        if useSystemToolPicker {
            // 시스템 도구 픽커 사용
            CanvasView.WithToolPicker(
                drawing: $pkDrawing,
                isToolPickerVisible: .constant(true)
            ) { newDrawing in
                drawing.pkDrawing = newDrawing
            }
        } else {
            // 커스텀 도구 팔레트 사용
            CanvasView(
                drawing: $pkDrawing,
                tool: palette.pkTool
            ) { newDrawing in
                drawing.pkDrawing = newDrawing
            }
        }
    }
    
    // MARK: - 하단 도구 바
    
    private var bottomToolbar: some View {
        VStack(spacing: 0) {
            Divider()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // 도구 버튼들
                    ForEach(ToolType.allCases) { tool in
                        toolButton(for: tool)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    // 색상 버튼
                    colorButton
                    
                    // 두께 슬라이더
                    widthSlider
                }
                .padding(.horizontal)
            }
            .frame(height: 60)
            .background(.regularMaterial)
        }
    }
    
    /// 도구 버튼
    private func toolButton(for tool: ToolType) -> some View {
        Button {
            palette.selectTool(tool)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tool.icon)
                    .font(.title2)
                Text(tool.rawValue)
                    .font(.caption2)
            }
            .foregroundStyle(palette.selectedTool == tool ? .blue : .primary)
            .frame(width: 50)
        }
        .buttonStyle(.plain)
    }
    
    /// 색상 버튼
    private var colorButton: some View {
        ColorPicker("", selection: Bindable(palette).selectedColor)
            .labelsHidden()
            .frame(width: 30, height: 30)
    }
    
    /// 두께 슬라이더
    private var widthSlider: some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Slider(
                value: Bindable(palette).lineWidth,
                in: 1...20,
                step: 1
            )
            .frame(width: 80)
            
            Image(systemName: "circle.fill")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 네비게이션 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 되돌리기/다시하기
        ToolbarItemGroup(placement: .secondaryAction) {
            Button {
                undoManager?.undo()
            } label: {
                Label("되돌리기", systemImage: "arrow.uturn.backward")
            }
            .disabled(undoManager?.canUndo != true)
            
            Button {
                undoManager?.redo()
            } label: {
                Label("다시하기", systemImage: "arrow.uturn.forward")
            }
            .disabled(undoManager?.canRedo != true)
        }
        
        // 주요 액션
        ToolbarItemGroup(placement: .primaryAction) {
            // 모두 지우기
            Button {
                pkDrawing = PKDrawing()
            } label: {
                Label("모두 지우기", systemImage: "trash")
            }
            
            // 도구 옵션
            Menu {
                Toggle("시스템 도구 픽커", isOn: $useSystemToolPicker)
                
                Button {
                    showingToolPicker = true
                } label: {
                    Label("도구 설정", systemImage: "paintbrush")
                }
                .disabled(useSystemToolPicker)
                
                Divider()
                
                Button {
                    showingRename = true
                } label: {
                    Label("이름 변경", systemImage: "pencil")
                }
            } label: {
                Label("옵션", systemImage: "ellipsis.circle")
            }
            
            // 내보내기
            Button {
                // 썸네일 생성 후 저장
                var updatedDrawing = drawing
                updatedDrawing.pkDrawing = pkDrawing
                updatedDrawing.generateThumbnail()
                drawing = updatedDrawing
                store.save()
                
                showingExport = true
            } label: {
                Label("내보내기", systemImage: "square.and.arrow.up")
            }
        }
    }
}

// MARK: - 미리보기

#Preview {
    @Previewable @State var drawing = Drawing.sample
    
    NavigationStack {
        DrawingView(drawing: $drawing)
    }
    .environment(DrawingStore.preview)
    .environment(ToolPalette.preview)
}
