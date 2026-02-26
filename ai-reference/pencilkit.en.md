# PencilKit AI Reference

> Apple Pencil drawing implementation guide. You can generate PencilKit code by reading this document.

## Overview

PencilKit is a framework that provides natural drawing experiences with Apple Pencil and fingers.
It supports drawing, erasing, tool selection, and saving/loading drawings.

## Required Import

```swift
import PencilKit
import SwiftUI
```

## Core Components

### 1. PKCanvasView

```swift
let canvasView = PKCanvasView()
canvasView.drawingPolicy = .anyInput  // Finger + Pencil
canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
canvasView.backgroundColor = .white
```

### 2. PKToolPicker

```swift
let toolPicker = PKToolPicker()
toolPicker.setVisible(true, forFirstResponder: canvasView)
toolPicker.addObserver(canvasView)
canvasView.becomeFirstResponder()
```

### 3. PKDrawing

```swift
// Get drawing
let drawing = canvasView.drawing

// Set drawing
canvasView.drawing = PKDrawing()

// Convert to image
let image = drawing.image(from: drawing.bounds, scale: 2.0)

// Save as data
let data = drawing.dataRepresentation()

// Load from data
let loadedDrawing = try PKDrawing(data: data)
```

## Complete Working Example

```swift
import SwiftUI
import PencilKit

// MARK: - Canvas View Wrapper
struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var tool: PKTool
    let showToolPicker: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawing = drawing
        canvasView.tool = tool
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        canvasView.delegate = context.coordinator
        
        // Tool picker
        if showToolPicker {
            let toolPicker = PKToolPicker()
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
            context.coordinator.toolPicker = toolPicker
        }
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = tool
        
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        var toolPicker: PKToolPicker?
        
        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

// MARK: - Drawing Manager
@Observable
class DrawingManager {
    var drawing = PKDrawing()
    var tool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    var selectedColor: Color = .black
    var selectedWidth: CGFloat = 5
    var toolType: ToolType = .pen
    
    enum ToolType: String, CaseIterable {
        case pen = "Pen"
        case pencil = "Pencil"
        case marker = "Marker"
        case eraser = "Eraser"
    }
    
    var canUndo: Bool {
        !drawing.strokes.isEmpty
    }
    
    func updateTool() {
        let uiColor = UIColor(selectedColor)
        
        switch toolType {
        case .pen:
            tool = PKInkingTool(.pen, color: uiColor, width: selectedWidth)
        case .pencil:
            tool = PKInkingTool(.pencil, color: uiColor, width: selectedWidth)
        case .marker:
            tool = PKInkingTool(.marker, color: uiColor, width: selectedWidth * 2)
        case .eraser:
            tool = PKEraserTool(.bitmap)
        }
    }
    
    func clear() {
        drawing = PKDrawing()
    }
    
    func save() -> Data {
        drawing.dataRepresentation()
    }
    
    func load(from data: Data) {
        if let loadedDrawing = try? PKDrawing(data: data) {
            drawing = loadedDrawing
        }
    }
    
    func exportImage(scale: CGFloat = 2.0) -> UIImage {
        drawing.image(from: drawing.bounds, scale: scale)
    }
}

// MARK: - Views
struct SketchPadView: View {
    @State private var manager = DrawingManager()
    @State private var showToolPicker = false
    @State private var showingExport = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Canvas
                CanvasView(
                    drawing: $manager.drawing,
                    tool: $manager.tool,
                    showToolPicker: showToolPicker
                )
                
                // Custom toolbar
                if !showToolPicker {
                    customToolbar
                }
            }
            .navigationTitle("Sketch Pad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear", role: .destructive) {
                        manager.clear()
                    }
                    .disabled(!manager.canUndo)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle("System Tool Picker", isOn: $showToolPicker)
                        
                        Button {
                            showingExport = true
                        } label: {
                            Label("Save as Image", systemImage: "square.and.arrow.down")
                        }
                        
                        ShareLink(item: Image(uiImage: manager.exportImage()), preview: SharePreview("Sketch", image: Image(uiImage: manager.exportImage()))) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Saved", isPresented: $showingExport) {
                Button("OK") {}
            } message: {
                Text("Image has been saved to Photos")
            }
        }
    }
    
    var customToolbar: some View {
        VStack(spacing: 12) {
            // Tool selection
            HStack(spacing: 16) {
                ForEach(DrawingManager.ToolType.allCases, id: \.self) { type in
                    Button {
                        manager.toolType = type
                        manager.updateTool()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: iconFor(type))
                                .font(.title2)
                            Text(type.rawValue)
                                .font(.caption2)
                        }
                        .foregroundStyle(manager.toolType == type ? .blue : .primary)
                    }
                }
            }
            
            if manager.toolType != .eraser {
                // Color selection
                HStack(spacing: 12) {
                    ForEach([Color.black, .red, .orange, .yellow, .green, .blue, .purple], id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .overlay {
                                if manager.selectedColor == color {
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                        .padding(2)
                                }
                            }
                            .onTapGesture {
                                manager.selectedColor = color
                                manager.updateTool()
                            }
                    }
                    
                    ColorPicker("", selection: $manager.selectedColor)
                        .labelsHidden()
                        .onChange(of: manager.selectedColor) { _, _ in
                            manager.updateTool()
                        }
                }
                
                // Width selection
                HStack {
                    Text("Width")
                        .font(.caption)
                    Slider(value: $manager.selectedWidth, in: 1...20)
                        .onChange(of: manager.selectedWidth) { _, _ in
                            manager.updateTool()
                        }
                    Text("\(Int(manager.selectedWidth))")
                        .font(.caption)
                        .frame(width: 30)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
    }
    
    func iconFor(_ type: DrawingManager.ToolType) -> String {
        switch type {
        case .pen: return "pencil.tip"
        case .pencil: return "pencil"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        }
    }
}
```

## Advanced Patterns

### 1. Lasso Selection Tool

```swift
let lassoTool = PKLassoTool()
canvasView.tool = lassoTool

// Handle selected strokes
// Process in PKCanvasViewDelegate's canvasViewDidFinishRendering
```

### 2. Stroke Analysis

```swift
func analyzeStrokes(_ drawing: PKDrawing) {
    for stroke in drawing.strokes {
        let path = stroke.path
        let ink = stroke.ink
        
        print("Color: \(ink.color)")
        print("Tool: \(ink.inkType)")
        print("Point count: \(path.count)")
        
        // Each point info
        for i in 0..<path.count {
            let point = path[i]
            print("Location: \(point.location), Pressure: \(point.force)")
        }
    }
}
```

### 3. Transparent Background Image

```swift
func exportWithTransparentBackground(drawing: PKDrawing) -> UIImage {
    let bounds = drawing.bounds
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 2.0)
    
    // Transparent background
    UIColor.clear.setFill()
    UIRectFill(CGRect(origin: .zero, size: bounds.size))
    
    // Render drawing
    let image = drawing.image(from: bounds, scale: 2.0)
    image.draw(at: .zero)
    
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return result ?? UIImage()
}
```

### 4. Merge Drawings

```swift
func mergeDrawings(_ drawings: [PKDrawing]) -> PKDrawing {
    var allStrokes: [PKStroke] = []
    
    for drawing in drawings {
        allStrokes.append(contentsOf: drawing.strokes)
    }
    
    return PKDrawing(strokes: allStrokes)
}
```

## Notes

1. **Apple Pencil Optimization**
   - `drawingPolicy = .pencilOnly`: Pencil only drawing
   - `drawingPolicy = .anyInput`: Finger also draws
   - `drawingPolicy = .default`: Follow system settings

2. **Memory Management**
   - Complex drawings increase memory usage
   - Adjust scale when exporting images

3. **Data Storage**
   ```swift
   // Save
   let data = drawing.dataRepresentation()
   try data.write(to: fileURL)
   
   // Load
   let data = try Data(contentsOf: fileURL)
   let drawing = try PKDrawing(data: data)
   ```

4. **Simulator Testing**
   - Can test with mouse/trackpad
   - Pressure sensitivity only on real devices
