import Foundation
import SwiftUI

// MARK: - DrawingStore
// 드로잉 목록의 저장 및 로드를 담당하는 저장소

@MainActor
@Observable
class DrawingStore {
    // MARK: - 속성
    
    /// 모든 드로잉 목록
    var drawings: [Drawing] = []
    
    /// 로딩 상태
    var isLoading = false
    
    /// 에러 메시지
    var errorMessage: String?
    
    // MARK: - 파일 경로
    
    /// 드로잉 저장 디렉토리
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// 드로잉 목록 파일 경로
    private var drawingsFileURL: URL {
        documentsDirectory.appendingPathComponent("drawings.json")
    }
    
    // MARK: - 초기화
    
    init() {
        // 앱 시작 시 드로잉 로드
        Task {
            await load()
        }
    }
    
    // MARK: - CRUD 작업
    
    /// 새 드로잉 생성
    func createDrawing(name: String = "새 드로잉") -> Drawing {
        let drawing = Drawing(name: name)
        drawings.insert(drawing, at: 0)  // 최신 드로잉이 맨 위에
        save()
        return drawing
    }
    
    /// 드로잉 업데이트
    func updateDrawing(_ drawing: Drawing) {
        if let index = drawings.firstIndex(where: { $0.id == drawing.id }) {
            drawings[index] = drawing
            save()
        }
    }
    
    /// 드로잉 삭제
    func deleteDrawing(_ drawing: Drawing) {
        drawings.removeAll { $0.id == drawing.id }
        save()
    }
    
    /// 여러 드로잉 삭제
    func deleteDrawings(at offsets: IndexSet) {
        drawings.remove(atOffsets: offsets)
        save()
    }
    
    // MARK: - 저장 및 로드
    
    /// 드로잉 목록 저장
    func save() {
        do {
            let data = try JSONEncoder().encode(drawings)
            try data.write(to: drawingsFileURL)
            errorMessage = nil
        } catch {
            errorMessage = "저장 실패: \(error.localizedDescription)"
            print("❌ 드로잉 저장 실패: \(error)")
        }
    }
    
    /// 드로잉 목록 로드
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard FileManager.default.fileExists(atPath: drawingsFileURL.path) else {
                // 파일이 없으면 빈 목록 사용
                drawings = []
                return
            }
            
            let data = try Data(contentsOf: drawingsFileURL)
            drawings = try JSONDecoder().decode([Drawing].self, from: data)
            errorMessage = nil
        } catch {
            errorMessage = "로드 실패: \(error.localizedDescription)"
            print("❌ 드로잉 로드 실패: \(error)")
            drawings = []
        }
    }
    
    // MARK: - 정렬
    
    /// 수정일 기준 정렬
    func sortByModifiedDate(ascending: Bool = false) {
        drawings.sort {
            ascending ? $0.modifiedAt < $1.modifiedAt : $0.modifiedAt > $1.modifiedAt
        }
    }
    
    /// 이름 기준 정렬
    func sortByName(ascending: Bool = true) {
        drawings.sort {
            ascending ? $0.name < $1.name : $0.name > $1.name
        }
    }
    
    /// 생성일 기준 정렬
    func sortByCreatedDate(ascending: Bool = false) {
        drawings.sort {
            ascending ? $0.createdAt < $1.createdAt : $0.createdAt > $1.createdAt
        }
    }
}

// MARK: - 미리보기용 확장

extension DrawingStore {
    /// 미리보기용 샘플 저장소
    static var preview: DrawingStore {
        let store = DrawingStore()
        store.drawings = Drawing.samples
        return store
    }
}
