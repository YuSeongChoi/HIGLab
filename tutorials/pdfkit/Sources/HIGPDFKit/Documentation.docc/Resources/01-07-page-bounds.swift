import PDFKit

func inspectPageBounds(_ page: PDFPage) {
    // 다양한 박스 타입의 bounds
    // mediaBox: 물리적 페이지 크기
    let mediaBox = page.bounds(for: .mediaBox)
    print("Media Box: \(mediaBox)")
    
    // cropBox: 표시/인쇄 영역 (가장 많이 사용)
    let cropBox = page.bounds(for: .cropBox)
    print("Crop Box: \(cropBox)")
    
    // artBox: 의미 있는 콘텐츠 영역
    let artBox = page.bounds(for: .artBox)
    print("Art Box: \(artBox)")
    
    // 페이지 회전 (0, 90, 180, 270)
    let rotation = page.rotation
    print("회전: \(rotation)도")
    
    // 일반적으로 cropBox를 기준으로 작업
    let pageWidth = cropBox.width
    let pageHeight = cropBox.height
    print("페이지 크기: \(pageWidth) x \(pageHeight)")
}
