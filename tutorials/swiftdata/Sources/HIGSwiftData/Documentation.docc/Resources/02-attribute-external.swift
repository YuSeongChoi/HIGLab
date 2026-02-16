import SwiftData
import Foundation

@Model
class TaskItem {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    // @Attribute(.externalStorage): 외부 파일로 저장
    // 큰 데이터 (이미지, 동영상, 문서 등)에 적합
    // SQLite 블롭 대신 별도 파일로 관리 → 성능 향상
    
    @Attribute(.externalStorage)
    var attachmentData: Data?
    
    // 이미지 저장 예시
    @Attribute(.externalStorage)
    var imageData: Data?
    
    init(
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = .now,
        attachmentData: Data? = nil,
        imageData: Data? = nil
    ) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.attachmentData = attachmentData
        self.imageData = imageData
    }
}

// ─────────────────────────────────────────

// 사용 예시
import SwiftUI

struct TaskDetailView: View {
    let task: TaskItem
    
    var body: some View {
        VStack {
            Text(task.title)
            
            // 이미지 표시
            if let imageData = task.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
    
    func attachImage(_ image: UIImage) {
        // UIImage → Data 변환 후 저장
        task.imageData = image.jpegData(compressionQuality: 0.8)
        // SwiftData가 자동으로 외부 파일로 저장
    }
}

// 💡 언제 사용하나?
// - 이미지: 100KB 이상
// - 파일: PDF, 오디오, 비디오
// - 대용량 텍스트: 로그, 긴 노트
