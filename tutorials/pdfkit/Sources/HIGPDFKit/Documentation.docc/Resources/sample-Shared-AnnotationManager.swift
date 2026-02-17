// AnnotationManager.swift
// PDFReader - HIG Lab 샘플 프로젝트
//
// PDF 주석 관리: 하이라이트, 메모, 도형 등

import Foundation
import PDFKit
import SwiftUI

// MARK: - 주석 타입
/// 지원하는 주석 종류
enum AnnotationType: String, CaseIterable, Identifiable {
    case highlight = "Highlight"    // 텍스트 강조
    case underline = "Underline"    // 밑줄
    case strikeOut = "StrikeOut"    // 취소선
    case note = "Text"              // 메모/노트
    case freeText = "FreeText"      // 자유 텍스트
    case ink = "Ink"                // 손글씨
    case circle = "Circle"          // 원
    case square = "Square"          // 사각형
    
    var id: String { rawValue }
    
    /// 표시 이름 (한국어)
    var displayName: String {
        switch self {
        case .highlight: return "형광펜"
        case .underline: return "밑줄"
        case .strikeOut: return "취소선"
        case .note: return "메모"
        case .freeText: return "텍스트"
        case .ink: return "펜"
        case .circle: return "원"
        case .square: return "사각형"
        }
    }
    
    /// SF Symbol 아이콘
    var iconName: String {
        switch self {
        case .highlight: return "highlighter"
        case .underline: return "underline"
        case .strikeOut: return "strikethrough"
        case .note: return "note.text"
        case .freeText: return "textformat"
        case .ink: return "pencil.tip"
        case .circle: return "circle"
        case .square: return "square"
        }
    }
}

// MARK: - 주석 색상
/// 주석 색상 프리셋
enum AnnotationColor: String, CaseIterable, Identifiable {
    case yellow = "yellow"
    case red = "red"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case orange = "orange"
    
    var id: String { rawValue }
    
    /// 표시 이름 (한국어)
    var displayName: String {
        switch self {
        case .yellow: return "노랑"
        case .red: return "빨강"
        case .green: return "초록"
        case .blue: return "파랑"
        case .purple: return "보라"
        case .orange: return "주황"
        }
    }
    
    /// 플랫폼별 색상 반환
    #if os(iOS)
    var uiColor: UIColor {
        switch self {
        case .yellow: return UIColor.systemYellow.withAlphaComponent(0.4)
        case .red: return UIColor.systemRed.withAlphaComponent(0.4)
        case .green: return UIColor.systemGreen.withAlphaComponent(0.4)
        case .blue: return UIColor.systemBlue.withAlphaComponent(0.4)
        case .purple: return UIColor.systemPurple.withAlphaComponent(0.4)
        case .orange: return UIColor.systemOrange.withAlphaComponent(0.4)
        }
    }
    #elseif os(macOS)
    var nsColor: NSColor {
        switch self {
        case .yellow: return NSColor.systemYellow.withAlphaComponent(0.4)
        case .red: return NSColor.systemRed.withAlphaComponent(0.4)
        case .green: return NSColor.systemGreen.withAlphaComponent(0.4)
        case .blue: return NSColor.systemBlue.withAlphaComponent(0.4)
        case .purple: return NSColor.systemPurple.withAlphaComponent(0.4)
        case .orange: return NSColor.systemOrange.withAlphaComponent(0.4)
        }
    }
    #endif
    
    /// SwiftUI 색상
    var color: Color {
        switch self {
        case .yellow: return .yellow
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .orange: return .orange
        }
    }
}

// MARK: - 주석 관리자
/// PDF 주석 생성, 수정, 삭제 관리
@MainActor
class AnnotationManager: ObservableObject {
    
    // MARK: - 속성
    
    /// 현재 PDF 문서
    @Published var pdfDocument: PDFDocument?
    
    /// 현재 선택된 주석 타입
    @Published var selectedType: AnnotationType = .highlight
    
    /// 현재 선택된 색상
    @Published var selectedColor: AnnotationColor = .yellow
    
    /// 주석 모드 활성화 여부
    @Published var isAnnotationModeEnabled: Bool = false
    
    /// 최근 추가된 주석 (실행 취소용)
    private var recentAnnotations: [(annotation: PDFAnnotation, page: PDFPage)] = []
    
    /// 실행 취소 스택 최대 크기
    private let maxUndoStack = 20
    
    // MARK: - 초기화
    
    init(pdfDocument: PDFDocument? = nil) {
        self.pdfDocument = pdfDocument
    }
    
    // MARK: - 주석 생성
    
    /// 선택 영역에 하이라이트 추가
    /// - Parameters:
    ///   - selection: PDF 선택 영역
    ///   - color: 하이라이트 색상
    func addHighlight(to selection: PDFSelection, color: AnnotationColor? = nil) {
        let annotationColor = color ?? selectedColor
        
        // 선택 영역의 각 페이지별로 처리
        for page in selection.pages {
            guard let bounds = selection.bounds(for: page) else { continue }
            
            let annotation = PDFAnnotation(bounds: bounds, forType: .highlight, withProperties: nil)
            
            #if os(iOS)
            annotation.color = annotationColor.uiColor
            #elseif os(macOS)
            annotation.color = annotationColor.nsColor
            #endif
            
            page.addAnnotation(annotation)
            addToUndoStack(annotation: annotation, page: page)
        }
    }
    
    /// 선택 영역에 밑줄 추가
    /// - Parameters:
    ///   - selection: PDF 선택 영역
    ///   - color: 밑줄 색상
    func addUnderline(to selection: PDFSelection, color: AnnotationColor? = nil) {
        let annotationColor = color ?? selectedColor
        
        for page in selection.pages {
            guard let bounds = selection.bounds(for: page) else { continue }
            
            let annotation = PDFAnnotation(bounds: bounds, forType: .underline, withProperties: nil)
            
            #if os(iOS)
            annotation.color = annotationColor.uiColor
            #elseif os(macOS)
            annotation.color = annotationColor.nsColor
            #endif
            
            page.addAnnotation(annotation)
            addToUndoStack(annotation: annotation, page: page)
        }
    }
    
    /// 선택 영역에 취소선 추가
    /// - Parameters:
    ///   - selection: PDF 선택 영역
    ///   - color: 취소선 색상
    func addStrikeOut(to selection: PDFSelection, color: AnnotationColor? = nil) {
        let annotationColor = color ?? selectedColor
        
        for page in selection.pages {
            guard let bounds = selection.bounds(for: page) else { continue }
            
            let annotation = PDFAnnotation(bounds: bounds, forType: .strikeOut, withProperties: nil)
            
            #if os(iOS)
            annotation.color = annotationColor.uiColor
            #elseif os(macOS)
            annotation.color = annotationColor.nsColor
            #endif
            
            page.addAnnotation(annotation)
            addToUndoStack(annotation: annotation, page: page)
        }
    }
    
    /// 특정 위치에 메모 추가
    /// - Parameters:
    ///   - page: 대상 페이지
    ///   - point: 메모 위치
    ///   - text: 메모 내용
    ///   - color: 메모 색상
    func addNote(
        to page: PDFPage,
        at point: CGPoint,
        text: String,
        color: AnnotationColor? = nil
    ) {
        let annotationColor = color ?? selectedColor
        
        // 메모 아이콘 크기
        let noteSize = CGSize(width: 24, height: 24)
        let bounds = CGRect(
            x: point.x - noteSize.width / 2,
            y: point.y - noteSize.height / 2,
            width: noteSize.width,
            height: noteSize.height
        )
        
        let annotation = PDFAnnotation(bounds: bounds, forType: .text, withProperties: nil)
        annotation.contents = text
        
        #if os(iOS)
        annotation.color = annotationColor.uiColor
        #elseif os(macOS)
        annotation.color = annotationColor.nsColor
        #endif
        
        page.addAnnotation(annotation)
        addToUndoStack(annotation: annotation, page: page)
    }
    
    /// 자유 텍스트 주석 추가
    /// - Parameters:
    ///   - page: 대상 페이지
    ///   - bounds: 텍스트 영역
    ///   - text: 텍스트 내용
    ///   - fontSize: 폰트 크기
    func addFreeText(
        to page: PDFPage,
        bounds: CGRect,
        text: String,
        fontSize: CGFloat = 14
    ) {
        let annotation = PDFAnnotation(bounds: bounds, forType: .freeText, withProperties: nil)
        annotation.contents = text
        annotation.font = .systemFont(ofSize: fontSize)
        
        #if os(iOS)
        annotation.fontColor = .black
        annotation.color = .clear
        #elseif os(macOS)
        annotation.fontColor = .black
        annotation.color = .clear
        #endif
        
        page.addAnnotation(annotation)
        addToUndoStack(annotation: annotation, page: page)
    }
    
    /// 도형 주석 추가 (원 또는 사각형)
    /// - Parameters:
    ///   - page: 대상 페이지
    ///   - bounds: 도형 영역
    ///   - type: 도형 타입 (.circle 또는 .square)
    ///   - color: 도형 색상
    func addShape(
        to page: PDFPage,
        bounds: CGRect,
        type: AnnotationType,
        color: AnnotationColor? = nil
    ) {
        guard type == .circle || type == .square else { return }
        
        let annotationColor = color ?? selectedColor
        let annotationType: PDFAnnotationSubtype = type == .circle ? .circle : .square
        
        let annotation = PDFAnnotation(bounds: bounds, forType: annotationType, withProperties: nil)
        
        #if os(iOS)
        annotation.color = annotationColor.uiColor
        #elseif os(macOS)
        annotation.color = annotationColor.nsColor
        #endif
        
        // 테두리 설정
        let border = PDFBorder()
        border.lineWidth = 2.0
        annotation.border = border
        
        page.addAnnotation(annotation)
        addToUndoStack(annotation: annotation, page: page)
    }
    
    // MARK: - 주석 삭제
    
    /// 특정 주석 삭제
    /// - Parameter annotation: 삭제할 주석
    func removeAnnotation(_ annotation: PDFAnnotation) {
        guard let page = annotation.page else { return }
        page.removeAnnotation(annotation)
    }
    
    /// 페이지의 모든 주석 삭제
    /// - Parameter page: 대상 페이지
    func removeAllAnnotations(from page: PDFPage) {
        for annotation in page.annotations {
            page.removeAnnotation(annotation)
        }
    }
    
    /// 문서의 모든 주석 삭제
    func removeAllAnnotations() {
        guard let document = pdfDocument else { return }
        
        for pageIndex in 0..<document.pageCount {
            if let page = document.page(at: pageIndex) {
                removeAllAnnotations(from: page)
            }
        }
    }
    
    // MARK: - 실행 취소
    
    /// 실행 취소 스택에 추가
    private func addToUndoStack(annotation: PDFAnnotation, page: PDFPage) {
        recentAnnotations.append((annotation, page))
        
        // 스택 크기 제한
        if recentAnnotations.count > maxUndoStack {
            recentAnnotations.removeFirst()
        }
    }
    
    /// 마지막 주석 실행 취소
    /// - Returns: 취소된 주석 (없으면 nil)
    @discardableResult
    func undo() -> PDFAnnotation? {
        guard let last = recentAnnotations.popLast() else { return nil }
        last.page.removeAnnotation(last.annotation)
        return last.annotation
    }
    
    /// 실행 취소 가능 여부
    var canUndo: Bool {
        !recentAnnotations.isEmpty
    }
    
    // MARK: - 주석 쿼리
    
    /// 특정 페이지의 주석 목록
    /// - Parameter page: 대상 페이지
    /// - Returns: 주석 배열
    func annotations(on page: PDFPage) -> [PDFAnnotation] {
        page.annotations
    }
    
    /// 특정 타입의 주석만 반환
    /// - Parameters:
    ///   - type: 주석 타입
    ///   - page: 대상 페이지 (nil이면 전체 문서)
    /// - Returns: 필터링된 주석 배열
    func annotations(ofType type: AnnotationType, on page: PDFPage? = nil) -> [PDFAnnotation] {
        if let page = page {
            return page.annotations.filter { $0.type == type.rawValue }
        }
        
        guard let document = pdfDocument else { return [] }
        return document.annotations(ofType: type.rawValue)
    }
    
    /// 특정 위치의 주석 찾기
    /// - Parameters:
    ///   - point: 검색 위치
    ///   - page: 대상 페이지
    /// - Returns: 해당 위치의 주석 (없으면 nil)
    func annotation(at point: CGPoint, on page: PDFPage) -> PDFAnnotation? {
        page.annotation(at: point)
    }
    
    // MARK: - 문서 저장
    
    /// 주석이 포함된 PDF 저장
    /// - Parameter url: 저장 경로
    /// - Returns: 저장 성공 여부
    @discardableResult
    func saveDocument(to url: URL) -> Bool {
        guard let document = pdfDocument else { return false }
        return document.write(to: url)
    }
}

// MARK: - 현재 선택에 따른 주석 적용
extension AnnotationManager {
    
    /// 현재 설정으로 선택 영역에 주석 적용
    /// - Parameter selection: PDF 선택 영역
    func applyAnnotation(to selection: PDFSelection) {
        switch selectedType {
        case .highlight:
            addHighlight(to: selection)
        case .underline:
            addUnderline(to: selection)
        case .strikeOut:
            addStrikeOut(to: selection)
        default:
            // 텍스트 선택 기반이 아닌 주석은 별도 처리
            break
        }
    }
}
