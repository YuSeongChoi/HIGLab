import TipKit

// MARK: - 팁 이벤트 정의
/// 앱 전체에서 사용되는 TipKit 이벤트들을 정의합니다.
/// 이벤트는 팁의 표시 조건을 결정하는 데 사용됩니다.

enum TipEvents {
    /// 앱이 열릴 때마다 기록되는 이벤트
    /// ProTip에서 3회 이상 앱 사용 시 팁을 표시하는 데 사용
    static let appOpened = Tips.Event(id: "appOpened")
    
    /// 기능을 사용했을 때 기록되는 이벤트
    static let featureUsed = Tips.Event(id: "featureUsed")
    
    /// 특정 화면을 방문했을 때 기록되는 이벤트
    static let screenVisited = Tips.Event(id: "screenVisited")
}

// MARK: - 이벤트 기록 헬퍼
extension TipEvents {
    /// 앱 열림 이벤트를 기록합니다.
    static func recordAppOpened() async {
        await appOpened.donate()
    }
    
    /// 기능 사용 이벤트를 기록합니다.
    static func recordFeatureUsed() async {
        await featureUsed.donate()
    }
    
    /// 화면 방문 이벤트를 기록합니다.
    static func recordScreenVisited() async {
        await screenVisited.donate()
    }
}
