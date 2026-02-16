import CoreNFC
import Foundation

class NFCWriter {
    
    /// 텍스트 레코드 생성
    func createTextPayload(text: String, locale: Locale = .current) -> NFCNDEFPayload? {
        // 편의 생성자 사용 (자동으로 언어 코드 및 인코딩 처리)
        return NFCNDEFPayload.wellKnownTypeTextPayload(
            string: text,
            locale: locale
        )
    }
    
    // 사용 예시
    func createTextRecords() {
        // 현재 로케일로 텍스트 생성
        if let payload = createTextPayload(text: "안녕하세요!") {
            print("한국어 텍스트 생성 완료")
        }
        
        // 특정 언어로 텍스트 생성
        let englishLocale = Locale(identifier: "en")
        if let payload = createTextPayload(text: "Hello!", locale: englishLocale) {
            print("영어 텍스트 생성 완료")
        }
        
        // 다국어 지원 메시지 (여러 텍스트 레코드)
        let multiLangPayloads = [
            createTextPayload(text: "안녕하세요!", locale: Locale(identifier: "ko")),
            createTextPayload(text: "Hello!", locale: Locale(identifier: "en")),
            createTextPayload(text: "こんにちは!", locale: Locale(identifier: "ja"))
        ].compactMap { $0 }
        
        print("다국어 메시지: \(multiLangPayloads.count)개 레코드")
    }
}
