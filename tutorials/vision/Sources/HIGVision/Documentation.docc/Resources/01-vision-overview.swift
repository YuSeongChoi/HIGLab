import Vision
import UIKit

// Vision 프레임워크의 3가지 핵심 요소

// 1. VNRequest - 수행할 작업 정의
let textRequest = VNRecognizeTextRequest()
let faceRequest = VNDetectFaceRectanglesRequest()
let barcodeRequest = VNDetectBarcodesRequest()

// 2. VNImageRequestHandler - 이미지 분석 실행
let handler = VNImageRequestHandler(cgImage: image, options: [:])

// 3. VNObservation - 분석 결과 반환
// 각 Request 타입에 맞는 Observation이 반환됨
// - VNRecognizedTextObservation
// - VNFaceObservation
// - VNBarcodeObservation
