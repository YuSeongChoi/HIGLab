import Foundation

/// Info.plist 권한 설명 문자열 (참고용)
enum LocationPermissionStrings {
    /// When In Use 권한 설명
    static let whenInUse = """
    러닝 중 실시간으로 경로를 추적하고 거리와 페이스를 계산합니다.
    """
    
    /// Always 권한 설명
    static let always = """
    화면이 꺼져 있어도 러닝 경로를 계속 기록합니다. 
    백그라운드 추적을 허용하면 정확한 러닝 기록을 받을 수 있습니다.
    """
    
    // 💡 Info.plist에 직접 추가해야 합니다:
    //
    // Privacy - Location When In Use Usage Description
    // Privacy - Location Always and When In Use Usage Description
}
