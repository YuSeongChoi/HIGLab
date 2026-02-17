import FoundationModels

// Foundation Models 응답의 안전성 검사
func processWithGuardrails(prompt: String) async {
    let session = LanguageModel.default.createSession()
    
    do {
        let response = try await session.generate(prompt: prompt)
        
        // 응답이 성공적으로 생성됨
        print("응답: \(response)")
        
    } catch LanguageModelError.guardrailViolation(let reason) {
        // 가드레일에 의해 차단된 경우
        switch reason {
        case .harmfulContent:
            print("유해한 콘텐츠가 감지되었습니다.")
        case .personalInformation:
            print("개인정보 보호를 위해 응답이 제한되었습니다.")
        case .unsupportedTopic:
            print("지원되지 않는 주제입니다.")
        @unknown default:
            print("안전상의 이유로 응답할 수 없습니다.")
        }
        
    } catch LanguageModelError.inputTooLong {
        print("입력이 너무 깁니다. 더 짧게 입력해주세요.")
        
    } catch {
        print("알 수 없는 오류: \(error)")
    }
}

// 스트리밍에서의 가드레일 처리
func streamWithGuardrails(prompt: String) async {
    let model = LanguageModel.default
    
    do {
        for try await token in model.streamGenerate(prompt: prompt) {
            // 각 토큰은 이미 가드레일을 통과한 상태
            print(token.text, terminator: "")
            
            // 중간에 가드레일 위반이 감지되면 스트림이 중단됨
        }
    } catch LanguageModelError.guardrailViolation {
        print("\n[응답이 안전상의 이유로 중단되었습니다]")
    } catch {
        print("\n오류: \(error)")
    }
}
