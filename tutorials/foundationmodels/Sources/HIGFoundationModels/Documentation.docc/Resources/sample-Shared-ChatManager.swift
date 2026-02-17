// ChatManager.swift
// FoundationModels LanguageModel 래퍼
// iOS 26+ | FoundationModels

import Foundation
import FoundationModels

/// 채팅 관리자 - LanguageModel과의 통신 담당
@MainActor
@Observable
final class ChatManager {
    
    // MARK: - 상태
    
    /// 현재 스트리밍 중인 응답 텍스트
    private(set) var streamingText: String = ""
    
    /// 응답 생성 중 여부
    private(set) var isGenerating: Bool = false
    
    /// 에러 메시지
    private(set) var errorMessage: String?
    
    // MARK: - LanguageModel
    
    /// 시스템 프롬프트
    var systemPrompt: String = "당신은 친절하고 도움이 되는 AI 어시스턴트입니다. 한국어로 답변해주세요."
    
    /// LanguageModel 세션
    private var session: LanguageModelSession?
    
    // MARK: - 초기화
    
    init() {
        resetSession()
    }
    
    /// 세션 초기화 (대화 초기화 시 호출)
    func resetSession() {
        session = LanguageModelSession(
            instructions: systemPrompt
        )
        streamingText = ""
        errorMessage = nil
    }
    
    // MARK: - 메시지 전송
    
    /// 메시지를 전송하고 스트리밍 응답 받기
    /// - Parameter content: 사용자 메시지 내용
    /// - Returns: 완성된 AI 응답 텍스트
    func send(_ content: String) async throws -> String {
        guard !isGenerating else {
            throw ChatError.alreadyGenerating
        }
        
        guard let session else {
            throw ChatError.sessionNotAvailable
        }
        
        isGenerating = true
        streamingText = ""
        errorMessage = nil
        
        defer {
            isGenerating = false
        }
        
        do {
            // 스트리밍 응답 요청
            let stream = session.streamResponse(to: content)
            
            // 스트림에서 텍스트 조각들을 수집
            for try await partial in stream {
                streamingText = partial.outputSoFar
            }
            
            let finalText = streamingText
            return finalText
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// 응답 생성 취소
    func cancel() {
        // 현재 FoundationModels에서는 Task 취소로 처리
        isGenerating = false
        streamingText = ""
    }
}

// MARK: - 에러 정의

enum ChatError: LocalizedError {
    case alreadyGenerating
    case sessionNotAvailable
    case modelUnavailable
    
    var errorDescription: String? {
        switch self {
        case .alreadyGenerating:
            return "이미 응답을 생성 중입니다."
        case .sessionNotAvailable:
            return "세션을 사용할 수 없습니다."
        case .modelUnavailable:
            return "언어 모델을 사용할 수 없습니다."
        }
    }
}

// MARK: - 모델 가용성 체크

extension ChatManager {
    /// 디바이스에서 모델 사용 가능 여부 확인
    static var isModelAvailable: Bool {
        // FoundationModels는 Apple Silicon Mac 또는 A17+ 칩 필요
        return SystemLanguageModel.default.isAvailable
    }
    
    /// 모델 다운로드 상태 확인
    static func checkAvailability() async -> SystemLanguageModel.Availability {
        return SystemLanguageModel.default.availability
    }
}
