import SwiftUI
import EventKit
import EventKitUI

struct EventDetailViewWrapper: UIViewControllerRepresentable {
    let event: EKEvent
    
    func makeUIViewController(context: Context) -> EKEventViewController {
        let controller = EKEventViewController()
        controller.event = event
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventViewController, context: Context) {}
}
