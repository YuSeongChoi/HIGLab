import AVFoundation
import SwiftUI

// MARK: - 카메라 설정 모델
// 카메라 앱의 모든 설정값을 관리하는 모델들입니다.
// HIG: 설정값은 직관적이고 사용자가 이해하기 쉬운 형태로 제공합니다.

// MARK: - 카메라 위치

/// 카메라 위치 (전면/후면)
enum CameraPosition: String, CaseIterable, Identifiable {
    case front = "전면"
    case back = "후면"
    
    var id: String { rawValue }
    
    /// AVFoundation 위치값으로 변환
    var avPosition: AVCaptureDevice.Position {
        switch self {
        case .front: .front
        case .back: .back
        }
    }
    
    /// 반대 위치 반환
    var opposite: CameraPosition {
        switch self {
        case .front: .back
        case .back: .front
        }
    }
    
    /// 아이콘 심볼
    var symbol: String {
        switch self {
        case .front: "camera.rotate.fill"
        case .back: "camera.fill"
        }
    }
}

// MARK: - 플래시 모드

/// 플래시/토치 모드
enum FlashMode: String, CaseIterable, Identifiable {
    case auto = "자동"
    case on = "켜기"
    case off = "끄기"
    
    var id: String { rawValue }
    
    /// SF Symbol 아이콘
    var symbol: String {
        switch self {
        case .auto: "bolt.badge.automatic"
        case .on: "bolt.fill"
        case .off: "bolt.slash.fill"
        }
    }
    
    /// AVCaptureDevice.FlashMode로 변환
    var avFlashMode: AVCaptureDevice.FlashMode {
        switch self {
        case .auto: .auto
        case .on: .on
        case .off: .off
        }
    }
    
    /// AVCaptureDevice.TorchMode로 변환 (비디오 촬영용)
    var avTorchMode: AVCaptureDevice.TorchMode {
        switch self {
        case .auto: .auto
        case .on: .on
        case .off: .off
        }
    }
    
    /// 다음 모드 순환
    var next: FlashMode {
        switch self {
        case .auto: .on
        case .on: .off
        case .off: .auto
        }
    }
}

// MARK: - 캡처 모드

/// 촬영 모드
enum CaptureMode: String, CaseIterable, Identifiable {
    case photo = "사진"
    case video = "비디오"
    case qrCode = "QR 코드"
    
    var id: String { rawValue }
    
    /// 아이콘 심볼
    var symbol: String {
        switch self {
        case .photo: "camera.fill"
        case .video: "video.fill"
        case .qrCode: "qrcode.viewfinder"
        }
    }
    
    /// 색상
    var color: Color {
        switch self {
        case .photo: .white
        case .video: .red
        case .qrCode: .yellow
        }
    }
}

// MARK: - 포커스 모드

/// 포커스 모드
enum FocusModeOption: String, CaseIterable, Identifiable {
    case auto = "자동"
    case continuous = "연속"
    case locked = "고정"
    
    var id: String { rawValue }
    
    /// AVCaptureDevice.FocusMode로 변환
    var avFocusMode: AVCaptureDevice.FocusMode {
        switch self {
        case .auto: .autoFocus
        case .continuous: .continuousAutoFocus
        case .locked: .locked
        }
    }
    
    /// 설명
    var description: String {
        switch self {
        case .auto: "화면을 탭하면 해당 지점에 초점을 맞춥니다"
        case .continuous: "자동으로 계속 초점을 조정합니다"
        case .locked: "현재 초점 위치를 유지합니다"
        }
    }
}

// MARK: - 노출 모드

/// 노출 모드
enum ExposureModeOption: String, CaseIterable, Identifiable {
    case auto = "자동"
    case continuous = "연속"
    case locked = "고정"
    case custom = "사용자 지정"
    
    var id: String { rawValue }
    
    /// AVCaptureDevice.ExposureMode로 변환
    var avExposureMode: AVCaptureDevice.ExposureMode {
        switch self {
        case .auto: .autoExpose
        case .continuous: .continuousAutoExposure
        case .locked: .locked
        case .custom: .custom
        }
    }
}

// MARK: - 화이트밸런스 모드

/// 화이트밸런스 모드
enum WhiteBalanceModeOption: String, CaseIterable, Identifiable {
    case auto = "자동"
    case continuous = "연속"
    case locked = "고정"
    
    var id: String { rawValue }
    
    /// AVCaptureDevice.WhiteBalanceMode로 변환
    var avWhiteBalanceMode: AVCaptureDevice.WhiteBalanceMode {
        switch self {
        case .auto: .autoWhiteBalance
        case .continuous: .continuousAutoWhiteBalance
        case .locked: .locked
        }
    }
}

// MARK: - 타이머 설정

/// 셀프 타이머 설정
enum TimerSetting: Int, CaseIterable, Identifiable {
    case off = 0
    case threeSeconds = 3
    case fiveSeconds = 5
    case tenSeconds = 10
    
    var id: Int { rawValue }
    
    /// 표시 문자열
    var displayText: String {
        switch self {
        case .off: "끔"
        default: "\(rawValue)초"
        }
    }
    
    /// 아이콘
    var symbol: String {
        switch self {
        case .off: "timer"
        default: "timer"
        }
    }
    
    /// 다음 설정 순환
    var next: TimerSetting {
        switch self {
        case .off: .threeSeconds
        case .threeSeconds: .fiveSeconds
        case .fiveSeconds: .tenSeconds
        case .tenSeconds: .off
        }
    }
}

// MARK: - HDR 모드

/// HDR 촬영 모드
enum HDRMode: String, CaseIterable, Identifiable {
    case auto = "자동"
    case on = "켜기"
    case off = "끄기"
    
    var id: String { rawValue }
    
    /// 아이콘
    var symbol: String {
        "hdr"
    }
}

// MARK: - 사진 품질

/// 사진 품질 설정
enum PhotoQuality: String, CaseIterable, Identifiable {
    case maximum = "최대"
    case balanced = "균형"
    case speed = "속도"
    
    var id: String { rawValue }
    
    /// AVCapturePhotoOutput.QualityPrioritization으로 변환
    var avQualityPrioritization: AVCapturePhotoOutput.QualityPrioritization {
        switch self {
        case .maximum: .quality
        case .balanced: .balanced
        case .speed: .speed
        }
    }
}

// MARK: - 비디오 해상도

/// 비디오 해상도 설정
enum VideoResolution: String, CaseIterable, Identifiable {
    case hd720p = "720p HD"
    case hd1080p = "1080p Full HD"
    case uhd4k = "4K UHD"
    
    var id: String { rawValue }
    
    /// AVCaptureSession.Preset으로 변환
    var sessionPreset: AVCaptureSession.Preset {
        switch self {
        case .hd720p: .hd1280x720
        case .hd1080p: .hd1920x1080
        case .uhd4k: .hd4K3840x2160
        }
    }
    
    /// 프레임 레이트 옵션
    var supportedFrameRates: [VideoFrameRate] {
        switch self {
        case .hd720p: [.fps30, .fps60, .fps120, .fps240]
        case .hd1080p: [.fps30, .fps60, .fps120]
        case .uhd4k: [.fps24, .fps30, .fps60]
        }
    }
}

// MARK: - 비디오 프레임 레이트

/// 비디오 프레임 레이트 설정
enum VideoFrameRate: Int, CaseIterable, Identifiable {
    case fps24 = 24
    case fps30 = 30
    case fps60 = 60
    case fps120 = 120
    case fps240 = 240
    
    var id: Int { rawValue }
    
    /// 표시 문자열
    var displayText: String {
        "\(rawValue) fps"
    }
}

// MARK: - 줌 레벨

/// 줌 설정
struct ZoomSettings {
    /// 현재 줌 배율
    var currentZoom: CGFloat = 1.0
    
    /// 최소 줌 배율
    var minZoom: CGFloat = 1.0
    
    /// 최대 줌 배율
    var maxZoom: CGFloat = 10.0
    
    /// 기본 줌 배율 (울트라 와이드 등)
    var defaultZoom: CGFloat = 1.0
    
    /// 사용 가능한 줌 프리셋 (0.5x, 1x, 2x, 3x 등)
    var availablePresets: [CGFloat] = [1.0, 2.0]
}

// MARK: - 포커스/노출 포인트

/// 화면상의 포커스/노출 포인트
struct FocusPoint: Equatable {
    /// 화면 좌표 (0.0 ~ 1.0)
    let x: CGFloat
    let y: CGFloat
    
    /// 탭 시간
    let timestamp: Date
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
        self.timestamp = Date()
    }
    
    /// CGPoint로 변환
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    static func == (lhs: FocusPoint, rhs: FocusPoint) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

// MARK: - 카메라 기능 지원 여부

/// 현재 카메라 디바이스의 기능 지원 여부
struct CameraCapabilities {
    var hasFlash: Bool = false
    var hasTorch: Bool = false
    var supportsFocus: Bool = false
    var supportsExposure: Bool = false
    var supportsWhiteBalance: Bool = false
    var supportsZoom: Bool = false
    var supportsHDR: Bool = false
    var supportsDepth: Bool = false
    var supportsPortrait: Bool = false
    var maxZoomFactor: CGFloat = 1.0
    var minZoomFactor: CGFloat = 1.0
    
    /// 기본값 (기능 없음)
    static let none = CameraCapabilities()
}

// MARK: - 카메라 오류

/// 카메라 관련 오류
enum CameraError: LocalizedError {
    case unauthorized
    case microphoneUnauthorized
    case setupFailed(String)
    case captureError(String)
    case recordingError(String)
    case deviceNotFound
    case formatNotSupported
    case sessionInterrupted
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            "카메라 접근 권한이 필요합니다. 설정에서 허용해주세요."
        case .microphoneUnauthorized:
            "마이크 접근 권한이 필요합니다. 설정에서 허용해주세요."
        case .setupFailed(let reason):
            "카메라 설정 실패: \(reason)"
        case .captureError(let reason):
            "촬영 오류: \(reason)"
        case .recordingError(let reason):
            "녹화 오류: \(reason)"
        case .deviceNotFound:
            "카메라 장치를 찾을 수 없습니다."
        case .formatNotSupported:
            "지원하지 않는 포맷입니다."
        case .sessionInterrupted:
            "카메라 세션이 중단되었습니다."
        case .unknown(let reason):
            "알 수 없는 오류: \(reason)"
        }
    }
    
    /// 복구 가능한 오류인지 여부
    var isRecoverable: Bool {
        switch self {
        case .sessionInterrupted:
            true
        default:
            false
        }
    }
}

// MARK: - 캡처 결과

/// 사진 캡처 결과
enum PhotoCaptureResult {
    case success(CapturedMedia)
    case failure(CameraError)
}

/// 비디오 녹화 결과
enum VideoRecordingResult {
    case success(CapturedMedia)
    case failure(CameraError)
}

// MARK: - QR 코드 스캔 결과

/// QR/바코드 스캔 결과
struct QRCodeScanResult: Identifiable, Equatable {
    let id = UUID()
    let value: String
    let type: AVMetadataObject.ObjectType
    let bounds: CGRect
    let timestamp: Date
    
    init(value: String, type: AVMetadataObject.ObjectType, bounds: CGRect = .zero) {
        self.value = value
        self.type = type
        self.bounds = bounds
        self.timestamp = Date()
    }
    
    /// 타입 이름 (한글)
    var typeName: String {
        switch type {
        case .qr: "QR 코드"
        case .ean8: "EAN-8"
        case .ean13: "EAN-13"
        case .code128: "Code 128"
        case .code39: "Code 39"
        case .code93: "Code 93"
        case .upce: "UPC-E"
        case .pdf417: "PDF417"
        case .aztec: "Aztec"
        case .dataMatrix: "Data Matrix"
        default: "바코드"
        }
    }
    
    static func == (lhs: QRCodeScanResult, rhs: QRCodeScanResult) -> Bool {
        lhs.value == rhs.value && lhs.type == rhs.type
    }
}

// MARK: - 연속 촬영 (Burst) 설정

/// 연속 촬영 설정
struct BurstSettings {
    /// 연속 촬영 활성화 여부
    var isEnabled: Bool = false
    
    /// 촬영 간격 (초)
    var interval: TimeInterval = 0.1
    
    /// 최대 촬영 수
    var maxCount: Int = 10
    
    /// 현재 촬영 수
    var currentCount: Int = 0
}

// MARK: - 오디오 설정

/// 비디오 녹화 시 오디오 설정
struct AudioSettings {
    /// 오디오 녹음 활성화
    var isEnabled: Bool = true
    
    /// 입력 게인 (0.0 ~ 1.0)
    var inputGain: Float = 1.0
}

// MARK: - 세션 상태

/// 캡처 세션 상태
enum SessionState: Equatable {
    case idle                    // 초기 상태
    case configuring             // 설정 중
    case running                 // 실행 중
    case paused                  // 일시 중지
    case stopped                 // 중지됨
    case error(String)           // 오류 발생
    
    var isActive: Bool {
        switch self {
        case .running: true
        default: false
        }
    }
    
    static func == (lhs: SessionState, rhs: SessionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.configuring, .configuring),
             (.running, .running),
             (.paused, .paused),
             (.stopped, .stopped):
            return true
        case (.error(let lMsg), .error(let rMsg)):
            return lMsg == rMsg
        default:
            return false
        }
    }
}

// MARK: - 녹화 상태

/// 비디오 녹화 상태
enum RecordingState: Equatable {
    case idle                    // 대기 중
    case preparing               // 준비 중
    case recording               // 녹화 중
    case pausing                 // 일시 중지 중
    case paused                  // 일시 중지됨
    case finishing               // 마무리 중
    case finished                // 완료
    
    var isRecording: Bool {
        switch self {
        case .recording, .paused: true
        default: false
        }
    }
}
