import AVFoundation

// AVFoundation 캡처 파이프라인 구조
//
// ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
// │ AVCapture    │───▶│ AVCapture    │───▶│ AVCapture    │
// │ Device       │    │ DeviceInput  │    │ Session      │
// │ (카메라)      │    │              │    │              │
// └──────────────┘    └──────────────┘    └──────┬───────┘
//                                                │
//                     ┌──────────────────────────┴───────┐
//                     │                                  │
//              ┌──────▼──────┐                   ┌──────▼──────┐
//              │ AVCapture   │                   │ AVCapture   │
//              │ PhotoOutput │                   │ VideoData   │
//              │ (사진 촬영)  │                   │ Output      │
//              └─────────────┘                   └─────────────┘
