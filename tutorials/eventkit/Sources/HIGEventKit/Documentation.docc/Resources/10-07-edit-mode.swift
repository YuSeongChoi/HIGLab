import SwiftUI
import EventKit
import EventKitUI

struct EventEditorWrapper: UIViewControllerRepresentable {
    let eventStore: EKEventStore
    var event: EKEvent?  // nil이면 새 이벤트 생성
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        
        if let event = event {
            controller.event = event
        } else {
            // 새 이벤트 생성
            let newEvent = EKEvent(eventStore: eventStore)
            newEvent.calendar = eventStore.defaultCalendarForNewEvents
            controller.event = newEvent
        }
        
        controller.editViewDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        @Binding var isPresented: Bool
        
        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
        
        func eventEditViewController(
            _ controller: EKEventEditViewController,
            didCompleteWith action: EKEventEditViewAction
        ) {
            isPresented = false
        }
    }
}
