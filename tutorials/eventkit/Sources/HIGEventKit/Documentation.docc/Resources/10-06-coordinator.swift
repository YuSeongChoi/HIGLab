import EventKit
import EventKitUI

class EventEditorCoordinator: NSObject, EKEventEditViewDelegate {
    let onComplete: (EKEventEditViewAction) -> Void
    
    init(onComplete: @escaping (EKEventEditViewAction) -> Void) {
        self.onComplete = onComplete
    }
    
    func eventEditViewController(
        _ controller: EKEventEditViewController,
        didCompleteWith action: EKEventEditViewAction
    ) {
        switch action {
        case .saved:
            print("이벤트 저장됨")
        case .deleted:
            print("이벤트 삭제됨")
        case .canceled:
            print("취소됨")
        @unknown default:
            break
        }
        
        onComplete(action)
    }
}
