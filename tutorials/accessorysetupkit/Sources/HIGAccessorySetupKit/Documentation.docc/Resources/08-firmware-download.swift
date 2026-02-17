import Foundation
import CryptoKit

class FirmwareDownloader {
    enum DownloadError: Error {
        case checksumMismatch
        case downloadFailed
        case invalidData
    }
    
    // 펌웨어 다운로드 및 검증
    func download(from url: URL, expectedChecksum: String,
                  progress: @escaping (Double) -> Void) async throws -> Data {
        
        let (asyncBytes, response) = try await URLSession.shared.bytes(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DownloadError.downloadFailed
        }
        
        let totalSize = response.expectedContentLength
        var downloadedData = Data()
        var downloadedBytes: Int64 = 0
        
        for try await byte in asyncBytes {
            downloadedData.append(byte)
            downloadedBytes += 1
            
            if totalSize > 0 {
                let currentProgress = Double(downloadedBytes) / Double(totalSize)
                progress(currentProgress)
            }
        }
        
        // SHA256 체크섬 검증
        let checksum = SHA256.hash(data: downloadedData)
            .compactMap { String(format: "%02x", $0) }
            .joined()
        
        guard checksum == expectedChecksum else {
            throw DownloadError.checksumMismatch
        }
        
        return downloadedData
    }
    
    // 로컬 캐시 저장
    func cacheFirmware(_ data: Data, version: FirmwareVersion) throws -> URL {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileURL = cacheDir.appending(path: "firmware_\(version).bin")
        try data.write(to: fileURL)
        return fileURL
    }
}
