// MARK: - Chapter 4: 패스 서명 & 배포

// 04-01-pass-type-id.swift
let passTypeIdentifier = "pass.com.myapp.membership"
// 형식: pass.{reverse-domain}.{pass-name}

// 04-03-manifest.swift
import CryptoKit
import Foundation

func createManifest(for directory: URL) throws -> [String: String] {
    var manifest: [String: String] = [:]
    let fileManager = FileManager.default
    
    let files = try fileManager.contentsOfDirectory(
        at: directory,
        includingPropertiesForKeys: nil
    )
    
    for file in files where file.lastPathComponent != "signature" {
        let data = try Data(contentsOf: file)
        let hash = SHA1.hash(data: data)
        let hashString = hash.map { String(format: "%02x", $0) }.joined()
        manifest[file.lastPathComponent] = hashString
    }
    
    return manifest
}

// 04-04-manifest-json.swift
/*
 manifest.json 예시:
 {
   "pass.json": "abc123...",
   "icon.png": "def456...",
   "icon@2x.png": "ghi789...",
   "logo.png": "jkl012...",
   "strip.png": "mno345..."
 }
*/

// 04-05-signing.swift
/*
 터미널에서 서명 생성 (OpenSSL):
 
 openssl smime -binary -sign \
   -certfile wwdr.pem \
   -signer passcert.pem \
   -inkey passkey.pem \
   -in manifest.json \
   -out signature \
   -outform DER
*/

// 04-07-create-bundle.swift
/*
 패스 번들 생성 (터미널):
 
 cd pass_directory
 zip -r ../membership.pkpass .
 
 또는 프로그래매틱하게:
*/
func createPKPassBundle(from directory: URL, to destination: URL) throws {
    let fileManager = FileManager.default
    let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
    
    // ZIP 압축 로직 (ZIPFoundation 등 사용)
}

// 04-09-download-pass.swift
import PassKit

func downloadAndAddPass(from urlString: String) async throws {
    guard let url = URL(string: urlString) else {
        throw PassError.invalidURL
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let pass = try PKPass(data: data)
    
    // 패스 유효성 확인
    guard PKPassLibrary.isPassLibraryAvailable() else {
        throw PassError.walletUnavailable
    }
    
    // 패스 추가 UI 표시
    await showAddPassUI(pass)
}

enum PassError: Error {
    case invalidURL
    case walletUnavailable
    case invalidPass
}

// 04-10-add-pass-vc.swift
import UIKit

class PassViewController: UIViewController {
    func presentAddPassViewController(with pass: PKPass) {
        guard let addPassVC = PKAddPassesViewController(pass: pass) else {
            return
        }
        
        addPassVC.delegate = self
        present(addPassVC, animated: true)
    }
}

extension PassViewController: PKAddPassesViewControllerDelegate {
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        controller.dismiss(animated: true)
    }
}

// 04-11-add-pass-swiftui.swift
import SwiftUI

struct AddPassButton: View {
    let passData: Data
    @State private var showingAddPass = false
    
    var body: some View {
        Button("Wallet에 추가") {
            showingAddPass = true
        }
        .sheet(isPresented: $showingAddPass) {
            AddPassViewRepresentable(passData: passData)
        }
    }
}

struct AddPassViewRepresentable: UIViewControllerRepresentable {
    let passData: Data
    
    func makeUIViewController(context: Context) -> PKAddPassesViewController {
        let pass = try! PKPass(data: passData)
        return PKAddPassesViewController(pass: pass)!
    }
    
    func updateUIViewController(_ uiViewController: PKAddPassesViewController, context: Context) {}
}

// MARK: - Chapter 5: 패스 업데이트

// 05-01-web-service-config.swift
let webServiceConfig = """
{
    "webServiceURL": "https://api.myapp.com/passes",
    "authenticationToken": "secure_random_token_here"
}
"""

// 05-03-register-device.swift
/*
 POST /v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}/{serialNumber}
 
 Headers:
   Authorization: ApplePass {authenticationToken}
 
 Body:
   { "pushToken": "abc123..." }
 
 Response:
   - 201 Created: 새로 등록됨
   - 200 OK: 이미 등록됨
   - 401 Unauthorized: 인증 실패
*/

// 05-05-unregister.swift
/*
 DELETE /v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}/{serialNumber}
 
 Headers:
   Authorization: ApplePass {authenticationToken}
 
 Response:
   - 200 OK: 등록 해제됨
*/

// 05-07-send-push.swift
/*
 APNs Push for Pass Update:
 
 - Topic: pass.com.myapp.membership (Pass Type ID)
 - Payload: {} (빈 객체)
 - Priority: 5 (low) 또는 10 (high)
*/

// 05-08-get-serials.swift
/*
 GET /v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}?passesUpdatedSince={tag}
 
 Response:
 {
   "serialNumbers": ["MEMBER123456", "MEMBER789012"],
   "lastUpdated": "1234567890"
 }
*/

// 05-09-get-pass.swift
/*
 GET /v1/passes/{passTypeIdentifier}/{serialNumber}
 
 Headers:
   Authorization: ApplePass {authenticationToken}
   If-Modified-Since: {lastModified}
 
 Response:
   - 200 OK: .pkpass 파일 (application/vnd.apple.pkpass)
   - 304 Not Modified: 변경 없음
*/

// 05-11-pass-notification.swift
class PassObserver {
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(passLibraryDidChange),
            name: NSNotification.Name.PKPassLibraryDidChange,
            object: nil
        )
    }
    
    @objc func passLibraryDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let addedPasses = userInfo[PKPassLibraryAddedPassesUserInfoKey] as? [PKPass] {
            print("추가된 패스: \(addedPasses.count)개")
        }
        
        if let removedPasses = userInfo[PKPassLibraryRemovedPassInfosUserInfoKey] as? [[String: Any]] {
            print("삭제된 패스: \(removedPasses.count)개")
        }
        
        if let replacedPasses = userInfo[PKPassLibraryReplacedPassesUserInfoKey] as? [PKPass] {
            print("업데이트된 패스: \(replacedPasses.count)개")
        }
    }
}
