import SwiftUI
import CloudKit
import UIKit

/// SwiftUI용 CloudSharing 래퍼
struct CloudSharingView: UIViewControllerRepresentable {
    
    let share: CKShare
    let container: CKContainer
    let onComplete: (Result<Void, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        controller.delegate = context.coordinator
        controller.availablePermissions = [.allowPublic, .allowPrivate, .allowReadOnly, .allowReadWrite]
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }
    
    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        let onComplete: (Result<Void, Error>) -> Void
        
        init(onComplete: @escaping (Result<Void, Error>) -> Void) {
            self.onComplete = onComplete
        }
        
        func cloudSharingController(
            _ csc: UICloudSharingController,
            failedToSaveShareWithError error: Error
        ) {
            onComplete(.failure(error))
        }
        
        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            onComplete(.success(()))
        }
        
        func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
            onComplete(.success(()))
        }
        
        func itemTitle(for csc: UICloudSharingController) -> String? {
            return "공유 메모"
        }
    }
}
