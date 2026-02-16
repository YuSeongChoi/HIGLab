import ShazamKit

// SHSession.Result - 매칭 결과 타입
enum ResultExample {
    static func handleResult(_ result: SHSession.Result) {
        switch result {
        case .match(let match):
            // 매칭 성공!
            // match.mediaItems에 인식된 곡 정보가 담김
            print("매칭 성공: \(match.mediaItems.count)개 결과")
            
        case .noMatch(let signature):
            // Shazam 카탈로그에 없는 곡
            // signature는 생성된 시그니처 (커스텀 카탈로그에 활용 가능)
            print("매칭 실패 - 시그니처 길이: \(signature.duration)초")
            
        case .error(let error, let signature):
            // 오류 발생 (네트워크 문제 등)
            // signature는 nil일 수 있음
            print("오류: \(error.localizedDescription)")
        }
    }
}
