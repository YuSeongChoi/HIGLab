import Foundation

struct FirmwareVersion: Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int
    let patch: Int
    
    var description: String {
        "\(major).\(minor).\(patch)"
    }
    
    static func < (lhs: FirmwareVersion, rhs: FirmwareVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
    
    init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    init?(string: String) {
        let parts = string.split(separator: ".").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        self.major = parts[0]
        self.minor = parts[1]
        self.patch = parts[2]
    }
}

class FirmwareChecker {
    private let serverURL: URL
    
    init(serverURL: URL) {
        self.serverURL = serverURL
    }
    
    // 서버에서 최신 버전 확인
    func checkLatestVersion(for deviceModel: String) async throws -> FirmwareInfo {
        let url = serverURL.appending(path: "firmware/\(deviceModel)/latest")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(FirmwareInfo.self, from: data)
    }
    
    // 업데이트 필요 여부 확인
    func needsUpdate(current: FirmwareVersion, latest: FirmwareVersion) -> Bool {
        current < latest
    }
}

struct FirmwareInfo: Codable {
    let version: String
    let downloadURL: URL
    let checksum: String
    let releaseNotes: String
    let minOSVersion: String
}
