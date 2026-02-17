//
//  ARManager.swift
//  ARFurniture
//
//  AR 세션 관리 및 상태 관리
//

import Foundation
import ARKit
import RealityKit
import Combine

/// AR 세션 상태
enum ARSessionState: Equatable {
    case notStarted           // 시작 전
    case initializing         // 초기화 중
    case running              // 실행 중
    case limited(reason: ARCamera.TrackingState.Reason)  // 제한적 추적
    case failed(String)       // 실패
    case paused               // 일시정지
    
    var description: String {
        switch self {
        case .notStarted:
            return "카메라를 시작하세요"
        case .initializing:
            return "AR 환경을 분석 중..."
        case .running:
            return "평면을 탭하여 가구를 배치하세요"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "기기를 천천히 움직여주세요"
            case .insufficientFeatures:
                return "더 많은 특징점이 필요합니다"
            case .initializing:
                return "AR 초기화 중..."
            case .relocalizing:
                return "위치 재탐색 중..."
            @unknown default:
                return "추적 제한됨"
            }
        case .failed(let message):
            return "오류: \(message)"
        case .paused:
            return "일시정지됨"
        }
    }
}

/// AR 세션 관리자
@MainActor
final class ARManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// 현재 세션 상태
    @Published private(set) var sessionState: ARSessionState = .notStarted
    
    /// 감지된 수평 평면 개수
    @Published private(set) var detectedPlaneCount: Int = 0
    
    /// 배치된 가구 목록
    @Published private(set) var placedFurnitures: [PlacedFurniture] = []
    
    /// 현재 선택된 가구 (배치 대기 중)
    @Published var selectedFurniture: FurnitureItem?
    
    /// 미리보기 엔티티 (배치 전 위치 미리보기)
    @Published private(set) var previewEntity: ModelEntity?
    
    /// 코칭 오버레이 표시 여부
    @Published var showCoaching: Bool = true
    
    // MARK: - Properties
    
    /// ARView 참조
    weak var arView: ARView?
    
    /// 앵커 저장소 (평면 추적용)
    private var planeAnchors: [UUID: AnchorEntity] = [:]
    
    /// 모델 로더
    private let modelLoader = ModelLoader()
    
    /// 구독 취소 토큰
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    // MARK: - Session Management
    
    /// AR 세션 설정 및 시작
    func setupSession(for arView: ARView) {
        self.arView = arView
        
        // AR 설정 구성
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]  // 수평면 감지
        configuration.environmentTexturing = .automatic  // 환경 텍스처링
        
        // 라이트 추정 활성화
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        // 세션 델리게이트 설정
        arView.session.delegate = self
        
        // 세션 시작
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        sessionState = .initializing
        
        // 제스처 설정
        setupGestures()
    }
    
    /// 세션 일시정지
    func pauseSession() {
        arView?.session.pause()
        sessionState = .paused
    }
    
    /// 세션 재개
    func resumeSession() {
        guard let arView = arView else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
        sessionState = .running
    }
    
    /// 세션 리셋 (모든 앵커 제거)
    func resetSession() {
        // 배치된 가구 제거
        for furniture in placedFurnitures {
            furniture.entity?.removeFromParent()
        }
        placedFurnitures.removeAll()
        planeAnchors.removeAll()
        
        // 미리보기 제거
        removePreview()
        
        // 세션 리셋
        guard let arView = arView else { return }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        detectedPlaneCount = 0
        sessionState = .initializing
    }
    
    // MARK: - Gesture Setup
    
    /// 제스처 인식기 설정
    private func setupGestures() {
        guard let arView = arView else { return }
        
        // 탭 제스처 (배치)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // 팬 제스처 (이동)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
        
        // 회전 제스처
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        arView.addGestureRecognizer(rotationGesture)
        
        // 핀치 제스처 (크기 조절)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
    }
    
    // MARK: - Gesture Handlers
    
    /// 탭 제스처 처리 - 가구 배치
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let arView = arView,
              let selectedFurniture = selectedFurniture else { return }
        
        let location = gesture.location(in: arView)
        
        // 레이캐스트로 평면 위치 찾기
        let results = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal)
        
        guard let firstResult = results.first else {
            print("평면을 찾을 수 없습니다")
            return
        }
        
        // 가구 배치
        Task {
            await placeFurniture(selectedFurniture, at: firstResult)
        }
    }
    
    /// 팬 제스처 처리 - 가구 이동
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let arView = arView else { return }
        
        let location = gesture.location(in: arView)
        
        switch gesture.state {
        case .changed:
            // 선택된 가구가 있으면 미리보기 이동
            if selectedFurniture != nil {
                let results = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal)
                if let result = results.first {
                    updatePreviewPosition(with: result)
                }
            }
        default:
            break
        }
    }
    
    /// 회전 제스처 처리
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let previewEntity = previewEntity else { return }
        
        if gesture.state == .changed {
            let rotation = Float(gesture.rotation)
            previewEntity.transform.rotation *= simd_quatf(angle: -rotation, axis: [0, 1, 0])
            gesture.rotation = 0
        }
    }
    
    /// 핀치 제스처 처리 - 크기 조절
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let previewEntity = previewEntity else { return }
        
        if gesture.state == .changed {
            let scale = Float(gesture.scale)
            let currentScale = previewEntity.scale.x
            let newScale = max(0.5, min(2.0, currentScale * scale))  // 0.5x ~ 2.0x 제한
            previewEntity.scale = SIMD3<Float>(repeating: newScale)
            gesture.scale = 1.0
        }
    }
    
    // MARK: - Furniture Placement
    
    /// 가구 배치
    func placeFurniture(_ item: FurnitureItem, at raycastResult: ARRaycastResult) async {
        guard let arView = arView else { return }
        
        do {
            // 모델 로드
            let entity = try await modelLoader.loadModel(named: item.modelName)
            
            // 앵커 생성
            let anchor = AnchorEntity(raycastResult: raycastResult)
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)
            
            // 배치 정보 저장
            let placed = PlacedFurniture(
                item: item,
                entity: entity,
                transform: entity.transform
            )
            placedFurnitures.append(placed)
            
            // 미리보기 제거 및 선택 해제
            removePreview()
            selectedFurniture = nil
            
            print("✅ \(item.name) 배치 완료")
            
        } catch {
            print("❌ 모델 로드 실패: \(error.localizedDescription)")
        }
    }
    
    /// 배치된 가구 삭제
    func removeFurniture(_ furniture: PlacedFurniture) {
        furniture.entity?.removeFromParent()
        placedFurnitures.removeAll { $0.id == furniture.id }
    }
    
    /// 모든 가구 삭제
    func removeAllFurniture() {
        for furniture in placedFurnitures {
            furniture.entity?.removeFromParent()
        }
        placedFurnitures.removeAll()
    }
    
    // MARK: - Preview
    
    /// 미리보기 엔티티 표시
    func showPreview(for item: FurnitureItem) {
        Task {
            do {
                let entity = try await modelLoader.loadModel(named: item.modelName)
                
                // 반투명 처리
                entity.model?.materials = entity.model?.materials.map { material in
                    var mat = SimpleMaterial()
                    mat.color = .init(tint: .white.withAlphaComponent(0.6))
                    return mat
                } ?? []
                
                self.previewEntity = entity
                
            } catch {
                print("미리보기 로드 실패: \(error)")
            }
        }
    }
    
    /// 미리보기 위치 업데이트
    func updatePreviewPosition(with raycastResult: ARRaycastResult) {
        guard let previewEntity = previewEntity,
              let arView = arView else { return }
        
        // 앵커가 없으면 생성
        if previewEntity.anchor == nil {
            let anchor = AnchorEntity(raycastResult: raycastResult)
            anchor.addChild(previewEntity)
            arView.scene.addAnchor(anchor)
        } else {
            // 위치만 업데이트
            previewEntity.setPosition(
                SIMD3<Float>(
                    raycastResult.worldTransform.columns.3.x,
                    raycastResult.worldTransform.columns.3.y,
                    raycastResult.worldTransform.columns.3.z
                ),
                relativeTo: nil
            )
        }
    }
    
    /// 미리보기 제거
    func removePreview() {
        previewEntity?.removeFromParent()
        previewEntity = nil
    }
}

// MARK: - ARSessionDelegate

extension ARManager: ARSessionDelegate {
    
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in
            // 추적 상태 업데이트
            switch frame.camera.trackingState {
            case .normal:
                if sessionState != .running {
                    sessionState = .running
                }
            case .limited(let reason):
                sessionState = .limited(reason: reason)
            case .notAvailable:
                sessionState = .failed("추적 불가")
            }
        }
    }
    
    nonisolated func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        Task { @MainActor in
            // 평면 앵커 카운트
            let planeAnchors = anchors.compactMap { $0 as? ARPlaneAnchor }
            detectedPlaneCount += planeAnchors.count
            
            if !planeAnchors.isEmpty {
                showCoaching = false
            }
        }
    }
    
    nonisolated func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        Task { @MainActor in
            let planeAnchors = anchors.compactMap { $0 as? ARPlaneAnchor }
            detectedPlaneCount = max(0, detectedPlaneCount - planeAnchors.count)
        }
    }
    
    nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
        Task { @MainActor in
            sessionState = .failed(error.localizedDescription)
        }
    }
    
    nonisolated func sessionWasInterrupted(_ session: ARSession) {
        Task { @MainActor in
            sessionState = .paused
        }
    }
    
    nonisolated func sessionInterruptionEnded(_ session: ARSession) {
        Task { @MainActor in
            resumeSession()
        }
    }
}
