import PDFKit

class PDFDownloader {
    func downloadPDF(from url: URL) async throws -> PDFDocument {
        // URLSession으로 비동기 다운로드
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // HTTP 응답 확인
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Data로부터 PDFDocument 생성
        guard let document = PDFDocument(data: data) else {
            throw PDFError.invalidDocument
        }
        
        return document
    }
}

enum PDFError: Error {
    case invalidDocument
    case downloadFailed
}

// 사용 예시
// Task {
//     let url = URL(string: "https://example.com/document.pdf")!
//     let document = try await downloader.downloadPDF(from: url)
//     pdfView.document = document
// }
