# PDFKit AI Reference

> PDF 뷰어 및 편집 가이드. 이 문서를 읽고 PDFKit 코드를 생성할 수 있습니다.

## 개요

PDFKit은 PDF 문서를 표시하고 조작하는 프레임워크입니다.
페이지 탐색, 검색, 주석, 텍스트 선택 등을 지원합니다.

## 필수 Import

```swift
import PDFKit
import SwiftUI
```

## 핵심 구성요소

### 1. PDFDocument

```swift
// URL에서 로드
let url = Bundle.main.url(forResource: "sample", withExtension: "pdf")!
let document = PDFDocument(url: url)

// 데이터에서 로드
let document = PDFDocument(data: pdfData)

// 페이지 접근
let pageCount = document?.pageCount ?? 0
let page = document?.page(at: 0)
```

### 2. PDFView

```swift
let pdfView = PDFView()
pdfView.document = document
pdfView.autoScales = true
pdfView.displayMode = .singlePageContinuous
pdfView.displayDirection = .vertical
```

### 3. PDFPage

```swift
// 페이지 정보
let bounds = page.bounds(for: .mediaBox)
let rotation = page.rotation

// 썸네일 생성
let thumbnail = page.thumbnail(of: CGSize(width: 100, height: 150), for: .mediaBox)

// 텍스트 추출
let text = page.string
```

## 전체 작동 예제

```swift
import SwiftUI
import PDFKit

// MARK: - PDF View Wrapper
struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument
    @Binding var currentPage: Int
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.delegate = context.coordinator
        
        // 페이지 변경 알림
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged),
            name: .PDFViewPageChanged,
            object: pdfView
        )
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // 페이지 이동
        if let page = document.page(at: currentPage) {
            uiView.go(to: page)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(currentPage: $currentPage)
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        @Binding var currentPage: Int
        
        init(currentPage: Binding<Int>) {
            _currentPage = currentPage
        }
        
        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let page = pdfView.currentPage,
                  let pageIndex = pdfView.document?.index(for: page) else { return }
            
            DispatchQueue.main.async {
                self.currentPage = pageIndex
            }
        }
    }
}

// MARK: - PDF Manager
@Observable
class PDFManager {
    var document: PDFDocument?
    var currentPage = 0
    var searchResults: [PDFSelection] = []
    var searchText = ""
    
    var pageCount: Int {
        document?.pageCount ?? 0
    }
    
    func loadDocument(from url: URL) {
        document = PDFDocument(url: url)
    }
    
    func loadDocument(from data: Data) {
        document = PDFDocument(data: data)
    }
    
    func search(_ text: String) {
        guard let document, !text.isEmpty else {
            searchResults = []
            return
        }
        
        searchResults = document.findString(text, withOptions: .caseInsensitive)
    }
    
    func goToNextPage() {
        if currentPage < pageCount - 1 {
            currentPage += 1
        }
    }
    
    func goToPreviousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    func goToPage(_ index: Int) {
        if index >= 0 && index < pageCount {
            currentPage = index
        }
    }
}

// MARK: - Views
struct PDFReaderView: View {
    @State private var manager = PDFManager()
    @State private var showingThumbnails = false
    @State private var showingSearch = false
    
    let pdfURL: URL
    
    var body: some View {
        NavigationStack {
            Group {
                if let document = manager.document {
                    PDFKitView(document: document, currentPage: $manager.currentPage)
                } else {
                    ContentUnavailableView("PDF 로드 실패", systemImage: "doc.fill")
                }
            }
            .navigationTitle("PDF 뷰어")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: manager.goToPreviousPage) {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(manager.currentPage == 0)
                        
                        Spacer()
                        
                        Text("\(manager.currentPage + 1) / \(manager.pageCount)")
                            .font(.caption)
                        
                        Spacer()
                        
                        Button(action: manager.goToNextPage) {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(manager.currentPage >= manager.pageCount - 1)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingThumbnails = true
                        } label: {
                            Label("썸네일", systemImage: "square.grid.2x2")
                        }
                        
                        Button {
                            showingSearch = true
                        } label: {
                            Label("검색", systemImage: "magnifyingglass")
                        }
                        
                        if let document = manager.document {
                            ShareLink(item: pdfURL) {
                                Label("공유", systemImage: "square.and.arrow.up")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingThumbnails) {
                ThumbnailsView(manager: manager)
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(manager: manager)
            }
        }
        .onAppear {
            manager.loadDocument(from: pdfURL)
        }
    }
}

struct ThumbnailsView: View {
    let manager: PDFManager
    @Environment(\.dismiss) private var dismiss
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<manager.pageCount, id: \.self) { index in
                        if let page = manager.document?.page(at: index),
                           let thumbnail = page.thumbnail(of: CGSize(width: 100, height: 140), for: .mediaBox) {
                            Button {
                                manager.goToPage(index)
                                dismiss()
                            } label: {
                                VStack {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFit()
                                        .border(manager.currentPage == index ? Color.blue : Color.gray, width: manager.currentPage == index ? 2 : 1)
                                    
                                    Text("\(index + 1)")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("페이지")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("닫기") { dismiss() }
            }
        }
    }
}

struct SearchView: View {
    let manager: PDFManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(manager.searchResults.enumerated()), id: \.offset) { index, selection in
                    Button {
                        if let page = selection.pages.first,
                           let pageIndex = manager.document?.index(for: page) {
                            manager.goToPage(pageIndex)
                            dismiss()
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            if let page = selection.pages.first,
                               let pageIndex = manager.document?.index(for: page) {
                                Text("페이지 \(pageIndex + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text(selection.string ?? "")
                                .lineLimit(2)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "텍스트 검색")
            .onChange(of: searchText) { _, newValue in
                manager.search(newValue)
            }
            .navigationTitle("검색")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("닫기") { dismiss() }
            }
            .overlay {
                if manager.searchResults.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView("검색 결과 없음", systemImage: "magnifyingglass")
                }
            }
        }
    }
}
```

## 고급 패턴

### 1. PDF 생성

```swift
func createPDF(text: String) -> Data? {
    let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)  // A4
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
    
    return renderer.pdfData { context in
        context.beginPage()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14)
        ]
        
        let textRect = CGRect(x: 50, y: 50, width: pageRect.width - 100, height: pageRect.height - 100)
        text.draw(in: textRect, withAttributes: attributes)
    }
}
```

### 2. 주석 추가

```swift
func addHighlight(to page: PDFPage, selection: PDFSelection) {
    let highlight = PDFAnnotation(
        bounds: selection.bounds(for: page),
        forType: .highlight,
        withProperties: nil
    )
    highlight.color = .yellow.withAlphaComponent(0.5)
    page.addAnnotation(highlight)
}

func addTextAnnotation(to page: PDFPage, at point: CGPoint, text: String) {
    let annotation = PDFAnnotation(
        bounds: CGRect(x: point.x, y: point.y, width: 200, height: 100),
        forType: .freeText,
        withProperties: nil
    )
    annotation.contents = text
    annotation.font = UIFont.systemFont(ofSize: 12)
    annotation.color = .yellow
    page.addAnnotation(annotation)
}
```

### 3. PDF 저장

```swift
func savePDF(document: PDFDocument, to url: URL) -> Bool {
    return document.write(to: url)
}

func saveToPhotos(page: PDFPage) {
    if let image = page.thumbnail(of: CGSize(width: 1000, height: 1400), for: .mediaBox) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
```

### 4. 텍스트 추출

```swift
func extractAllText(from document: PDFDocument) -> String {
    var text = ""
    for i in 0..<document.pageCount {
        if let page = document.page(at: i),
           let pageText = page.string {
            text += pageText + "\n"
        }
    }
    return text
}
```

## 주의사항

1. **메모리 관리**
   - 큰 PDF는 메모리 주의
   - 썸네일 캐싱 권장

2. **비동기 로딩**
   ```swift
   Task {
       let document = await Task.detached {
           PDFDocument(url: url)
       }.value
   }
   ```

3. **보안 PDF**
   - 암호 보호된 PDF: `document.unlock(withPassword:)`
   - DRM 문서는 추가 처리 필요

4. **인쇄**
   ```swift
   let printInfo = UIPrintInfo(dictionary: nil)
   printInfo.outputType = .general
   
   let printController = UIPrintInteractionController.shared
   printController.printInfo = printInfo
   printController.printingItem = document.dataRepresentation()
   printController.present(animated: true)
   ```
