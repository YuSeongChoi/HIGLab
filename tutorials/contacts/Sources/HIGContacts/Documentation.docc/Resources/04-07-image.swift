import Contacts
import SwiftUI

let contact: CNContact = // 가져온 연락처

// 이미지 데이터 접근
if let imageData = contact.imageData {
    // UIImage로 변환
    #if canImport(UIKit)
    let image = UIImage(data: imageData)
    #endif
}

// 썸네일 이미지 (작은 크기)
if let thumbnailData = contact.thumbnailImageData {
    #if canImport(UIKit)
    let thumbnail = UIImage(data: thumbnailData)
    #endif
}

// 이미지 사용 가능 여부 확인
let hasImage = contact.imageDataAvailable
