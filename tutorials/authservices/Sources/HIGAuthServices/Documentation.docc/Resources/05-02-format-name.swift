import Foundation

extension AppleSignInManager {
    
    func formatFullName(_ components: PersonNameComponents?) -> String {
        guard let components = components else {
            return "사용자"
        }
        
        // PersonNameComponentsFormatter 사용
        // 문화권에 맞게 자동으로 이름을 조합
        let formatter = PersonNameComponentsFormatter()
        
        // 기본 스타일로 포맷팅
        let formattedName = formatter.string(from: components)
        
        // 예시:
        // 한국: "김철수" (성+이름)
        // 미국: "John Smith" (이름+성)
        // 일본: "田中 太郎" (성+이름)
        
        return formattedName
    }
}
