import SwiftUI

struct ErrorAlertView: View {
    let error: UserFriendlyError
    let recoveryOptions: [ErrorRecoveryManager.RecoveryOption]
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // 아이콘
            Image(systemName: error.icon)
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            // 제목
            Text(error.title)
                .font(.title2.bold())
            
            // 메시지
            Text(error.message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // 제안
            if let suggestion = error.suggestion {
                Text(suggestion)
                    .font(.callout)
                    .padding()
                    .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
            
            // 복구 옵션 버튼
            VStack(spacing: 12) {
                ForEach(recoveryOptions.indices, id: \.self) { index in
                    Button(recoveryOptions[index].title) {
                        Task {
                            try? await recoveryOptions[index].action()
                            onDismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("닫기", role: .cancel) {
                    onDismiss()
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(24)
    }
}

// 에러 상태를 포함한 컨테이너 뷰
struct ErrorHandlingContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content
    @State private var currentError: AccessorySetupError?
    @State private var showingError = false
    
    private let recoveryManager = ErrorRecoveryManager()
    
    var body: some View {
        content()
            .environment(\.handleError) { error in
                currentError = error
                showingError = true
            }
            .sheet(isPresented: $showingError) {
                if let error = currentError {
                    ErrorAlertView(
                        error: UserFriendlyError(from: error),
                        recoveryOptions: recoveryManager.recoveryOptions(for: error)
                    ) {
                        showingError = false
                    }
                    .presentationDetents([.medium])
                }
            }
    }
}

// Environment key for error handling
struct ErrorHandlerKey: EnvironmentKey {
    static let defaultValue: (AccessorySetupError) -> Void = { _ in }
}

extension EnvironmentValues {
    var handleError: (AccessorySetupError) -> Void {
        get { self[ErrorHandlerKey.self] }
        set { self[ErrorHandlerKey.self] = newValue }
    }
}
