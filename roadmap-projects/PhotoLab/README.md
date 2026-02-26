# 📸 PhotoLab

사진 편집 앱 통합 샘플 프로젝트입니다.

## 사용 프레임워크

| 프레임워크 | 용도 |
|-----------|------|
| **SwiftUI** | 선언적 UI |
| **PhotosUI** | 사진 라이브러리 접근 |
| **Core Image** | 이미지 필터 적용 |
| **PencilKit** | 드로잉/마크업 |
| **Vision** | 텍스트 인식 (OCR) |

## 주요 기능

- 🖼️ 사진 선택 (PhotosUI)
- 🎨 필터 적용 (Core Image - Sepia, Mono, Vignette 등)
- ✏️ 드로잉 오버레이 (PencilKit)
- 📝 텍스트 인식 (Vision)
- 💾 편집 이미지 저장

## 학습 포인트

1. **PhotosUI**: PhotosPicker와 Transferable 프로토콜
2. **Core Image**: CIFilter 체이닝 및 GPU 렌더링
3. **PencilKit**: PKCanvasView 통합
4. **Vision**: VNRecognizeTextRequest OCR
