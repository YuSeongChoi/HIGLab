import SwiftUI
import EventKit
import EventKitUI

struct EventDetailViewWrapper: UIViewControllerRepresentable {
    let event: EKEvent
    var allowsEditing: Bool = true
    
    func makeUIViewController(context: Context) -> EKEventViewController {
        let controller = EKEventViewController()
        controller.event = event
        controller.allowsEditing = allowsEditing
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventViewController, context: Context) {}
}
