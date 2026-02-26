# ARKit AI Reference

> Augmented reality app implementation guide. Read this document to generate ARKit code.

## Overview

ARKit is a framework that creates augmented reality experiences using the iOS device's camera and sensors.
It supports plane detection, image tracking, face tracking, object placement, and more.

## Required Imports

```swift
import ARKit
import RealityKit  // 3D rendering (recommended)
// or
import SceneKit    // Legacy 3D rendering
```

## Project Setup

```xml
<!-- Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Camera access is required for AR experiences.</string>

<!-- Required device capabilities (optional) -->
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arkit</string>
</array>
```

## Core Components

### 1. ARView (RealityKit)

```swift
import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Plane detection configuration
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
```

### 2. AR Session Configuration Types

```swift
// World tracking (most common)
let worldConfig = ARWorldTrackingConfiguration()
worldConfig.planeDetection = [.horizontal, .vertical]
worldConfig.sceneReconstruction = .mesh  // LiDAR devices only

// Face tracking (front camera)
let faceConfig = ARFaceTrackingConfiguration()

// Image tracking
let imageConfig = ARImageTrackingConfiguration()
imageConfig.trackingImages = referenceImages  // AR Resource Group

// Body tracking
let bodyConfig = ARBodyTrackingConfiguration()
```

### 3. 3D Object Placement

```swift
func placeObject(at position: SIMD3<Float>, in arView: ARView) {
    // Create anchor
    let anchor = AnchorEntity(world: position)
    
    // Load 3D model
    if let model = try? Entity.loadModel(named: "toy_robot") {
        model.scale = SIMD3<Float>(repeating: 0.01)
        anchor.addChild(model)
    }
    
    // Or basic shapes
    let box = ModelEntity(
        mesh: .generateBox(size: 0.1),
        materials: [SimpleMaterial(color: .blue, isMetallic: true)]
    )
    anchor.addChild(box)
    
    arView.scene.addAnchor(anchor)
}
```

## Complete Working Example

```swift
import SwiftUI
import RealityKit
import ARKit

// MARK: - AR View Container
struct ARFurnitureView: UIViewRepresentable {
    @Binding var selectedModel: String?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // AR configuration
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        arView.session.delegate = context.coordinator
        
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        context.coordinator.arView = arView
        
        // Add coaching overlay
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
            
            // Find plane with raycast
            if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                placeFurniture(modelName: modelName, at: result.worldTransform, in: arView)
            }
        }
        
        func placeFurniture(modelName: String, at transform: simd_float4x4, in arView: ARView) {
            let position = SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            let anchor = AnchorEntity(world: position)
            
            // Load model
            if let model = try? Entity.loadModel(named: modelName) {
                model.generateCollisionShapes(recursive: true)
                
                // Enable gestures (move, rotate)
                arView.installGestures([.translation, .rotation], for: model)
                
                anchor.addChild(model)
                arView.scene.addAnchor(anchor)
                
                // Deselect after placement
                DispatchQueue.main.async {
                    self.selectedModelBinding = nil
                }
            }
        }
        
        // Plane detection visualization
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
                
                // Furniture selection UI
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

## Advanced Patterns

### 1. Image Tracking

```swift
func setupImageTracking(for arView: ARView) {
    guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
    
    let config = ARImageTrackingConfiguration()
    config.trackingImages = referenceImages
    config.maximumNumberOfTrackedImages = 4
    
    arView.session.run(config)
}

// Handle image detection
func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for anchor in anchors {
        if let imageAnchor = anchor as? ARImageAnchor {
            let imageName = imageAnchor.referenceImage.name ?? "unknown"
            print("Detected image: \(imageName)")
            
            // Place content on image
            placeContent(on: imageAnchor)
        }
    }
}
```

### 2. Face Tracking

```swift
func setupFaceTracking(for arView: ARView) {
    guard ARFaceTrackingConfiguration.isSupported else { return }
    
    let config = ARFaceTrackingConfiguration()
    config.maximumNumberOfTrackedFaces = 1
    
    arView.session.run(config)
}

// Apply face filter
func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    for anchor in anchors {
        if let faceAnchor = anchor as? ARFaceAnchor {
            // Expression detection
            let smile = faceAnchor.blendShapes[.mouthSmileLeft]?.floatValue ?? 0
            let eyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            
            // Update face mesh
            updateFaceMesh(with: faceAnchor)
        }
    }
}
```

### 3. LiDAR Mesh Scanning (Pro Devices)

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

## Important Notes

1. **Device Support Check**
   ```swift
   // AR support check
   ARWorldTrackingConfiguration.isSupported
   
   // Face tracking (TrueDepth camera)
   ARFaceTrackingConfiguration.isSupported
   
   // LiDAR mesh
   ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
   ```

2. **Session Management**
   - Call `session.pause()` when app goes to background
   - On return: `session.run(config, options: .resetTracking)`

3. **Performance Optimization**
   - Use LOD (Level of Detail) for complex 3D models
   - Too many anchors causes performance degradation
   - Utilize `environmentTexturing = .automatic`

4. **User Experience**
   - Provide guidance with `ARCoachingOverlayView`
   - Show guidance message before plane detection
   - Warn when lighting is insufficient
