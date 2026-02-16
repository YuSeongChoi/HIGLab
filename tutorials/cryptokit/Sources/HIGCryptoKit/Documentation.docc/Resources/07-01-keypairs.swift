import CryptoKit
import Foundation

// Alice와 Bob의 키 쌍 생성
struct User {
    let name: String
    let privateKey: Curve25519.KeyAgreement.PrivateKey
    var publicKey: Curve25519.KeyAgreement.PublicKey {
        privateKey.publicKey
    }
    
    init(name: String) {
        self.name = name
        self.privateKey = Curve25519.KeyAgreement.PrivateKey()
    }
}

let alice = User(name: "Alice")
let bob = User(name: "Bob")

print("Alice 공개 키: \(alice.publicKey.rawRepresentation.base64EncodedString())")
print("Bob 공개 키: \(bob.publicKey.rawRepresentation.base64EncodedString())")
