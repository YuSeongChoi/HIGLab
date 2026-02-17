// AnnotationView.swift
// PDFReader - HIG Lab 샘플 프로젝트
//
// 주석 도구 뷰: 하이라이트, 메모, 도형 등

import SwiftUI
import PDFKit

// MARK: - 주석 도구 뷰
struct AnnotationView: View {
    
    // MARK: - 속성
    
    /// 주석 관리자
    @ObservedObject var annotationManager: AnnotationManager
    
    // MARK: - 상태
    
    /// 색상 선택기 표시 여부
    @State private var showColorPicker = false
    
    /// 메모 입력 시트 표시 여부
    @State private var showNoteInput = false
    
    /// 메모 텍스트
    @State private var noteText = ""
    
    // MARK: - 뷰 본문
    
    var body: some View {
        VStack(spacing: 12) {
            // 주석 도구 버튼들
            HStack(spacing: 16) {
                ForEach(AnnotationType.allCases) { type in
                    annotationToolButton(for: type)
                }
                
                Spacer()
                
                // 실행 취소
                Button {
                    annotationManager.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title3)
                }
                .disabled(!annotationManager.canUndo)
                
                // 색상 선택
                colorButton
            }
            
            // 주석 모드 토글
            Toggle("주석 모드", isOn: $annotationManager.isAnnotationModeEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .frame(height: 0)
                .opacity(0)
        }
        .sheet(isPresented: $showNoteInput) {
            noteInputSheet
        }
    }
    
    // MARK: - 주석 도구 버튼
    
    /// 개별 주석 도구 버튼
    private func annotationToolButton(for type: AnnotationType) -> some View {
        Button {
            selectTool(type)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: type.iconName)
                    .font(.title3)
                    .frame(width: 32, height: 32)
                
                Text(type.displayName)
                    .font(.caption2)
            }
            .foregroundStyle(
                annotationManager.selectedType == type
                    ? .white
                    : .primary
            )
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        annotationManager.selectedType == type
                            ? Color.accentColor
                            : Color.clear
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 색상 버튼
    
    /// 색상 선택 버튼
    private var colorButton: some View {
        Menu {
            ForEach(AnnotationColor.allCases) { color in
                Button {
                    annotationManager.selectedColor = color
                } label: {
                    Label(color.displayName, systemImage: "circle.fill")
                        .foregroundStyle(color.color)
                }
            }
        } label: {
            Circle()
                .fill(annotationManager.selectedColor.color)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    // MARK: - 메모 입력 시트
    
    /// 메모 입력 시트
    private var noteInputSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $noteText)
                        .frame(minHeight: 100)
                } header: {
                    Text("메모 내용")
                }
            }
            .navigationTitle("메모 추가")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        noteText = ""
                        showNoteInput = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        // 메모 추가 로직은 선택 위치가 필요하므로 
                        // 실제 구현에서는 PDFView와 연동 필요
                        showNoteInput = false
                        noteText = ""
                    }
                    .disabled(noteText.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - 도구 선택
    
    /// 도구 선택 처리
    private func selectTool(_ type: AnnotationType) {
        annotationManager.selectedType = type
        annotationManager.isAnnotationModeEnabled = true
        
        // 메모 타입인 경우 입력 시트 표시
        if type == .note || type == .freeText {
            showNoteInput = true
        }
    }
}

// MARK: - 주석 목록 뷰
/// 문서의 모든 주석을 목록으로 표시
struct AnnotationListView: View {
    
    /// PDF 문서
    let pdfDocument: PDFDocument
    
    /// 주석 선택 콜백
    let onSelect: (PDFAnnotation, PDFPage) -> Void
    
    /// 주석 삭제 콜백
    let onDelete: (PDFAnnotation) -> Void
    
    /// 모든 주석 (페이지별 그룹화)
    private var annotationsByPage: [(pageIndex: Int, annotations: [PDFAnnotation])] {
        var result: [(Int, [PDFAnnotation])] = []
        
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            let annotations = page.annotations.filter { !isSystemAnnotation($0) }
            
            if !annotations.isEmpty {
                result.append((pageIndex, annotations))
            }
        }
        
        return result
    }
    
    var body: some View {
        Group {
            if annotationsByPage.isEmpty {
                ContentUnavailableView(
                    "주석 없음",
                    systemImage: "pencil.tip.crop.circle",
                    description: Text("텍스트를 선택하여 주석을 추가하세요")
                )
            } else {
                List {
                    ForEach(annotationsByPage, id: \.pageIndex) { pageData in
                        Section("페이지 \(pageData.pageIndex + 1)") {
                            ForEach(pageData.annotations, id: \.self) { annotation in
                                annotationRow(annotation, pageIndex: pageData.pageIndex)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 주석 행
    private func annotationRow(_ annotation: PDFAnnotation, pageIndex: Int) -> some View {
        Button {
            if let page = pdfDocument.page(at: pageIndex) {
                onSelect(annotation, page)
            }
        } label: {
            HStack {
                // 주석 타입 아이콘
                annotationIcon(for: annotation)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    // 주석 타입
                    Text(annotationTypeName(annotation))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // 주석 내용 (있는 경우)
                    if let contents = annotation.contents, !contents.isEmpty {
                        Text(contents)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // 색상 표시
                if let color = annotation.color {
                    Circle()
                        .fill(Color(color))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete(annotation)
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }
    
    /// 주석 타입 아이콘
    private func annotationIcon(for annotation: PDFAnnotation) -> Image {
        let iconName: String
        
        switch annotation.type {
        case "Highlight":
            iconName = "highlighter"
        case "Underline":
            iconName = "underline"
        case "StrikeOut":
            iconName = "strikethrough"
        case "Text":
            iconName = "note.text"
        case "FreeText":
            iconName = "textformat"
        case "Ink":
            iconName = "pencil.tip"
        case "Circle":
            iconName = "circle"
        case "Square":
            iconName = "square"
        default:
            iconName = "pencil.tip.crop.circle"
        }
        
        return Image(systemName: iconName)
    }
    
    /// 주석 타입 이름
    private func annotationTypeName(_ annotation: PDFAnnotation) -> String {
        switch annotation.type {
        case "Highlight": return "형광펜"
        case "Underline": return "밑줄"
        case "StrikeOut": return "취소선"
        case "Text": return "메모"
        case "FreeText": return "텍스트"
        case "Ink": return "펜"
        case "Circle": return "원"
        case "Square": return "사각형"
        default: return annotation.type ?? "주석"
        }
    }
    
    /// 시스템 주석인지 확인 (링크 등)
    private func isSystemAnnotation(_ annotation: PDFAnnotation) -> Bool {
        annotation.type == "Link" || annotation.type == "Widget"
    }
}

// MARK: - 컴팩트 주석 도구 바
/// 간소화된 주석 도구 바 (빠른 접근용)
struct CompactAnnotationToolbar: View {
    
    @ObservedObject var annotationManager: AnnotationManager
    
    var body: some View {
        HStack(spacing: 12) {
            // 주요 도구만 표시
            ForEach([AnnotationType.highlight, .underline, .note], id: \.self) { type in
                Button {
                    annotationManager.selectedType = type
                    annotationManager.isAnnotationModeEnabled = true
                } label: {
                    Image(systemName: type.iconName)
                        .font(.title3)
                        .foregroundStyle(
                            annotationManager.selectedType == type
                                ? annotationManager.selectedColor.color
                                : .primary
                        )
                }
            }
            
            Divider()
                .frame(height: 24)
            
            // 색상 퀵 선택
            ForEach([AnnotationColor.yellow, .red, .blue], id: \.self) { color in
                Button {
                    annotationManager.selectedColor = color
                } label: {
                    Circle()
                        .fill(color.color)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(
                                    annotationManager.selectedColor == color
                                        ? Color.primary
                                        : Color.clear,
                                    lineWidth: 2
                                )
                        )
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

// MARK: - 프리뷰
#Preview("주석 도구") {
    AnnotationView(annotationManager: AnnotationManager())
        .padding()
}

#Preview("컴팩트 도구 바") {
    CompactAnnotationToolbar(annotationManager: AnnotationManager())
        .padding()
}
