# RealityKit AI Reference

> 3D/AR content rendering guide. You can generate RealityKit code by reading this document.

## Overview

RealityKit is Apple's 3D rendering and AR engine that makes it easy to create high-quality 3D content.
It integrates with ARKit for augmented reality app development and is the core framework for visionOS.

## Required Import

```swift
import RealityKit
import ARKit       // For AR features
import RealityKitContent  // visionOS projects
```

## Project Setup

```xml
<!-- Info.plist (for AR) -->
<key>NSCameraUsageDescription</key>
<string>Camera access is required for AR experience.</string>
```

## Core Components

### 1. Entity (Basic Unit)

```swift
// Base class for all 3D objects
let entity = Entity()

// ModelEntity: 3D model
let box = ModelEntity(
    mesh: .generateBox(size: 0.1),
    materials: [SimpleMaterial(color: .blue, isMetallic: true)]
)

// AnchorEntity: Anchor to fix to scene
let anchor = AnchorEntity(plane: .horizontal)
anchor.addChild(box)
```

### 2. Basic Shape Generation

```swift
// Box
MeshResource.generateBox(size: 0.1)
MeshResource.generateBox(width: 0.2, height: 0.1, depth: 0.3)

// Sphere
MeshResource.generateSphere(radius: 0.05)

// Plane
MeshResource.generatePlane(width: 0.2, depth: 0.2)

// Text
MeshResource.generateText("Hello", extrusionDepth: 0.01)
```

### 3. Material

```swift
// Simple material
let simple = SimpleMaterial(color: .red, isMetallic: false)

// PBR material
var pbr = PhysicallyBasedMaterial()
pbr.baseColor = .init(tint: .white, texture: .init(try! .load(named: "texture")))
pbr.roughness = .init(floatLiteral: 0.5)
pbr.metallic = .init(floatLiteral: 0.8)

// Translucent material
var transparent = SimpleMaterial()
transparent.color = .init(tint: .blue.withAlphaComponent(0.5))
transparent.blending = .transparent(opacity: 0.5)
```

## Complete Working Example

```swift
import SwiftUI
import RealityKit
import ARKit

// MARK: - AR View Container
struct RealityKitView: UIViewRepresentable {
    @Binding var placedObjects: [String]
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // AR session setup
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        
        // Add tap gesture
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tap)
        
        context.coordinator.arView = arView
        
        // Coaching overlay
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
            
            // Find plane with raycast
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
            
            // Create anchor
            let anchor = AnchorEntity(world: position)
            
            // Create random shape
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
            
            // Enable collision detection
            model.generateCollisionShapes(recursive: true)
            
            // Enable gestures (move, rotate, scale)
            arView.installGestures([.translation, .rotation, .scale], for: model)
            
            anchor.addChild(model)
            arView.scene.addAnchor(anchor)
            
            // Record placement
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
                    Text("Placed Objects: \(placedObjects.count)")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button("Remove All") {
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

## Advanced Patterns

### 1. Loading 3D Models

```swift
// Load USDZ file
func loadModel(named name: String) async -> ModelEntity? {
    do {
        let entity = try await ModelEntity(named: name)
        return entity
    } catch {
        print("Failed to load model: \(error)")
        return nil
    }
}

// Load from bundle
let model = try? Entity.loadModel(named: "robot")

// Load from URL
let url = URL(string: "https://example.com/model.usdz")!
let model = try? await Entity(contentsOf: url)
```

### 2. Animation

```swift
// Move animation
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

// Rotation animation
func rotateEntity(_ entity: Entity) {
    let rotation = simd_quatf(angle: .pi * 2, axis: SIMD3<Float>(0, 1, 0))
    var transform = entity.transform
    transform.rotation = rotation
    
    entity.move(to: transform, relativeTo: entity.parent, duration: 3.0)
}

// Repeat animation
func spinForever(_ entity: Entity) {
    guard let animation = entity.availableAnimations.first else { return }
    entity.playAnimation(animation.repeat())
}
```

### 3. Lighting

```swift
// Point light
let pointLight = PointLight()
pointLight.light.color = .white
pointLight.light.intensity = 10000
pointLight.light.attenuationRadius = 2.0

// Spotlight
let spotlight = SpotLight()
spotlight.light.color = .yellow
spotlight.light.intensity = 50000
spotlight.light.innerAngleInDegrees = 30
spotlight.light.outerAngleInDegrees = 60

// Directional light
let directional = DirectionalLight()
directional.light.color = .white
directional.light.intensity = 1000
directional.shadow = DirectionalLightComponent.Shadow()
```

### 4. Physics Simulation

```swift
func setupPhysics(for entity: ModelEntity) {
    // Generate collision shape
    entity.generateCollisionShapes(recursive: true)
    
    // Add physics body (dynamic)
    entity.physicsBody = PhysicsBodyComponent(
        massProperties: .init(mass: 1.0),
        material: .generate(friction: 0.5, restitution: 0.3),
        mode: .dynamic
    )
}

// Static body (does not move)
func makeStatic(_ entity: ModelEntity) {
    entity.generateCollisionShapes(recursive: true)
    entity.physicsBody = PhysicsBodyComponent(
        massProperties: .default,
        mode: .static
    )
}

// Apply force
func applyForce(to entity: ModelEntity) {
    entity.applyLinearImpulse(SIMD3<Float>(0, 5, 0), relativeTo: nil)
}
```

### 5. Audio

```swift
// Play spatial audio
func playSound(on entity: Entity) {
    guard let resource = try? AudioFileResource.load(named: "sound.mp3") else { return }
    
    let audioController = entity.prepareAudio(resource)
    audioController.play()
}

// Spatial audio component
let spatialAudio = SpatialAudioComponent(directivity: .beam(focus: 0.5))
entity.components.set(spatialAudio)
```

### 6. visionOS ImmersiveSpace

```swift
// Immersive Space for visionOS
import SwiftUI
import RealityKit

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            // Add 3D content
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.1),
                materials: [SimpleMaterial(color: .blue, isMetallic: true)]
            )
            sphere.position = SIMD3<Float>(0, 1.5, -1)
            content.add(sphere)
            
            // Environment lighting
            guard let environment = try? await EnvironmentResource(named: "studio") else { return }
            content.add(environment)
        }
    }
}

// Declare ImmersiveSpace in App
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

## Notes

1. **Performance Optimization**
   ```swift
   // Use LOD for complex meshes
   // Remove unnecessary entities
   anchor.removeFromParent()
   
   // Optimize texture size (2048x2048 or smaller)
   ```

2. **Memory Management**
   - Be careful with strong references to Entities
   - Call `removeFromParent()` when removing from scene
   - Load large models asynchronously

3. **AR Session Lifecycle**
   ```swift
   // When entering background
   arView.session.pause()
   
   // When returning to foreground
   arView.session.run(config, options: .resetTracking)
   ```

4. **Collision Detection**
   - `generateCollisionShapes(recursive: true)` is required
   - Must be called before using gestures

5. **Coordinate System**
   - RealityKit uses meters
   - Y-axis is up (right-handed coordinate system)
