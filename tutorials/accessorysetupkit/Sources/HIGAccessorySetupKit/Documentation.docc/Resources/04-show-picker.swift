import AccessorySetupKit
import SwiftUI

@Observable
class AccessoryManager {
    private let session = ASAccessorySession()
    var discoveredAccessories: [ASAccessory] = []
    
    func activate() {
        session.activate(on: .main) { [weak self] event in
            self?.handleEvent(event)
        }
    }
    
    // 시스템 피커 표시
    func showPicker() {
        let items = createPickerItems()
        session.showPicker(for: items) { error in
            if let error {
                print("피커 표시 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleEvent(_ event: ASAccessoryEvent) {
        switch event.eventType {
        case .pickerDidPresent:
            print("피커가 표시됨")
        case .pickerDidDismiss:
            print("피커가 닫힘")
        case .accessoryAdded:
            if let accessory = event.accessory {
                discoveredAccessories.append(accessory)
            }
        default:
            break
        }
    }
}
