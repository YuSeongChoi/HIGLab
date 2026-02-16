import PDFKit
import UIKit

class AnnotationManager {
    
    /// PDFSelection을 하이라이트 주석으로 변환
    func addHighlight(
        for selection: PDFSelection,
        color: UIColor = .yellow
    ) {
        // 줄 단위로 선택 분할
        guard let selections = selection.selectionsByLine() else { return }
        
        for lineSelection in selections {
            guard let page = lineSelection.pages.first else { continue }
            
            // 선택 영역의 bounds 가져오기
            let bounds = lineSelection.bounds(for: page)
            
            // 하이라이트 주석 생성
            let annotation = PDFAnnotation(
                bounds: bounds,
                forType: .highlight,
                withProperties: nil
            )
            
            // 색상 설정 (반투명)
            annotation.color = color.withAlphaComponent(0.5)
            
            // 페이지에 주석 추가
            page.addAnnotation(annotation)
        }
    }
    
    /// 하이라이트 주석 제거
    func removeHighlight(_ annotation: PDFAnnotation) {
        annotation.page?.removeAnnotation(annotation)
    }
}
