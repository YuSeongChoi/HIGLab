import Foundation

// BLE 커맨드 빌더 예제
struct LEDCommand {
    enum Mode: UInt8 {
        case off = 0x00
        case solid = 0x01
        case blink = 0x02
        case fade = 0x03
    }
    
    // LED 색상 설정 커맨드
    static func setColor(r: UInt8, g: UInt8, b: UInt8) -> Data {
        Data([0x01, r, g, b])  // [Command ID, R, G, B]
    }
    
    // LED 모드 설정
    static func setMode(_ mode: Mode) -> Data {
        Data([0x02, mode.rawValue])
    }
    
    // 밝기 설정 (0-100)
    static func setBrightness(_ percent: Int) -> Data {
        let value = UInt8(clamping: percent)
        return Data([0x03, value])
    }
}

// 사용 예
let redColor = LEDCommand.setColor(r: 255, g: 0, b: 0)
// writeValue(redColor, for: ledCharacteristic)

let blinkMode = LEDCommand.setMode(.blink)
// writeValue(blinkMode, for: ledCharacteristic)
