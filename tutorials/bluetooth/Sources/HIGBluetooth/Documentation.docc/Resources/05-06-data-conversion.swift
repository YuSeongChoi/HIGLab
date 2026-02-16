import Foundation

// Data <-> 정수 변환 (리틀 엔디안)
extension Data {
    // UInt8 배열로 변환
    var bytes: [UInt8] {
        [UInt8](self)
    }
    
    // Hex 문자열
    var hexString: String {
        map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    // 16비트 정수 읽기 (리틀 엔디안)
    func readUInt16(at offset: Int = 0) -> UInt16? {
        guard count >= offset + 2 else { return nil }
        return withUnsafeBytes {
            $0.load(fromByteOffset: offset, as: UInt16.self)
        }
    }
    
    // 32비트 정수 읽기
    func readUInt32(at offset: Int = 0) -> UInt32? {
        guard count >= offset + 4 else { return nil }
        return withUnsafeBytes {
            $0.load(fromByteOffset: offset, as: UInt32.self)
        }
    }
}

// 정수 -> Data 변환
extension UInt16 {
    var data: Data {
        var value = self
        return Data(bytes: &value, count: 2)
    }
}

extension UInt32 {
    var data: Data {
        var value = self
        return Data(bytes: &value, count: 4)
    }
}
