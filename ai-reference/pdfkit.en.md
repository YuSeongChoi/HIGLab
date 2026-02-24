# PDFKit AI Reference

> PDF viewer and editing guide. You can generate PDFKit code by reading this document.

## Overview

PDFKit is a framework for displaying and manipulating PDF documents.
It supports page navigation, search, annotations, text selection, and more.

## Required Import

```swift
import PDFKit
import SwiftUI
```

## Core Components

### 1. PDFDocument

```swift
// Load from URL
let url = Bundle.main.url(forResource: "sample", withExtension: "pdf")!
let document = PDFDocument(url: url)

// Load from data
let document = PDFDocument(data: pdfData)

// Access pages
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
// Page information
let bounds = page.bounds(for: .mediaBox)
let rotation = page.rotation

// Generate thumbnail
let thumbnail = page.thumbnail(of: CGSize(width: 100, height: 150), for: .mediaBox)

// Extract text
let text = page.string
```

## Complete Working Example

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
        
        // Page change notification
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged),
            name: .PDFViewPageChanged,
            object: pdfView
        )
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Navigate to page
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
                    ContentUnavailableView("Failed to Load PDF", systemImage: "doc.fill")
                }
            }
            .navigationTitle("PDF Viewer")
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
                            Label("Thumbnails", systemImage: "square.grid.2x2")
                        }
                        
                        Button {
                            showingSearch = true
                        } label: {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        
                        if let document = manager.document {
                            ShareLink(item: pdfURL) {
                                Label("Share", systemImage: "square.and.arrow.up")
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
            .navigationTitle("Pages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Close") { dismiss() }
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
                                Text("Page \(pageIndex + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text(selection.string ?? "")
                                .lineLimit(2)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search text")
            .onChange(of: searchText) { _, newValue in
                manager.search(newValue)
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Close") { dismiss() }
            }
            .overlay {
                if manager.searchResults.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView("No Results", systemImage: "magnifyingglass")
                }
            }
        }
    }
}
```

## Advanced Patterns

### 1. PDF Creation

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

### 2. Adding Annotations

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

### 3. Saving PDF

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

### 4. Text Extraction

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

## Notes

1. **Memory Management**
   - Be careful with large PDFs
   - Thumbnail caching recommended

2. **Async Loading**
   ```swift
   Task {
       let document = await Task.detached {
           PDFDocument(url: url)
       }.value
   }
   ```

3. **Secured PDFs**
   - Password-protected PDFs: `document.unlock(withPassword:)`
   - DRM documents require additional handling

4. **Printing**
   ```swift
   let printInfo = UIPrintInfo(dictionary: nil)
   printInfo.outputType = .general
   
   let printController = UIPrintInteractionController.shared
   printController.printInfo = printInfo
   printController.printingItem = document.dataRepresentation()
   printController.present(animated: true)
   ```
