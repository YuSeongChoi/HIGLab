//
//  ModelLoader.swift
//  ARFurniture
//
//  USDZ 3D 모델 로딩 및 캐싱
//

import Foundation
import RealityKit
import Combine

/// 모델 로딩 에러
enum ModelLoadError: LocalizedError {
    case fileNotFound(String)
    case loadFailed(String)
    case invalidFormat
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "모델 파일을 찾을 수 없습니다: \(name)"
        case .loadFailed(let message):
            return "모델 로드 실패: \(message)"
        case .invalidFormat:
            return "지원하지 않는 파일 형식입니다"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}

/// USDZ 모델 로더
actor ModelLoader {
    
    // MARK: - Properties
    
    /// 모델 캐시 (이름 -> 엔티티)
    private var modelCache: [String: ModelEntity] = [:]
    
    /// 로딩 중인 모델 추적 (중복 로드 방지)
    private var loadingTasks: [String: Task<ModelEntity, Error>] = [:]
    
    // MARK: - Public Methods
    
    /// 모델 로드 (캐시 활용)
    /// - Parameter name: 모델 파일 이름 (확장자 제외)
    /// - Returns: 복제된 ModelEntity
    func loadModel(named name: String) async throws -> ModelEntity {
        // 캐시 확인
        if let cached = modelCache[name] {
            return cached.clone(recursive: true)
        }
        
        // 이미 로딩 중인지 확인
        if let existingTask = loadingTasks[name] {
            let entity = try await existingTask.value
            return entity.clone(recursive: true)
        }
        
        // 새로운 로딩 태스크 생성
        let task = Task<ModelEntity, Error> {
            let entity = try await loadFromBundle(name: name)
            return entity
        }
        
        loadingTasks[name] = task
        
        do {
            let entity = try await task.value
            modelCache[name] = entity
            loadingTasks.removeValue(forKey: name)
            return entity.clone(recursive: true)
        } catch {
            loadingTasks.removeValue(forKey: name)
            throw error
        }
    }
    
    /// URL에서 모델 로드
    /// - Parameter url: USDZ 파일 URL
    /// - Returns: ModelEntity
    func loadModel(from url: URL) async throws -> ModelEntity {
        let key = url.lastPathComponent
        
        // 캐시 확인
        if let cached = modelCache[key] {
            return cached.clone(recursive: true)
        }
        
        do {
            let entity = try await ModelEntity(contentsOf: url)
            
            // 그림자 설정
            entity.generateCollisionShapes(recursive: true)
            
            modelCache[key] = entity
            return entity.clone(recursive: true)
            
        } catch {
            throw ModelLoadError.loadFailed(error.localizedDescription)
        }
    }
    
    /// 캐시 비우기
    func clearCache() {
        modelCache.removeAll()
    }
    
    /// 특정 모델 캐시 제거
    func removeFromCache(named name: String) {
        modelCache.removeValue(forKey: name)
    }
    
    /// 모델 프리로드 (백그라운드에서 미리 로드)
    func preloadModels(_ names: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            for name in names {
                group.addTask {
                    do {
                        _ = try await self.loadModel(named: name)
                        print("✅ 프리로드 완료: \(name)")
                    } catch {
                        print("⚠️ 프리로드 실패: \(name) - \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 번들에서 모델 로드
    private func loadFromBundle(name: String) async throws -> ModelEntity {
        // USDZ 파일 찾기
        guard let url = Bundle.main.url(forResource: name, withExtension: "usdz") else {
            // 파일이 없으면 플레이스홀더 생성
            print("⚠️ 모델 파일 없음: \(name).usdz - 플레이스홀더 사용")
            return createPlaceholder(for: name)
        }
        
        do {
            let entity = try await ModelEntity(contentsOf: url)
            
            // 충돌 쉐이프 생성 (제스처 인식용)
            entity.generateCollisionShapes(recursive: true)
            
            // 그림자 생성
            if var model = entity.model {
                // 그림자 캐스팅 활성화는 material에서 설정
                entity.model = model
            }
            
            return entity
            
        } catch {
            throw ModelLoadError.loadFailed(error.localizedDescription)
        }
    }
    
    /// 플레이스홀더 모델 생성 (실제 모델이 없을 때)
    private func createPlaceholder(for name: String) -> ModelEntity {
        // 기본 박스 메시 생성
        let mesh = MeshResource.generateBox(size: 0.3, cornerRadius: 0.02)
        
        // 카테고리별 색상 지정
        var material = SimpleMaterial()
        
        if name.contains("chair") {
            material.color = .init(tint: .systemBrown)
        } else if name.contains("table") {
            material.color = .init(tint: .systemGray)
        } else if name.contains("sofa") {
            material.color = .init(tint: .systemBlue)
        } else if name.contains("lamp") {
            material.color = .init(tint: .systemYellow)
        } else if name.contains("plant") {
            material.color = .init(tint: .systemGreen)
        } else {
            material.color = .init(tint: .systemPurple)
        }
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.generateCollisionShapes(recursive: true)
        
        return entity
    }
}

// MARK: - Model Configuration

extension ModelLoader {
    
    /// 모델에 그림자 설정 적용
    static func configureShadow(for entity: ModelEntity) {
        // 섀도우는 RealityKit에서 자동으로 처리됨
        // 추가 설정이 필요한 경우 여기서 처리
    }
    
    /// 모델 스케일 조정
    static func adjustScale(for entity: ModelEntity, targetSize: SIMD3<Float>) {
        // 현재 바운딩 박스 크기 계산
        let bounds = entity.visualBounds(relativeTo: nil)
        let currentSize = bounds.extents
        
        // 스케일 비율 계산
        let scaleX = targetSize.x / currentSize.x
        let scaleY = targetSize.y / currentSize.y
        let scaleZ = targetSize.z / currentSize.z
        
        // 균일한 스케일링 (가장 작은 비율 사용)
        let uniformScale = min(scaleX, scaleY, scaleZ)
        entity.scale = SIMD3<Float>(repeating: uniformScale)
    }
}

// MARK: - Remote Model Loading

extension ModelLoader {
    
    /// 원격 URL에서 모델 다운로드 및 로드
    func downloadAndLoad(from remoteURL: URL) async throws -> ModelEntity {
        // 임시 파일 경로
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("usdz")
        
        do {
            // 다운로드
            let (data, response) = try await URLSession.shared.data(from: remoteURL)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw ModelLoadError.networkError(URLError(.badServerResponse))
            }
            
            // 파일 저장
            try data.write(to: tempURL)
            
            // 모델 로드
            let entity = try await loadModel(from: tempURL)
            
            // 임시 파일 삭제
            try? FileManager.default.removeItem(at: tempURL)
            
            return entity
            
        } catch let error as ModelLoadError {
            throw error
        } catch {
            throw ModelLoadError.networkError(error)
        }
    }
}
