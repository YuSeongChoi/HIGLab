// MessageBubbleView.swift
// 채팅 메시지 버블 뷰
// iOS 26+ | FoundationModels

import SwiftUI

/// 메시지 버블 뷰
struct MessageBubbleView: View {
    
    let message: Message
    
    /// 사용자 메시지 여부
    private var isUser: Bool {
        message.role == .user
    }
    
    var body: some View {
        HStack {
            // 사용자 메시지는 오른쪽 정렬
            if isUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                // 메시지 내용
                Text(message.content)
                    .textSelection(.enabled)
                
                // 타임스탬프
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(bubbleBackground, in: bubbleShape)
            
            // AI 메시지는 왼쪽 정렬
            if !isUser {
                Spacer(minLength: 60)
            }
        }
        .contextMenu {
            // 복사 버튼
            Button {
                UIPasteboard.general.string = message.content
            } label: {
                Label("복사", systemImage: "doc.on.doc")
            }
            
            // 공유 버튼
            ShareLink(item: message.content) {
                Label("공유", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    // MARK: - 스타일
    
    /// 버블 배경색
    private var bubbleBackground: some ShapeStyle {
        if isUser {
            return AnyShapeStyle(.tint)
        } else {
            return AnyShapeStyle(.fill.tertiary)
        }
    }
    
    /// 버블 모양 (말풍선 스타일)
    private var bubbleShape: some InsettableShape {
        RoundedRectangle(cornerRadius: 16)
    }
    
    /// 텍스트 색상
    private var textColor: Color {
        isUser ? .white : .primary
    }
}

// MARK: - 프리뷰

#Preview("User Message") {
    MessageBubbleView(message: .user("안녕하세요! 오늘 날씨가 어때요?"))
        .padding()
}

#Preview("Assistant Message") {
    MessageBubbleView(message: .assistant("안녕하세요! 저는 날씨 정보에 직접 접근할 수 없지만, 날씨 앱을 확인해보시는 건 어떨까요? 😊"))
        .padding()
}

#Preview("Conversation") {
    VStack(spacing: 12) {
        MessageBubbleView(message: .user("Swift에서 옵셔널이란?"))
        MessageBubbleView(message: .assistant("Swift에서 옵셔널(Optional)은 값이 있을 수도 있고 없을 수도 있는 상태를 표현하는 타입입니다.\n\n예: var name: String? = nil"))
    }
    .padding()
}
