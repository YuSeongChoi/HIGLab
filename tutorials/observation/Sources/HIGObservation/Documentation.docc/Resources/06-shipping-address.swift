import SwiftUI
import Observation

// MARK: - CartFlow: 배송지 모델
// Observable 객체로 배송지 정보 관리

@Observable
class ShippingAddress {
    var recipientName: String
    var phoneNumber: String
    var postalCode: String
    var address: String
    var detailAddress: String
    var isDefault: Bool
    
    init(
        recipientName: String = "",
        phoneNumber: String = "",
        postalCode: String = "",
        address: String = "",
        detailAddress: String = "",
        isDefault: Bool = false
    ) {
        self.recipientName = recipientName
        self.phoneNumber = phoneNumber
        self.postalCode = postalCode
        self.address = address
        self.detailAddress = detailAddress
        self.isDefault = isDefault
    }
    
    // 유효성 검사
    var isValid: Bool {
        !recipientName.isEmpty &&
        !phoneNumber.isEmpty &&
        !postalCode.isEmpty &&
        !address.isEmpty
    }
    
    // 전체 주소 문자열
    var fullAddress: String {
        if detailAddress.isEmpty {
            return "(\(postalCode)) \(address)"
        }
        return "(\(postalCode)) \(address), \(detailAddress)"
    }
    
    // 복사본 생성
    func copy() -> ShippingAddress {
        ShippingAddress(
            recipientName: recipientName,
            phoneNumber: phoneNumber,
            postalCode: postalCode,
            address: address,
            detailAddress: detailAddress,
            isDefault: isDefault
        )
    }
}

// MARK: - 샘플 데이터

extension ShippingAddress {
    static let sample = ShippingAddress(
        recipientName: "홍길동",
        phoneNumber: "010-1234-5678",
        postalCode: "06164",
        address: "서울특별시 강남구 테헤란로 123",
        detailAddress: "456호",
        isDefault: true
    )
    
    static let empty = ShippingAddress()
}
