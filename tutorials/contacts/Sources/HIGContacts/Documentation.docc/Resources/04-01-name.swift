import Contacts

let contact: CNContact = // 가져온 연락처

// 이름 관련 프로퍼티
let givenName = contact.givenName       // 이름 (예: "민수")
let familyName = contact.familyName     // 성 (예: "김")
let middleName = contact.middleName     // 중간 이름
let namePrefix = contact.namePrefix     // 접두사 (예: "Dr.")
let nameSuffix = contact.nameSuffix     // 접미사 (예: "Jr.")
let nickname = contact.nickname         // 별명
let organizationName = contact.organizationName // 회사명
let departmentName = contact.departmentName     // 부서명
let jobTitle = contact.jobTitle         // 직함
