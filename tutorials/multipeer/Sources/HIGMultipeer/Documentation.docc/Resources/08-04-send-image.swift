import MultipeerConnectivity
import UIKit

class ResourceManager {
    
    let session: MCSession
    
    // UIImage 전송
    func sendImage(_ image: UIImage, to peer: MCPeerID, quality: CGFloat = 0.8) -> Progress? {
        // 임시 파일로 저장
        guard let data = image.jpegData(compressionQuality: quality) else {
            return nil
        }
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        
        do {
            try data.write(to: tempURL)
        } catch {
            print("이미지 저장 실패: \(error)")
            return nil
        }
        
        // 전송 후 임시 파일 삭제
        return session.sendResource(
            at: tempURL,
            withName: "image_\(Date().timeIntervalSince1970).jpg",
            toPeer: peer
        ) { error in
            // 임시 파일 정리
            try? FileManager.default.removeItem(at: tempURL)
            
            if let error = error {
                print("이미지 전송 실패: \(error)")
            }
        }
    }
}
