import FoundationModels
import SwiftUI

// 모델 프리로딩 및 캐싱
@MainActor
class AIModelManager: ObservableObject {
    static let shared = AIModelManager()
    
    @Published var isModelReady = false
    @Published var loadingProgress: Double = 0
    
    private var cachedSession: LanguageModel.Session?
    
    private init() {}
    
    // 앱 시작 시 또는 AI 화면 진입 전에 호출
    func preloadModel() async {
        guard !isModelReady else { return }
        
        do {
            // 모델 가용성 확인
            let availability = await LanguageModel.default.checkAvailability()
            
            switch availability {
            case .available:
                // 세션 미리 생성
                cachedSession = LanguageModel.default.createSession()
                isModelReady = true
                
            case .needsDownload(let size):
                // 다운로드가 필요한 경우 (큰 모델)
                print("모델 다운로드 필요: \(size)MB")
                
            case .unavailable:
                print("이 기기에서 사용할 수 없습니다")
            }
            
        } catch {
            print("모델 로딩 실패: \(error)")
        }
    }
    
    // 캐시된 세션 반환 또는 새로 생성
    func getSession(systemPrompt: String? = nil) -> LanguageModel.Session {
        if let cached = cachedSession, systemPrompt == nil {
            return cached
        }
        
        let session = LanguageModel.default.createSession(
            systemPrompt: systemPrompt
        )
        
        if systemPrompt == nil {
            cachedSession = session
        }
        
        return session
    }
    
    // 메모리 부족 시 캐시 해제
    func releaseCache() {
        cachedSession = nil
        isModelReady = false
    }
}

// 뷰에서 사용
struct AIFeatureView: View {
    @StateObject var modelManager = AIModelManager.shared
    
    var body: some View {
        Group {
            if modelManager.isModelReady {
                ChatInterface()
            } else {
                LoadingView()
                    .task {
                        await modelManager.preloadModel()
                    }
            }
        }
    }
}

struct ChatInterface: View {
    var body: some View {
        Text("AI 채팅 준비 완료")
    }
}

struct LoadingView: View {
    var body: some View {
        ProgressView("AI 모델 준비 중...")
    }
}
