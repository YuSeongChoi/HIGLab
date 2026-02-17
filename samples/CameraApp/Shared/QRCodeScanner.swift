import AVFoundation
import UIKit
import Combine

// MARK: - QR/바코드 스캐너
// AVCaptureMetadataOutput을 사용하여 QR 코드와 바코드를 인식합니다.
// HIG: 스캔 영역을 명확히 표시하고, 인식 결과를 즉시 피드백합니다.

/// QR/바코드 스캔 설정
struct QRCodeScannerConfiguration {
    /// 지원할 코드 타입
    var supportedTypes: [AVMetadataObject.ObjectType] = [
        .qr,           // QR 코드
        .ean8,         // EAN-8
        .ean13,        // EAN-13 (ISBN, 상품 바코드 등)
        .code128,      // Code 128
        .code39,       // Code 39
        .code93,       // Code 93
        .upce,         // UPC-E
        .pdf417,       // PDF417
        .aztec,        // Aztec
        .dataMatrix    // Data Matrix
    ]
    
    /// 스캔 영역 제한 (0~1 정규화된 좌표, nil = 전체 화면)
    var rectOfInterest: CGRect?
    
    /// 중복 스캔 방지 시간 (초)
    var duplicateFilterInterval: TimeInterval = 2.0
    
    /// 햅틱 피드백 활성화
    var isHapticFeedbackEnabled: Bool = true
    
    /// 스캔 사운드 활성화
    var isSoundEnabled: Bool = true
    
    /// 자동 URL 열기
    var autoOpenURL: Bool = false
}

// MARK: - QR 코드 스캐너

/// QR/바코드 스캐너 관리자
@MainActor
final class QRCodeScanner: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// 스캔 활성화 여부
    @Published var isScanning = false
    
    /// 마지막 스캔 결과
    @Published private(set) var lastResult: QRCodeScanResult?
    
    /// 스캔 결과 기록
    @Published private(set) var scanHistory: [QRCodeScanResult] = []
    
    /// 현재 감지된 코드들 (실시간 프레임)
    @Published private(set) var detectedCodes: [QRCodeScanResult] = []
    
    /// 스캔 영역 (UI 표시용)
    @Published var scanAreaBounds: CGRect = .zero
    
    // MARK: - Properties
    
    /// 메타데이터 출력
    private let metadataOutput = AVCaptureMetadataOutput()
    
    /// 스캔 설정
    private var configuration: QRCodeScannerConfiguration
    
    /// 중복 필터링을 위한 마지막 스캔 시간
    private var lastScanTime: [String: Date] = [:]
    
    /// 메타데이터 처리 큐
    private let metadataQueue = DispatchQueue(label: "com.cameraapp.metadata", qos: .userInitiated)
    
    /// 스캔 결과 콜백
    var onScanResult: ((QRCodeScanResult) -> Void)?
    
    // MARK: - Initialization
    
    init(configuration: QRCodeScannerConfiguration = QRCodeScannerConfiguration()) {
        self.configuration = configuration
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// 세션에 메타데이터 출력 추가
    /// - Parameter session: AVCaptureSession
    /// - Returns: 성공 여부
    func configureOutput(for session: AVCaptureSession) -> Bool {
        guard session.canAddOutput(metadataOutput) else {
            print("⚠️ MetadataOutput 추가 불가")
            return false
        }
        
        session.addOutput(metadataOutput)
        
        // 델리게이트 설정
        metadataOutput.setMetadataObjectsDelegate(self, queue: metadataQueue)
        
        // 지원 타입 필터링 (실제 지원되는 것만)
        let availableTypes = metadataOutput.availableMetadataObjectTypes
        let supportedTypes = configuration.supportedTypes.filter { availableTypes.contains($0) }
        metadataOutput.metadataObjectTypes = supportedTypes
        
        print("📱 QR 스캐너 설정 완료 - 지원 타입: \(supportedTypes.count)개")
        
        return true
    }
    
    /// 스캔 영역 설정
    /// - Parameter rect: 정규화된 영역 (0~1)
    func setRectOfInterest(_ rect: CGRect?) {
        if let rect = rect {
            // AVFoundation은 가로 모드 기준이므로 좌표 변환
            let transformedRect = CGRect(
                x: rect.origin.y,
                y: 1 - rect.origin.x - rect.size.width,
                width: rect.size.height,
                height: rect.size.width
            )
            metadataOutput.rectOfInterest = transformedRect
        } else {
            metadataOutput.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
    }
    
    /// 스캔 시작
    func startScanning() {
        isScanning = true
        detectedCodes.removeAll()
        print("🔍 QR 스캔 시작")
    }
    
    /// 스캔 중지
    func stopScanning() {
        isScanning = false
        detectedCodes.removeAll()
        print("🔍 QR 스캔 중지")
    }
    
    /// 스캔 토글
    func toggleScanning() {
        if isScanning {
            stopScanning()
        } else {
            startScanning()
        }
    }
    
    /// 스캔 기록 초기화
    func clearHistory() {
        scanHistory.removeAll()
        lastScanTime.removeAll()
    }
    
    /// 설정 업데이트
    func updateConfiguration(_ configuration: QRCodeScannerConfiguration) {
        self.configuration = configuration
        
        // 지원 타입 업데이트
        let availableTypes = metadataOutput.availableMetadataObjectTypes
        let supportedTypes = configuration.supportedTypes.filter { availableTypes.contains($0) }
        metadataOutput.metadataObjectTypes = supportedTypes
        
        // 스캔 영역 업데이트
        setRectOfInterest(configuration.rectOfInterest)
    }
    
    // MARK: - Private Methods
    
    /// 중복 스캔 필터링
    private func shouldProcessCode(_ value: String) -> Bool {
        let now = Date()
        
        if let lastTime = lastScanTime[value] {
            let elapsed = now.timeIntervalSince(lastTime)
            if elapsed < configuration.duplicateFilterInterval {
                return false
            }
        }
        
        lastScanTime[value] = now
        return true
    }
    
    /// 스캔 결과 처리
    private func processScanResult(_ result: QRCodeScanResult) {
        // 햅틱 피드백
        if configuration.isHapticFeedbackEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
        // 기록에 추가
        scanHistory.insert(result, at: 0)
        
        // 기록 제한 (최근 50개)
        if scanHistory.count > 50 {
            scanHistory = Array(scanHistory.prefix(50))
        }
        
        // 마지막 결과 업데이트
        lastResult = result
        
        // 콜백 호출
        onScanResult?(result)
        
        print("✅ 스캔 결과: [\(result.typeName)] \(result.value)")
        
        // 자동 URL 열기
        if configuration.autoOpenURL, let url = URL(string: result.value),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        // 스캔 비활성화 시 무시
        Task { @MainActor in
            guard self.isScanning else { return }
            
            // 감지된 코드들 업데이트
            let codes = metadataObjects.compactMap { object -> QRCodeScanResult? in
                guard let readable = object as? AVMetadataMachineReadableCodeObject,
                      let value = readable.stringValue else {
                    return nil
                }
                
                return QRCodeScanResult(
                    value: value,
                    type: readable.type,
                    bounds: readable.bounds
                )
            }
            
            self.detectedCodes = codes
            
            // 새 스캔 결과 처리
            for code in codes {
                if self.shouldProcessCode(code.value) {
                    self.processScanResult(code)
                }
            }
        }
    }
}

// MARK: - QR 코드 결과 분석 헬퍼

extension QRCodeScanResult {
    
    /// 결과가 URL인지 확인
    var isURL: Bool {
        URL(string: value) != nil && (value.hasPrefix("http://") || value.hasPrefix("https://"))
    }
    
    /// 결과가 이메일인지 확인
    var isEmail: Bool {
        value.contains("@") && value.contains(".")
    }
    
    /// 결과가 전화번호인지 확인
    var isPhoneNumber: Bool {
        value.hasPrefix("tel:") || value.allSatisfy { $0.isNumber || $0 == "-" || $0 == "+" || $0 == " " }
    }
    
    /// 결과가 Wi-Fi 정보인지 확인
    var isWiFi: Bool {
        value.hasPrefix("WIFI:")
    }
    
    /// 결과가 vCard 연락처인지 확인
    var isVCard: Bool {
        value.hasPrefix("BEGIN:VCARD")
    }
    
    /// 결과가 캘린더 이벤트인지 확인
    var isCalendarEvent: Bool {
        value.hasPrefix("BEGIN:VEVENT")
    }
    
    /// 결과 타입 자동 감지
    var detectedContentType: QRCodeContentType {
        if isURL { return .url }
        if isEmail { return .email }
        if isPhoneNumber { return .phone }
        if isWiFi { return .wifi }
        if isVCard { return .contact }
        if isCalendarEvent { return .calendar }
        return .text
    }
    
    /// 액션 가능한 URL 반환
    var actionURL: URL? {
        switch detectedContentType {
        case .url:
            return URL(string: value)
        case .email:
            return URL(string: "mailto:\(value)")
        case .phone:
            let cleanNumber = value.replacingOccurrences(of: "tel:", with: "")
            return URL(string: "tel:\(cleanNumber)")
        default:
            return nil
        }
    }
}

/// QR 코드 내용 타입
enum QRCodeContentType: String, CaseIterable {
    case url = "URL"
    case email = "이메일"
    case phone = "전화번호"
    case wifi = "Wi-Fi"
    case contact = "연락처"
    case calendar = "일정"
    case text = "텍스트"
    
    var symbol: String {
        switch self {
        case .url: "link"
        case .email: "envelope.fill"
        case .phone: "phone.fill"
        case .wifi: "wifi"
        case .contact: "person.crop.circle.fill"
        case .calendar: "calendar"
        case .text: "doc.text"
        }
    }
}

// MARK: - Wi-Fi 정보 파서

/// Wi-Fi QR 코드 정보
struct WiFiInfo {
    let ssid: String
    let password: String?
    let securityType: String?
    let isHidden: Bool
    
    /// Wi-Fi QR 코드 문자열 파싱
    /// 형식: WIFI:S:네트워크이름;T:보안타입;P:비밀번호;H:숨김여부;;
    init?(qrValue: String) {
        guard qrValue.hasPrefix("WIFI:") else { return nil }
        
        let content = qrValue.dropFirst(5) // "WIFI:" 제거
        var ssid: String?
        var password: String?
        var security: String?
        var hidden = false
        
        // 필드 파싱
        let fields = content.components(separatedBy: ";")
        for field in fields {
            if field.hasPrefix("S:") {
                ssid = String(field.dropFirst(2))
            } else if field.hasPrefix("P:") {
                password = String(field.dropFirst(2))
            } else if field.hasPrefix("T:") {
                security = String(field.dropFirst(2))
            } else if field.hasPrefix("H:") {
                hidden = field.dropFirst(2).lowercased() == "true"
            }
        }
        
        guard let networkName = ssid else { return nil }
        
        self.ssid = networkName
        self.password = password
        self.securityType = security
        self.isHidden = hidden
    }
}

// MARK: - vCard 파서

/// vCard 연락처 정보 (간단한 파싱)
struct VCardInfo {
    let fullName: String?
    let organization: String?
    let phoneNumbers: [String]
    let emails: [String]
    let address: String?
    
    init?(qrValue: String) {
        guard qrValue.hasPrefix("BEGIN:VCARD") else { return nil }
        
        var name: String?
        var org: String?
        var phones: [String] = []
        var emails: [String] = []
        var addr: String?
        
        let lines = qrValue.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("FN:") {
                name = String(trimmed.dropFirst(3))
            } else if trimmed.hasPrefix("ORG:") {
                org = String(trimmed.dropFirst(4))
            } else if trimmed.hasPrefix("TEL") {
                if let colonIndex = trimmed.firstIndex(of: ":") {
                    phones.append(String(trimmed[trimmed.index(after: colonIndex)...]))
                }
            } else if trimmed.hasPrefix("EMAIL") {
                if let colonIndex = trimmed.firstIndex(of: ":") {
                    emails.append(String(trimmed[trimmed.index(after: colonIndex)...]))
                }
            } else if trimmed.hasPrefix("ADR") {
                if let colonIndex = trimmed.firstIndex(of: ":") {
                    addr = String(trimmed[trimmed.index(after: colonIndex)...])
                        .replacingOccurrences(of: ";", with: " ")
                }
            }
        }
        
        self.fullName = name
        self.organization = org
        self.phoneNumbers = phones
        self.emails = emails
        self.address = addr
    }
}
