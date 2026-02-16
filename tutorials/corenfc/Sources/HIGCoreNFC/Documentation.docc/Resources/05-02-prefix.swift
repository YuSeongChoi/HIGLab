import CoreNFC
import Foundation

// URI 프리픽스 코드 (NFC Forum URI Record Type Definition)
// payload[0]이 프리픽스를 나타냄
let uriPrefixes: [UInt8: String] = [
    0x00: "",                    // 프리픽스 없음
    0x01: "http://www.",
    0x02: "https://www.",
    0x03: "http://",
    0x04: "https://",
    0x05: "tel:",
    0x06: "mailto:",
    0x07: "ftp://anonymous:anonymous@",
    0x08: "ftp://ftp.",
    0x09: "ftps://",
    0x0A: "sftp://",
    0x0B: "smb://",
    0x0C: "nfs://",
    0x0D: "ftp://",
    0x0E: "dav://",
    0x0F: "news:",
    0x10: "telnet://",
    0x11: "imap:",
    0x12: "rtsp://",
    0x13: "urn:",
    0x14: "pop:",
    0x15: "sip:",
    0x16: "sips:",
    0x17: "tftp:",
    0x18: "btspp://",
    0x19: "btl2cap://",
    0x1A: "btgoep://",
    0x1B: "tcpobex://",
    0x1C: "irdaobex://",
    0x1D: "file://",
    0x1E: "urn:epc:id:",
    0x1F: "urn:epc:tag:",
    0x20: "urn:epc:pat:",
    0x21: "urn:epc:raw:",
    0x22: "urn:epc:",
    0x23: "urn:nfc:"
]

// 수동으로 URL 파싱하기
func parseURIManually(_ payload: Data) -> URL? {
    guard !payload.isEmpty else { return nil }
    
    let prefixCode = payload[0]
    let prefix = uriPrefixes[prefixCode] ?? ""
    let rest = String(data: payload.dropFirst(), encoding: .utf8) ?? ""
    
    return URL(string: prefix + rest)
}
