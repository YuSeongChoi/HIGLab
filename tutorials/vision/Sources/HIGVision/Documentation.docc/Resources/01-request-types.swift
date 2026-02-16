import Vision

// Vision이 제공하는 다양한 Request 종류

// 📝 텍스트 인식
let textRequest = VNRecognizeTextRequest()

// 👤 얼굴 감지
let faceRectRequest = VNDetectFaceRectanglesRequest()
let faceLandmarkRequest = VNDetectFaceLandmarksRequest()

// 📱 바코드 & QR
let barcodeRequest = VNDetectBarcodesRequest()

// 📄 사각형 감지
let rectangleRequest = VNDetectRectanglesRequest()

// 🎯 객체 추적
// let trackRequest = VNTrackObjectRequest(detectedObjectObservation: observation)

// 🖼️ 이미지 세그멘테이션
let segmentRequest = VNGeneratePersonSegmentationRequest()

// ✋ 손 포즈
let handPoseRequest = VNDetectHumanHandPoseRequest()

// 🏃 신체 포즈
let bodyPoseRequest = VNDetectHumanBodyPoseRequest()

// 🤖 CoreML 모델
// let coreMLRequest = VNCoreMLRequest(model: model)
