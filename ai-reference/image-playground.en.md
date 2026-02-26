# Image Playground AI Reference

> Apple Intelligence image generation guide. Read this document to generate Image Playground code.

## Overview

Image Playground is Apple Intelligence's image generation framework.
It generates images in three styles (animation, illustration, sketch) based on text prompts, concepts, and people.
Requires iOS 18.1+ and Apple Silicon devices.

## Required Import

```swift
import ImagePlayground
```

## Project Setup

- Requires **iOS 18.1+**
- Only supports **Apple Silicon** devices (A17 Pro or later)
- No additional permissions required

## Core Components

### 1. ImagePlaygroundSheet (SwiftUI)

```swift
import SwiftUI
import ImagePlayground

struct ContentView: View {
    @State private var showPlayground = false
    @State private var generatedImage: URL?
    
    var body: some View {
        VStack {
            if let imageURL = generatedImage {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            }
            
            Button("Generate Image") {
                showPlayground = true
            }
        }
        .imagePlaygroundSheet(
            isPresented: $showPlayground,
            concept: "A cat eating pizza in space"
        ) { url in
            generatedImage = url
        }
    }
}
```

### 2. Concept (Input Concepts)

```swift
// Text concept
ImagePlaygroundConcept.text("Sunset on the beach")

// Extracted concept (extracts key concepts from text)
ImagePlaygroundConcept.extracted(from: "A dog is playing in the park", title: "Dog")

// Person (PersonsNameComponents)
ImagePlaygroundConcept.person(url: photoURL, nameComponents: personName)
```

### 3. Style (Image Styles)

```swift
// Animation (3D-like)
ImagePlaygroundStyle.animation

// Illustration (flat design)
ImagePlaygroundStyle.illustration

// Sketch (hand-drawn feel)
ImagePlaygroundStyle.sketch
```

## Complete Working Example

```swift
import SwiftUI
import ImagePlayground

// MARK: - Main View
struct ImagePlaygroundView: View {
    @State private var showPlayground = false
    @State private var generatedImages: [URL] = []
    @State private var prompt = ""
    @State private var selectedStyle: ImagePlaygroundStyle = .animation
    @State private var isSupported = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Check support
                if !isSupported {
                    ContentUnavailableView(
                        "Unsupported Device",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Image Playground is only available on Apple Silicon devices with A17 Pro or later.")
                    )
                } else {
                    // Generated images grid
                    if generatedImages.isEmpty {
                        ContentUnavailableView(
                            "No Generated Images",
                            systemImage: "photo.badge.plus",
                            description: Text("Tap the button below to generate images")
                        )
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                                ForEach(generatedImages, id: \.self) { url in
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.quaternary)
                                            .frame(height: 150)
                                            .overlay { ProgressView() }
                                    }
                                    .contextMenu {
                                        Button {
                                            copyImage(from: url)
                                        } label: {
                                            Label("Copy", systemImage: "doc.on.doc")
                                        }
                                        
                                        ShareLink(item: url)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    Spacer()
                    
                    // Prompt input
                    VStack(spacing: 12) {
                        TextField("What would you like to create?", text: $prompt)
                            .textFieldStyle(.roundedBorder)
                        
                        // Style selection
                        Picker("Style", selection: $selectedStyle) {
                            Text("Animation").tag(ImagePlaygroundStyle.animation)
                            Text("Illustration").tag(ImagePlaygroundStyle.illustration)
                            Text("Sketch").tag(ImagePlaygroundStyle.sketch)
                        }
                        .pickerStyle(.segmented)
                        
                        // Generate button
                        Button {
                            showPlayground = true
                        } label: {
                            Label("Generate Image", systemImage: "wand.and.stars")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(prompt.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("Image Playground")
            .toolbar {
                if !generatedImages.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Delete All") {
                            generatedImages.removeAll()
                        }
                    }
                }
            }
            .imagePlaygroundSheet(
                isPresented: $showPlayground,
                concepts: [.text(prompt)],
                style: selectedStyle,
                title: "Generate Image"
            ) { url in
                generatedImages.append(url)
                prompt = ""
            }
            .task {
                // Check support
                isSupported = ImagePlaygroundViewController.isAvailable
            }
        }
    }
    
    func copyImage(from url: URL) {
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            UIPasteboard.general.image = image
        }
    }
}

#Preview {
    ImagePlaygroundView()
}
```

## Advanced Patterns

### 1. Combining Multiple Concepts

```swift
struct MultiConceptView: View {
    @State private var showPlayground = false
    @State private var result: URL?
    
    var body: some View {
        Button("Generate") {
            showPlayground = true
        }
        .imagePlaygroundSheet(
            isPresented: $showPlayground,
            concepts: [
                .text("Fantasy castle"),
                .text("Snow-covered mountains"),
                .extracted(from: "A wizard is casting a spell", title: "Wizard")
            ],
            style: .illustration
        ) { url in
            result = url
        }
    }
}
```

### 2. UIKit Integration (ImagePlaygroundViewController)

```swift
import UIKit
import ImagePlayground

class ImagePlaygroundHostVC: UIViewController {
    
    func presentPlayground() {
        guard ImagePlaygroundViewController.isAvailable else {
            showUnsupportedAlert()
            return
        }
        
        let playgroundVC = ImagePlaygroundViewController()
        playgroundVC.delegate = self
        
        // Set initial concepts
        playgroundVC.concepts = [
            .text("Cute robot")
        ]
        
        // Set style
        playgroundVC.style = .animation
        
        present(playgroundVC, animated: true)
    }
    
    func showUnsupportedAlert() {
        let alert = UIAlertController(
            title: "Not Supported",
            message: "Image Playground is not available on this device.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ImagePlaygroundHostVC: ImagePlaygroundViewControllerDelegate {
    func imagePlaygroundViewController(
        _ controller: ImagePlaygroundViewController,
        didCreateImageAt imageURL: URL
    ) {
        // Process generated image
        if let data = try? Data(contentsOf: imageURL),
           let image = UIImage(data: data) {
            // Use image
            handleGeneratedImage(image)
        }
        controller.dismiss(animated: true)
    }
    
    func imagePlaygroundViewControllerDidCancel(
        _ controller: ImagePlaygroundViewController
    ) {
        controller.dismiss(animated: true)
    }
    
    func handleGeneratedImage(_ image: UIImage) {
        // Image processing logic
    }
}
```

### 3. Generating Images with People

```swift
import SwiftUI
import ImagePlayground

struct PersonImageView: View {
    @State private var showPlayground = false
    @State private var result: URL?
    
    // Person photo URL
    let personPhotoURL: URL
    
    var body: some View {
        Button("Create My Character") {
            showPlayground = true
        }
        .imagePlaygroundSheet(
            isPresented: $showPlayground,
            concepts: [
                .person(
                    url: personPhotoURL,
                    nameComponents: PersonNameComponents(givenName: "John")
                ),
                .text("Astronaut")
            ],
            style: .animation
        ) { url in
            result = url
        }
    }
}
```

### 4. Fallback UI After Support Check

```swift
struct AdaptiveImageView: View {
    var body: some View {
        if ImagePlaygroundViewController.isAvailable {
            ImagePlaygroundView()
        } else {
            // Fallback UI (e.g., sticker picker)
            StickerPickerView()
        }
    }
}
```

### 5. Saving and Sharing Images

```swift
func saveToPhotos(url: URL) async throws {
    let data = try Data(contentsOf: url)
    guard let image = UIImage(data: data) else { return }
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
}

// Using ShareLink
struct ShareableImageView: View {
    let imageURL: URL
    
    var body: some View {
        VStack {
            AsyncImage(url: imageURL) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            
            ShareLink(
                item: imageURL,
                preview: SharePreview("Generated Image", image: imageURL)
            ) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }
}
```

## Important Notes

1. **Device Requirements**
   ```swift
   // Runtime check required
   if ImagePlaygroundViewController.isAvailable {
       // Available
   } else {
       // Show fallback UI
   }
   ```

2. **Supported Devices**
   - iPhone 15 Pro / Pro Max or later
   - M1 or later iPad / Mac
   - Not supported in simulator

3. **Image Characteristics**
   - Generated images are provided as temporary URLs
   - Copy manually for permanent storage

4. **Privacy**
   - Explicit consent required when using person images
   - Generated images are processed locally

5. **Style Limitations**
   - Only three styles supported (animation, illustration, sketch)
   - Realistic image generation not available
   - Limited text rendering
