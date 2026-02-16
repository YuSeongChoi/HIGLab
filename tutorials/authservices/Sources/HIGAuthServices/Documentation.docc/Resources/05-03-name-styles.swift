import Foundation

extension AppleSignInManager {
    
    func formatWithStyles(_ components: PersonNameComponents?) {
        guard let components = components else { return }
        
        let formatter = PersonNameComponentsFormatter()
        
        // .short - 간단한 이름 (예: "철수")
        formatter.style = .short
        let shortName = formatter.string(from: components)
        
        // .medium - 일반적인 이름 (예: "김철수")
        formatter.style = .medium
        let mediumName = formatter.string(from: components)
        
        // .long - 전체 이름 (예: "김철수 박사")
        formatter.style = .long
        let longName = formatter.string(from: components)
        
        // .abbreviated - 약어 (예: "김")
        formatter.style = .abbreviated
        let abbreviatedName = formatter.string(from: components)
        
        print("Short: \(shortName)")
        print("Medium: \(mediumName)")
        print("Long: \(longName)")
        print("Abbreviated: \(abbreviatedName)")
    }
}
