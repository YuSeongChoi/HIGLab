import Contacts
import UIKit

let newContact = CNMutableContact()
newContact.givenName = "민수"
newContact.familyName = "김"

// 프로필 이미지 설정
if let image = UIImage(named: "profile"),
   let imageData = image.jpegData(compressionQuality: 0.8) {
    newContact.imageData = imageData
}

// 또는 PNG 데이터 사용
if let image = UIImage(systemName: "person.fill"),
   let pngData = image.pngData() {
    newContact.imageData = pngData
}
