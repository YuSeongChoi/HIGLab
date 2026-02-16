import PDFKit

// PDFKit 주요 클래스 계층구조
// 
// PDFView
//   └── document: PDFDocument?
//         └── page(at:) → PDFPage
//               └── annotations: [PDFAnnotation]
//
// PDFDocument: PDF 파일의 메모리 표현
// PDFPage: 개별 페이지
// PDFAnnotation: 페이지에 추가된 주석
// PDFSelection: 텍스트 선택 범위
// PDFDestination: 문서 내 특정 위치
// PDFOutline: 목차(북마크) 구조
