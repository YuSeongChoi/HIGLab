//
//  DeviceConnection.swift
//  BLEScanner
//
//  BLE 기기 연결 후 서비스/특성 탐색 및 데이터 교환 관리
//

import Foundation
import CoreBluetooth
import Combine

/// BLE 기기 연결 및 데이터 교환 관리
/// CBPeripheralDelegate를 구현하여 서비스/특성 탐색 처리
final class DeviceConnection: NSObject, ObservableObject {
    
    // MARK: - 싱글톤
    
    static let shared = DeviceConnection()
    
    // MARK: - Published 프로퍼티
    
    /// 서비스 검색 중 여부
    @Published var isDiscoveringServices = false
    
    /// 특성 검색 중 여부
    @Published var isDiscoveringCharacteristics = false
    
    /// 특성에서 읽은 값
    @Published var characteristicValues: [CBUUID: Data] = [:]
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    // MARK: - 알림 구독
    
    /// 알림 활성화된 특성 목록
    @Published var notifyingCharacteristics: Set<CBUUID> = []
    
    // MARK: - 초기화
    
    private override init() {
        super.init()
    }
    
    // MARK: - 서비스/특성 탐색
    
    /// 특정 서비스의 특성 검색
    /// - Parameters:
    ///   - peripheral: 대상 peripheral
    ///   - service: 대상 서비스
    func discoverCharacteristics(for peripheral: CBPeripheral, service: CBService) {
        isDiscoveringCharacteristics = true
        peripheral.discoverCharacteristics(nil, for: service)
    }
    
    // MARK: - 특성 읽기/쓰기
    
    /// 특성 값 읽기
    /// - Parameters:
    ///   - peripheral: 대상 peripheral
    ///   - characteristic: 읽을 특성
    func readValue(from peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard characteristic.properties.contains(.read) else {
            errorMessage = "이 특성은 읽기를 지원하지 않습니다"
            return
        }
        
        peripheral.readValue(for: characteristic)
        print("📖 특성 읽기 요청: \(characteristic.uuid)")
    }
    
    /// 특성에 값 쓰기
    /// - Parameters:
    ///   - peripheral: 대상 peripheral
    ///   - characteristic: 쓸 특성
    ///   - data: 쓸 데이터
    ///   - withResponse: 응답 대기 여부
    func writeValue(
        to peripheral: CBPeripheral,
        characteristic: CBCharacteristic,
        data: Data,
        withResponse: Bool = true
    ) {
        let writeType: CBCharacteristicWriteType = withResponse ? .withResponse : .withoutResponse
        
        // 쓰기 가능 여부 확인
        if withResponse {
            guard characteristic.properties.contains(.write) else {
                errorMessage = "이 특성은 쓰기(응답)를 지원하지 않습니다"
                return
            }
        } else {
            guard characteristic.properties.contains(.writeWithoutResponse) else {
                errorMessage = "이 특성은 쓰기(무응답)를 지원하지 않습니다"
                return
            }
        }
        
        peripheral.writeValue(data, for: characteristic, type: writeType)
        print("✍️ 특성 쓰기: \(characteristic.uuid), 데이터: \(data.hexString)")
    }
    
    // MARK: - 알림 설정
    
    /// 특성 알림 활성화/비활성화
    /// - Parameters:
    ///   - peripheral: 대상 peripheral
    ///   - characteristic: 대상 특성
    ///   - enabled: 활성화 여부
    func setNotify(
        for peripheral: CBPeripheral,
        characteristic: CBCharacteristic,
        enabled: Bool
    ) {
        guard characteristic.properties.contains(.notify) ||
              characteristic.properties.contains(.indicate) else {
            errorMessage = "이 특성은 알림을 지원하지 않습니다"
            return
        }
        
        peripheral.setNotifyValue(enabled, for: characteristic)
        print("🔔 알림 설정: \(characteristic.uuid), 활성화: \(enabled)")
    }
    
    /// 알림 토글
    func toggleNotify(for peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        let isCurrentlyNotifying = notifyingCharacteristics.contains(characteristic.uuid)
        setNotify(for: peripheral, characteristic: characteristic, enabled: !isCurrentlyNotifying)
    }
}

// MARK: - CBPeripheralDelegate

extension DeviceConnection: CBPeripheralDelegate {
    
    /// 서비스 발견 콜백
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        isDiscoveringServices = false
        
        if let error = error {
            errorMessage = "서비스 검색 실패: \(error.localizedDescription)"
            print("❌ 서비스 검색 실패: \(error)")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        print("📦 발견된 서비스: \(services.count)개")
        
        // BluetoothManager의 연결된 기기에 서비스 저장
        if let device = BluetoothManager.shared.discoveredDevices.first(where: { $0.id == peripheral.identifier }) {
            DispatchQueue.main.async {
                device.services = services
            }
            
            // 각 서비스의 특성 검색
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    /// 특성 발견 콜백
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        isDiscoveringCharacteristics = false
        
        if let error = error {
            errorMessage = "특성 검색 실패: \(error.localizedDescription)"
            print("❌ 특성 검색 실패: \(error)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        print("🔧 서비스 \(service.uuid)의 특성: \(characteristics.count)개")
        
        // 연결된 기기에 특성 저장
        if let device = BluetoothManager.shared.discoveredDevices.first(where: { $0.id == peripheral.identifier }) {
            DispatchQueue.main.async {
                device.characteristics[service.uuid] = characteristics
            }
        }
    }
    
    /// 특성 값 업데이트 콜백 (읽기 또는 알림)
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            errorMessage = "값 읽기 실패: \(error.localizedDescription)"
            print("❌ 값 읽기 실패: \(error)")
            return
        }
        
        if let value = characteristic.value {
            DispatchQueue.main.async { [weak self] in
                self?.characteristicValues[characteristic.uuid] = value
            }
            
            print("📥 특성 값 수신: \(characteristic.uuid)")
            print("   HEX: \(value.hexString)")
            print("   UTF8: \(value.utf8String ?? "(디코딩 불가)")")
        }
    }
    
    /// 특성 쓰기 완료 콜백
    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            errorMessage = "값 쓰기 실패: \(error.localizedDescription)"
            print("❌ 값 쓰기 실패: \(error)")
            return
        }
        
        print("✅ 특성 쓰기 완료: \(characteristic.uuid)")
    }
    
    /// 알림 상태 변경 콜백
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            errorMessage = "알림 설정 실패: \(error.localizedDescription)"
            print("❌ 알림 설정 실패: \(error)")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if characteristic.isNotifying {
                self?.notifyingCharacteristics.insert(characteristic.uuid)
                print("🔔 알림 활성화: \(characteristic.uuid)")
            } else {
                self?.notifyingCharacteristics.remove(characteristic.uuid)
                print("🔕 알림 비활성화: \(characteristic.uuid)")
            }
        }
    }
    
    /// peripheral 이름 변경 콜백
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        if let device = BluetoothManager.shared.discoveredDevices.first(where: { $0.id == peripheral.identifier }) {
            DispatchQueue.main.async {
                device.name = peripheral.name ?? "알 수 없는 기기"
            }
        }
    }
    
    /// RSSI 읽기 콜백
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            print("⚠️ RSSI 읽기 실패: \(error)")
            return
        }
        
        if let device = BluetoothManager.shared.discoveredDevices.first(where: { $0.id == peripheral.identifier }) {
            DispatchQueue.main.async {
                device.updateRSSI(RSSI.intValue)
            }
        }
    }
}

// MARK: - Data 확장

extension Data {
    /// 16진수 문자열 변환
    var hexString: String {
        map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    /// UTF-8 문자열 변환 (실패 시 nil)
    var utf8String: String? {
        String(data: self, encoding: .utf8)
    }
}

// MARK: - CBCharacteristic 확장

extension CBCharacteristic {
    /// 특성 속성 설명
    var propertiesDescription: String {
        var props: [String] = []
        
        if properties.contains(.read) { props.append("읽기") }
        if properties.contains(.write) { props.append("쓰기") }
        if properties.contains(.writeWithoutResponse) { props.append("쓰기(무응답)") }
        if properties.contains(.notify) { props.append("알림") }
        if properties.contains(.indicate) { props.append("표시") }
        if properties.contains(.broadcast) { props.append("브로드캐스트") }
        if properties.contains(.authenticatedSignedWrites) { props.append("인증 쓰기") }
        if properties.contains(.extendedProperties) { props.append("확장 속성") }
        
        return props.isEmpty ? "없음" : props.joined(separator: ", ")
    }
}

// MARK: - 알려진 서비스/특성 UUID

/// 표준 BLE 서비스 UUID
enum StandardBLEService {
    /// 기기 정보 서비스
    static let deviceInformation = CBUUID(string: "180A")
    /// 배터리 서비스
    static let battery = CBUUID(string: "180F")
    /// 심박수 서비스
    static let heartRate = CBUUID(string: "180D")
    /// 혈압 서비스
    static let bloodPressure = CBUUID(string: "1810")
    /// 건강 체온계 서비스
    static let healthThermometer = CBUUID(string: "1809")
    
    /// 서비스 이름 가져오기
    static func name(for uuid: CBUUID) -> String? {
        switch uuid {
        case deviceInformation: return "기기 정보"
        case battery: return "배터리"
        case heartRate: return "심박수"
        case bloodPressure: return "혈압"
        case healthThermometer: return "체온계"
        default: return nil
        }
    }
}

/// 표준 BLE 특성 UUID
enum StandardBLECharacteristic {
    /// 제조사 이름
    static let manufacturerName = CBUUID(string: "2A29")
    /// 모델 번호
    static let modelNumber = CBUUID(string: "2A24")
    /// 펌웨어 버전
    static let firmwareRevision = CBUUID(string: "2A26")
    /// 배터리 레벨
    static let batteryLevel = CBUUID(string: "2A19")
    /// 심박수 측정
    static let heartRateMeasurement = CBUUID(string: "2A37")
    
    /// 특성 이름 가져오기
    static func name(for uuid: CBUUID) -> String? {
        switch uuid {
        case manufacturerName: return "제조사"
        case modelNumber: return "모델 번호"
        case firmwareRevision: return "펌웨어 버전"
        case batteryLevel: return "배터리 레벨"
        case heartRateMeasurement: return "심박수 측정"
        default: return nil
        }
    }
}
