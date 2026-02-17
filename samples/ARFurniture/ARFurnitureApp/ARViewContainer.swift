//
//  ARViewContainer.swift
//  ARFurniture
//
//  ARView를 SwiftUI에서 사용하기 위한 래퍼
//

import SwiftUI
import RealityKit
import ARKit

/// ARView SwiftUI 래퍼
struct ARViewContainer: UIViewRepresentable {
    
    @EnvironmentObject var arManager: ARManager
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> ARView {
        // ARView 생성
        let arView = ARView(frame: .zero)
        
        // 디버그 옵션 (개발 중에만 활성화)
        #if DEBUG
        // arView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        #endif
        
        // 환경 설정
        configureEnvironment(for: arView)
        
        // AR 세션 설정
        arManager.setupSession(for: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 선택된 가구가 변경되면 미리보기 업데이트
        if let selectedItem = arManager.selectedFurniture,
           arManager.previewEntity == nil {
            arManager.showPreview(for: selectedItem)
        }
    }
    
    // MARK: - Environment Configuration
    
    /// ARView 환경 설정
    private func configureEnvironment(for arView: ARView) {
        // 환경 조명 설정
        arView.environment.lighting.intensityExponent = 1.0
        
        // 그림자 설정
        arView.environment.lighting.resource = nil
        
        // 배경 설정 (카메라 피드)
        arView.environment.background = .cameraFeed()
        
        // 렌더링 옵션
        arView.renderOptions = [
            .disableMotionBlur,
            .disableDepthOfField
        ]
    }
}

// MARK: - AR Coaching Overlay

/// ARKit 코칭 오버레이 (시스템 제공)
struct ARCoachingOverlayViewContainer: UIViewRepresentable {
    
    let arView: ARView
    
    func makeUIView(context: Context) -> ARCoachingOverlayView {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
        return coachingOverlay
    }
    
    func updateUIView(_ uiView: ARCoachingOverlayView, context: Context) {
        // 업데이트 필요 없음
    }
}

// MARK: - AR Debug View

/// AR 디버그 정보 뷰
struct ARDebugView: View {
    
    @EnvironmentObject var arManager: ARManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AR Debug Info")
                .font(.headline)
            
            Divider()
            
            debugRow("상태", value: arManager.sessionState.description)
            debugRow("감지된 평면", value: "\(arManager.detectedPlaneCount)")
            debugRow("배치된 가구", value: "\(arManager.placedFurnitures.count)")
            
            if let selected = arManager.selectedFurniture {
                debugRow("선택됨", value: selected.name)
            }
        }
        .font(.caption)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func debugRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

// MARK: - Focus Entity (배치 위치 표시)

/// 포커스 엔티티 (레이캐스트 위치 시각화)
class FocusEntity {
    
    private var entity: ModelEntity?
    private var anchor: AnchorEntity?
    
    /// 포커스 엔티티 생성
    init() {
        // 원형 평면 메시
        let mesh = MeshResource.generatePlane(width: 0.15, depth: 0.15, cornerRadius: 0.075)
        
        // 반투명 재질
        var material = SimpleMaterial()
        material.color = .init(tint: .systemBlue.withAlphaComponent(0.5))
        
        entity = ModelEntity(mesh: mesh, materials: [material])
    }
    
    /// ARView에 추가
    func addToScene(_ arView: ARView) {
        guard let entity = entity else { return }
        
        anchor = AnchorEntity()
        anchor?.addChild(entity)
        
        if let anchor = anchor {
            arView.scene.addAnchor(anchor)
        }
    }
    
    /// 위치 업데이트
    func update(with raycastResult: ARRaycastResult) {
        let transform = raycastResult.worldTransform
        
        anchor?.setTransformMatrix(transform, relativeTo: nil)
        
        // 살짝 위로 띄움
        entity?.position.y = 0.001
    }
    
    /// 숨기기
    func hide() {
        entity?.isEnabled = false
    }
    
    /// 보이기
    func show() {
        entity?.isEnabled = true
    }
    
    /// 제거
    func remove() {
        anchor?.removeFromParent()
        anchor = nil
        entity = nil
    }
}
