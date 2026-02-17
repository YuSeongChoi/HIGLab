import AccessorySetupKit

@Observable
class PairingManager {
    private let session = ASAccessorySession()
    var state: PairingState = .idle
    var pairedAccessory: ASAccessory?
    
    func startSession() {
        session.activate(on: .main) { [weak self] event in
            self?.handleSessionEvent(event)
        }
    }
    
    private func handleSessionEvent(_ event: ASAccessoryEvent) {
        switch event.eventType {
        case .activated:
            // 세션 활성화됨 - 이전에 페어링된 액세서리 복원
            state = .ready
            
        case .pickerDidPresent:
            // 피커가 표시됨
            state = .discovering
            
        case .pickerDidDismiss:
            // 사용자가 피커를 닫음
            if state == .discovering {
                state = .ready // 선택 없이 닫힘
            }
            
        case .accessoryAdded:
            // 새 액세서리가 페어링됨
            pairedAccessory = event.accessory
            state = .paired
            
        case .accessoryRemoved:
            // 액세서리 페어링 해제됨
            pairedAccessory = nil
            state = .ready
            
        case .accessoryChanged:
            // 액세서리 상태 변경됨
            pairedAccessory = event.accessory
            
        default:
            break
        }
    }
}
