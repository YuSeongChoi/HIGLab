# RealityKit AI Reference

> 3D/AR 콘텐츠 렌더링 가이드. 이 문서를 읽고 RealityKit 코드를 생성할 수 있습니다.

## 개요

RealityKit은 Apple의 3D 렌더링 및 AR 엔진으로, 고품질 3D 콘텐츠를 쉽게 만들 수 있습니다.
ARKit과 통합되어 증강현실 앱 개발에 최적화되어 있으며, visionOS의 핵심 프레임워크입니다.

## 필수 Import

```swift
import RealityKit
import ARKit       // AR 기능 사용 시
import RealityKitContent  // visionOS 프로젝트
```

## 프로젝트 설정

```xml
<!-- Info.plist (AR 사용 시) -->
<key>NSCameraUsageDescription</key>
<string>AR 경험을 위해 카메라 접근이 필요합니다.</string>
```

## 핵심 구성요소

### 1. Entity (기본 단위)

```swift
// 모든 3D 객체의 기본 클래스
let entity = Entity()

// ModelEntity: 3D 모델
let box = ModelEntity(
    mesh: .generateBox(size: 0.1),
    materials: [SimpleMaterial(color: .blue, isMetallic: true)]
)

// AnchorEntity: 씬에 고정하는 앵커
let anchor = AnchorEntity(plane: .horizontal)
anchor.addChild(box)
```

### 2. 기본 도형 생성

```swift
// 박스
MeshResource.generateBox(size: 0.1)
MeshResource.generateBox(width: 0.2, height: 0.1, depth: 0.3)

// 구
MeshResource.generateSphere(radius: 0.05)

// 평면
MeshResource.generatePlane(width: 0.2, depth: 0.2)

// 텍스트
MeshResource.generateText("Hello", extrusionDepth: 0.01)
```

### 3. Material (재질)

```swift
// 단순 재질
let simple = SimpleMaterial(color: .red, isMetallic: false)

// PBR 재질
var pbr = PhysicallyBasedMaterial()
pbr.baseColor = .init(tint: .white, texture: .init(try! .load(named: "texture")))
pbr.roughness = .init(floatLiteral: 0.5)
pbr.metallic = .init(floatLiteral: 0.8)

// 반투명 재질
var transparent = SimpleMaterial()
transparent.color = .init(tint: .blue.withAlphaComponent(0.5))
transparent.blending = .transparent(opacity: 0.5)
```

## 전체 작동 예제

```swift
import SwiftUI
import RealityKit
import ARKit

// MARK: - AR View Container
struct RealityKitView: UIViewRepresentable {
    @Binding var placedObjects: [String]
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // AR 세션 설정
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        
        // 탭 제스처 추가
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tap)
        
        context.coordinator.arView = arView
        
        // 코칭 오버레이
        let coaching = ARCoachingOverlayView()
        coaching.session = arView.session
        coaching.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coaching.goal = .horizontalPlane
        arView.addSubview(coaching)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(placedObjects: $placedObjects)
    }
    
    class Coordinator: NSObject {
        var arView: ARView?
        @Binding var placedObjects: [String]
        
        init(placedObjects: Binding<[String]>) {
            _placedObjects = placedObjects
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            let location = gesture.location(in: arView)
            
            // 레이캐스트로 평면 찾기
            if let result = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            ).first {
                placeObject(at: result, in: arView)
            }
        }
        
        func placeObject(at raycastResult: ARRaycastResult, in arView: ARView) {
            let transform = raycastResult.worldTransform
            let position = SIMD3<Float>(
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z
            )
            
            // 앵커 생성
            let anchor = AnchorEntity(world: position)
            
            // 랜덤 도형 생성
            let shapes: [(MeshResource, UIColor)] = [
                (.generateBox(size: 0.05), .systemRed),
                (.generateSphere(radius: 0.03), .systemBlue),
                (.generateBox(width: 0.08, height: 0.02, depth: 0.04), .systemGreen)
            ]
            
            let (mesh, color) = shapes.randomElement()!
            
            let model = ModelEntity(
                mesh: mesh,
                materials: [SimpleMaterial(color: color, isMetallic: true)]
            )
            
            // 충돌 감지 활성화
            model.generateCollisionShapes(recursive: true)
            
            // 제스처 활성화 (이동, 회전, 크기 조절)
            arView.installGestures([.translation, .rotation, .scale], for: model)
            
            anchor.addChild(model)
            arView.scene.addAnchor(anchor)
            
            // 배치 기록
            placedObjects.append(UUID().uuidString)
        }
    }
}

// MARK: - Main View
struct ARObjectPlacerView: View {
    @State private var placedObjects: [String] = []
    
    var body: some View {
        ZStack {
            RealityKitView(placedObjects: $placedObjects)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack {
                    Text("배치된 객체: \(placedObjects.count)")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button("모두 삭제") {
                        placedObjects.removeAll()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .padding()
            }
        }
    }
}

#Preview {
    ARObjectPlacerView()
}
```

## 고급 패턴

### 1. 3D 모델 로드

```swift
// USDZ 파일 로드
func loadModel(named name: String) async -> ModelEntity? {
    do {
        let entity = try await ModelEntity(named: name)
        return entity
    } catch {
        print("모델 로드 실패: \(error)")
        return nil
    }
}

// 번들에서 로드
let model = try? Entity.loadModel(named: "robot")

// URL에서 로드
let url = URL(string: "https://example.com/model.usdz")!
let model = try? await Entity(contentsOf: url)
```

### 2. 애니메이션

```swift
// 이동 애니메이션
func animateEntity(_ entity: Entity) {
    var transform = entity.transform
    transform.translation = SIMD3<Float>(0, 0.5, 0)
    
    entity.move(
        to: transform,
        relativeTo: entity.parent,
        duration: 2.0,
        timingFunction: .easeInOut
    )
}

// 회전 애니메이션
func rotateEntity(_ entity: Entity) {
    let rotation = simd_quatf(angle: .pi * 2, axis: SIMD3<Float>(0, 1, 0))
    var transform = entity.transform
    transform.rotation = rotation
    
    entity.move(to: transform, relativeTo: entity.parent, duration: 3.0)
}

// 반복 애니메이션
func spinForever(_ entity: Entity) {
    guard let animation = entity.availableAnimations.first else { return }
    entity.playAnimation(animation.repeat())
}
```

### 3. 조명

```swift
// 포인트 라이트
let pointLight = PointLight()
pointLight.light.color = .white
pointLight.light.intensity = 10000
pointLight.light.attenuationRadius = 2.0

// 스팟 라이트
let spotlight = SpotLight()
spotlight.light.color = .yellow
spotlight.light.intensity = 50000
spotlight.light.innerAngleInDegrees = 30
spotlight.light.outerAngleInDegrees = 60

// 디렉셔널 라이트
let directional = DirectionalLight()
directional.light.color = .white
directional.light.intensity = 1000
directional.shadow = DirectionalLightComponent.Shadow()
```

### 4. 물리 시뮬레이션

```swift
func setupPhysics(for entity: ModelEntity) {
    // 충돌 형태 생성
    entity.generateCollisionShapes(recursive: true)
    
    // 물리 바디 추가 (동적)
    entity.physicsBody = PhysicsBodyComponent(
        massProperties: .init(mass: 1.0),
        material: .generate(friction: 0.5, restitution: 0.3),
        mode: .dynamic
    )
}

// 정적 바디 (움직이지 않음)
func makeStatic(_ entity: ModelEntity) {
    entity.generateCollisionShapes(recursive: true)
    entity.physicsBody = PhysicsBodyComponent(
        massProperties: .default,
        mode: .static
    )
}

// 힘 적용
func applyForce(to entity: ModelEntity) {
    entity.applyLinearImpulse(SIMD3<Float>(0, 5, 0), relativeTo: nil)
}
```

### 5. 오디오

```swift
// 공간 오디오 재생
func playSound(on entity: Entity) {
    guard let resource = try? AudioFileResource.load(named: "sound.mp3") else { return }
    
    let audioController = entity.prepareAudio(resource)
    audioController.play()
}

// 공간 오디오 컴포넌트
let spatialAudio = SpatialAudioComponent(directivity: .beam(focus: 0.5))
entity.components.set(spatialAudio)
```

### 6. visionOS ImmersiveSpace

```swift
// visionOS용 Immersive Space
import SwiftUI
import RealityKit

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            // 3D 콘텐츠 추가
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.1),
                materials: [SimpleMaterial(color: .blue, isMetallic: true)]
            )
            sphere.position = SIMD3<Float>(0, 1.5, -1)
            content.add(sphere)
            
            // 환경 조명
            guard let environment = try? await EnvironmentResource(named: "studio") else { return }
            content.add(environment)
        }
    }
}

// App에서 ImmersiveSpace 선언
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
```

## 주의사항

1. **성능 최적화**
   ```swift
   // 복잡한 메시는 LOD 사용
   // 불필요한 Entity 제거
   anchor.removeFromParent()
   
   // 텍스처 크기 최적화 (2048x2048 이하)
   ```

2. **메모리 관리**
   - Entity는 강한 참조 주의
   - 씬에서 제거 시 `removeFromParent()` 호출
   - 대용량 모델은 비동기 로드

3. **AR 세션 생명주기**
   ```swift
   // 백그라운드 진입 시
   arView.session.pause()
   
   // 포그라운드 복귀 시
   arView.session.run(config, options: .resetTracking)
   ```

4. **충돌 감지**
   - `generateCollisionShapes(recursive: true)` 필수
   - 제스처 사용 전 반드시 호출

5. **좌표계**
   - RealityKit은 미터 단위 사용
   - Y축이 위쪽 (오른손 좌표계)
