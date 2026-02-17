# ARKit AI Reference

> 증강현실 앱 구현 가이드. 이 문서를 읽고 ARKit 코드를 생성할 수 있습니다.

## 개요

ARKit은 iOS 기기의 카메라와 센서를 활용해 증강현실 경험을 만드는 프레임워크입니다.
평면 감지, 이미지 추적, 얼굴 추적, 물체 배치 등을 지원합니다.

## 필수 Import

```swift
import ARKit
import RealityKit  // 3D 렌더링 (권장)
// 또는
import SceneKit    // 레거시 3D 렌더링
```

## 프로젝트 설정

```xml
<!-- Info.plist -->
<key>NSCameraUsageDescription</key>
<string>AR 경험을 위해 카메라 접근이 필요합니다.</string>

<!-- Required device capabilities (선택) -->
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arkit</string>
</array>
```

## 핵심 구성요소

### 1. ARView (RealityKit)

```swift
import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 평면 감지 설정
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
```

### 2. AR 세션 설정 종류

```swift
// 월드 트래킹 (가장 일반적)
let worldConfig = ARWorldTrackingConfiguration()
worldConfig.planeDetection = [.horizontal, .vertical]
worldConfig.sceneReconstruction = .mesh  // LiDAR 기기만

// 얼굴 트래킹 (전면 카메라)
let faceConfig = ARFaceTrackingConfiguration()

// 이미지 트래킹
let imageConfig = ARImageTrackingConfiguration()
imageConfig.trackingImages = referenceImages  // AR Resource Group

// 바디 트래킹
let bodyConfig = ARBodyTrackingConfiguration()
```

### 3. 3D 객체 배치

```swift
func placeObject(at position: SIMD3<Float>, in arView: ARView) {
    // 앵커 생성
    let anchor = AnchorEntity(world: position)
    
    // 3D 모델 로드
    if let model = try? Entity.loadModel(named: "toy_robot") {
        model.scale = SIMD3<Float>(repeating: 0.01)
        anchor.addChild(model)
    }
    
    // 또는 기본 도형
    let box = ModelEntity(
        mesh: .generateBox(size: 0.1),
        materials: [SimpleMaterial(color: .blue, isMetallic: true)]
    )
    anchor.addChild(box)
    
    arView.scene.addAnchor(anchor)
}
```

## 전체 작동 예제

```swift
import SwiftUI
import RealityKit
import ARKit

// MARK: - AR View Container
struct ARFurnitureView: UIViewRepresentable {
    @Binding var selectedModel: String?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // AR 설정
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        arView.session.delegate = context.coordinator
        
        // 탭 제스처
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        context.coordinator.arView = arView
        
        // 코칭 오버레이 추가
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.selectedModel = selectedModel
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedModel: $selectedModel)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var arView: ARView?
        var selectedModel: String?
        @Binding var selectedModelBinding: String?
        
        init(selectedModel: Binding<String?>) {
            _selectedModelBinding = selectedModel
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView,
                  let modelName = selectedModel else { return }
            
            let location = gesture.location(in: arView)
            
            // 레이캐스트로 평면 찾기
            if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                placeFurniture(modelName: modelName, at: result.worldTransform, in: arView)
            }
        }
        
        func placeFurniture(modelName: String, at transform: simd_float4x4, in arView: ARView) {
            let position = SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            let anchor = AnchorEntity(world: position)
            
            // 모델 로드
            if let model = try? Entity.loadModel(named: modelName) {
                model.generateCollisionShapes(recursive: true)
                
                // 제스처 활성화 (이동, 회전)
                arView.installGestures([.translation, .rotation], for: model)
                
                anchor.addChild(model)
                arView.scene.addAnchor(anchor)
                
                // 배치 후 선택 해제
                DispatchQueue.main.async {
                    self.selectedModelBinding = nil
                }
            }
        }
        
        // 평면 감지 시각화
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let planeAnchor = anchor as? ARPlaneAnchor {
                    visualizePlane(planeAnchor)
                }
            }
        }
        
        private func visualizePlane(_ anchor: ARPlaneAnchor) {
            guard let arView = arView else { return }
            
            let extent = anchor.planeExtent
            let plane = ModelEntity(
                mesh: .generatePlane(width: extent.width, depth: extent.height),
                materials: [SimpleMaterial(color: .blue.withAlphaComponent(0.3), isMetallic: false)]
            )
            
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(plane)
            arView.scene.addAnchor(anchorEntity)
        }
    }
}

// MARK: - Main View
struct ARFurnitureApp: View {
    @State private var selectedModel: String?
    
    let models = ["chair", "table", "lamp", "plant"]
    
    var body: some View {
        ZStack {
            ARFurnitureView(selectedModel: $selectedModel)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // 가구 선택 UI
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(models, id: \.self) { model in
                            Button {
                                selectedModel = model
                            } label: {
                                VStack {
                                    Image(systemName: iconFor(model))
                                        .font(.title)
                                    Text(model)
                                        .font(.caption)
                                }
                                .padding()
                                .background(selectedModel == model ? Color.blue : Color.white)
                                .foregroundStyle(selectedModel == model ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding()
                }
                .background(.ultraThinMaterial)
            }
        }
    }
    
    func iconFor(_ model: String) -> String {
        switch model {
        case "chair": return "chair.fill"
        case "table": return "table.furniture.fill"
        case "lamp": return "lamp.desk.fill"
        case "plant": return "leaf.fill"
        default: return "cube.fill"
        }
    }
}
```

## 고급 패턴

### 1. 이미지 추적

```swift
func setupImageTracking(for arView: ARView) {
    guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
    
    let config = ARImageTrackingConfiguration()
    config.trackingImages = referenceImages
    config.maximumNumberOfTrackedImages = 4
    
    arView.session.run(config)
}

// 이미지 감지 시 처리
func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for anchor in anchors {
        if let imageAnchor = anchor as? ARImageAnchor {
            let imageName = imageAnchor.referenceImage.name ?? "unknown"
            print("감지된 이미지: \(imageName)")
            
            // 이미지 위에 콘텐츠 배치
            placeContent(on: imageAnchor)
        }
    }
}
```

### 2. 얼굴 추적

```swift
func setupFaceTracking(for arView: ARView) {
    guard ARFaceTrackingConfiguration.isSupported else { return }
    
    let config = ARFaceTrackingConfiguration()
    config.maximumNumberOfTrackedFaces = 1
    
    arView.session.run(config)
}

// 얼굴 필터 적용
func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    for anchor in anchors {
        if let faceAnchor = anchor as? ARFaceAnchor {
            // 표정 감지
            let smile = faceAnchor.blendShapes[.mouthSmileLeft]?.floatValue ?? 0
            let eyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            
            // 얼굴 메시 업데이트
            updateFaceMesh(with: faceAnchor)
        }
    }
}
```

### 3. LiDAR 메시 스캔 (Pro 기기)

```swift
func setupMeshScanning(for arView: ARView) {
    guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) else { return }
    
    let config = ARWorldTrackingConfiguration()
    config.sceneReconstruction = .meshWithClassification
    config.planeDetection = [.horizontal, .vertical]
    
    arView.session.run(config)
    arView.debugOptions = [.showSceneUnderstanding]
}
```

## 주의사항

1. **기기 지원 확인**
   ```swift
   // AR 지원 확인
   ARWorldTrackingConfiguration.isSupported
   
   // 얼굴 추적 (TrueDepth 카메라)
   ARFaceTrackingConfiguration.isSupported
   
   // LiDAR 메시
   ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
   ```

2. **세션 관리**
   - 앱이 백그라운드 갈 때 `session.pause()`
   - 복귀 시 `session.run(config, options: .resetTracking)`

3. **성능 최적화**
   - 복잡한 3D 모델은 LOD(Level of Detail) 사용
   - 앵커가 너무 많으면 성능 저하
   - `environmentTexturing = .automatic` 활용

4. **사용자 경험**
   - `ARCoachingOverlayView`로 가이드 제공
   - 평면 감지 전 안내 메시지
   - 조명 부족 시 경고
