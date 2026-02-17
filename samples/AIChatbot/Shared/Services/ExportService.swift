// ExportService.swift
// 대화 내보내기/가져오기 서비스
// iOS 26+ | FoundationModels
//
// JSON, Markdown, 텍스트 형식으로 대화를 내보내고 가져오기

import Foundation
import UniformTypeIdentifiers

// MARK: - 내보내기 서비스

/// 대화 내보내기/가져오기를 담당하는 서비스
@MainActor
@Observable
final class ExportService {
    
    // MARK: - 상태
    
    /// 현재 작업 중 여부
    private(set) var isProcessing: Bool = false
    
    /// 마지막 에러
    private(set) var lastError: ExportError?
    
    // MARK: - 내보내기 형식
    
    /// 지원하는 내보내기 형식
    enum ExportFormat: String, CaseIterable, Sendable {
        case json = "JSON"
        case markdown = "Markdown"
        case text = "텍스트"
        case html = "HTML"
        
        var fileExtension: String {
            switch self {
            case .json: return "json"
            case .markdown: return "md"
            case .text: return "txt"
            case .html: return "html"
            }
        }
        
        var utType: UTType {
            switch self {
            case .json: return .json
            case .markdown: return UTType(filenameExtension: "md") ?? .plainText
            case .text: return .plainText
            case .html: return .html
            }
        }
        
        var mimeType: String {
            switch self {
            case .json: return "application/json"
            case .markdown: return "text/markdown"
            case .text: return "text/plain"
            case .html: return "text/html"
            }
        }
    }
    
    // MARK: - 단일 대화 내보내기
    
    /// 대화를 지정된 형식으로 내보내기
    /// - Parameters:
    ///   - conversation: 내보낼 대화
    ///   - format: 내보내기 형식
    /// - Returns: 내보내기 데이터
    func export(
        _ conversation: Conversation,
        format: ExportFormat
    ) throws -> Data {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let content: String
            
            switch format {
            case .json:
                content = try exportToJSON(conversation)
            case .markdown:
                content = exportToMarkdown(conversation)
            case .text:
                content = exportToText(conversation)
            case .html:
                content = exportToHTML(conversation)
            }
            
            guard let data = content.data(using: .utf8) else {
                throw ExportError.encodingFailed
            }
            
            return data
            
        } catch {
            lastError = error as? ExportError ?? .unknown(error)
            throw error
        }
    }
    
    /// 파일 이름 생성
    /// - Parameters:
    ///   - conversation: 대화
    ///   - format: 형식
    /// - Returns: 파일 이름
    func fileName(
        for conversation: Conversation,
        format: ExportFormat
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = dateFormatter.string(from: Date())
        
        let sanitizedTitle = conversation.title
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
            .prefix(30)
        
        return "\(sanitizedTitle)_\(dateString).\(format.fileExtension)"
    }
    
    // MARK: - JSON 내보내기
    
    private func exportToJSON(_ conversation: Conversation) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        
        let data = try encoder.encode(conversation)
        
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw ExportError.encodingFailed
        }
        
        return jsonString
    }
    
    // MARK: - Markdown 내보내기
    
    private func exportToMarkdown(_ conversation: Conversation) -> String {
        var md = """
            # \(conversation.title)
            
            - **생성일**: \(conversation.formattedCreatedAt)
            - **메시지 수**: \(conversation.messageCount)
            - **토큰 사용량**: \(conversation.totalTokenUsage.description)
            
            ---
            
            ## 시스템 프롬프트
            
            ```
            \(conversation.systemPrompt)
            ```
            
            ---
            
            ## 대화 내용
            
            
            """
        
        for message in conversation.messages {
            let roleEmoji: String
            let roleName: String
            
            switch message.role {
            case .user:
                roleEmoji = "👤"
                roleName = "사용자"
            case .assistant:
                roleEmoji = "🤖"
                roleName = "AI"
            case .system:
                roleEmoji = "ℹ️"
                roleName = "시스템"
            case .tool:
                roleEmoji = "🔧"
                roleName = "도구"
            }
            
            md += """
                ### \(roleEmoji) \(roleName) (\(message.formattedTime))
                
                \(message.content)
                
                
                """
            
            // 도구 호출 정보
            for toolCall in message.toolCalls {
                md += """
                    > **도구 호출**: \(toolCall.toolName)
                    > - 결과: \(toolCall.result ?? "없음")
                    
                    
                    """
            }
            
            // 토큰 사용량
            if let usage = message.tokenUsage {
                md += "_토큰: \(usage.description)_\n\n"
            }
        }
        
        md += """
            
            ---
            
            _내보내기 시간: \(formattedCurrentTime())_
            """
        
        return md
    }
    
    // MARK: - 텍스트 내보내기
    
    private func exportToText(_ conversation: Conversation) -> String {
        var text = """
            ═══════════════════════════════════════════
            \(conversation.title)
            ═══════════════════════════════════════════
            
            생성일: \(conversation.formattedCreatedAt)
            메시지 수: \(conversation.messageCount)
            
            ───────────────────────────────────────────
            
            
            """
        
        for message in conversation.messages {
            let roleName = message.role == .user ? "[사용자]" : "[AI]"
            
            text += """
                \(roleName) \(message.formattedTime)
                \(message.content)
                
                
                """
        }
        
        text += """
            ───────────────────────────────────────────
            내보내기: \(formattedCurrentTime())
            """
        
        return text
    }
    
    // MARK: - HTML 내보내기
    
    private func exportToHTML(_ conversation: Conversation) -> String {
        var html = """
            <!DOCTYPE html>
            <html lang="ko">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>\(escapeHTML(conversation.title))</title>
                <style>
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                        max-width: 800px;
                        margin: 0 auto;
                        padding: 20px;
                        background: #f5f5f5;
                    }
                    h1 {
                        color: #333;
                        border-bottom: 2px solid #007AFF;
                        padding-bottom: 10px;
                    }
                    .meta {
                        color: #666;
                        font-size: 0.9em;
                        margin-bottom: 20px;
                    }
                    .message {
                        margin: 15px 0;
                        padding: 15px;
                        border-radius: 12px;
                    }
                    .user {
                        background: #007AFF;
                        color: white;
                        margin-left: 50px;
                    }
                    .assistant {
                        background: white;
                        color: #333;
                        margin-right: 50px;
                        border: 1px solid #ddd;
                    }
                    .system {
                        background: #f0f0f0;
                        color: #666;
                        font-style: italic;
                    }
                    .tool {
                        background: #e8f5e9;
                        color: #2e7d32;
                        border-left: 4px solid #4caf50;
                    }
                    .time {
                        font-size: 0.8em;
                        opacity: 0.7;
                        margin-top: 5px;
                    }
                    .tool-call {
                        background: rgba(0,0,0,0.05);
                        padding: 10px;
                        border-radius: 8px;
                        margin-top: 10px;
                        font-size: 0.9em;
                    }
                    footer {
                        margin-top: 30px;
                        text-align: center;
                        color: #999;
                        font-size: 0.8em;
                    }
                </style>
            </head>
            <body>
                <h1>📱 \(escapeHTML(conversation.title))</h1>
                <div class="meta">
                    <p>생성일: \(conversation.formattedCreatedAt)</p>
                    <p>메시지 수: \(conversation.messageCount)</p>
                </div>
            
            """
        
        for message in conversation.messages {
            let roleClass = message.role.rawValue
            
            html += """
                <div class="message \(roleClass)">
                    <div class="content">\(escapeHTML(message.content))</div>
                    <div class="time">\(message.formattedTime)</div>
            """
            
            for toolCall in message.toolCalls {
                html += """
                    <div class="tool-call">
                        🔧 <strong>\(escapeHTML(toolCall.toolName))</strong>: \(escapeHTML(toolCall.result ?? ""))
                    </div>
                """
            }
            
            html += "</div>\n"
        }
        
        html += """
                <footer>
                    AI Chatbot - 내보내기 시간: \(formattedCurrentTime())
                </footer>
            </body>
            </html>
            """
        
        return html
    }
    
    // MARK: - 여러 대화 내보내기
    
    /// 여러 대화를 ZIP으로 내보내기
    /// - Parameters:
    ///   - conversations: 내보낼 대화들
    ///   - format: 내보내기 형식
    /// - Returns: ZIP 데이터 (실제 구현 시 ZipFoundation 등 사용)
    func exportMultiple(
        _ conversations: [Conversation],
        format: ExportFormat
    ) throws -> [(name: String, data: Data)] {
        isProcessing = true
        defer { isProcessing = false }
        
        var results: [(name: String, data: Data)] = []
        
        for conversation in conversations {
            let data = try export(conversation, format: format)
            let name = fileName(for: conversation, format: format)
            results.append((name: name, data: data))
        }
        
        return results
    }
    
    // MARK: - 가져오기
    
    /// JSON에서 대화 가져오기
    /// - Parameter data: JSON 데이터
    /// - Returns: 가져온 대화
    func importFromJSON(_ data: Data) throws -> Conversation {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let conversation = try decoder.decode(Conversation.self, from: data)
            return conversation
            
        } catch {
            lastError = .importFailed(error.localizedDescription)
            throw ExportError.importFailed(error.localizedDescription)
        }
    }
    
    /// 파일 URL에서 대화 가져오기
    /// - Parameter url: 파일 URL
    /// - Returns: 가져온 대화
    func importFromURL(_ url: URL) throws -> Conversation {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let data = try Data(contentsOf: url)
            return try importFromJSON(data)
        } catch {
            lastError = .fileReadFailed
            throw ExportError.fileReadFailed
        }
    }
    
    // MARK: - 유틸리티
    
    /// 현재 시간 포맷팅
    private func formattedCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
    
    /// HTML 이스케이프
    private func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
            .replacingOccurrences(of: "\n", with: "<br>")
    }
}

// MARK: - 에러 정의

/// 내보내기/가져오기 에러
enum ExportError: LocalizedError {
    case encodingFailed
    case fileWriteFailed
    case fileReadFailed
    case importFailed(String)
    case invalidFormat
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "데이터 인코딩에 실패했습니다."
        case .fileWriteFailed:
            return "파일 저장에 실패했습니다."
        case .fileReadFailed:
            return "파일을 읽을 수 없습니다."
        case .importFailed(let reason):
            return "가져오기 실패: \(reason)"
        case .invalidFormat:
            return "지원하지 않는 형식입니다."
        case .unknown(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}

// MARK: - 프리뷰 지원

extension ExportService {
    
    /// 프리뷰용 서비스
    static var preview: ExportService {
        ExportService()
    }
}
