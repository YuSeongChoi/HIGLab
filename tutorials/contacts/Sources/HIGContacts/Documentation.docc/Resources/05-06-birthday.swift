import Contacts

let newContact = CNMutableContact()
newContact.givenName = "민수"
newContact.familyName = "김"

// 생일 설정
var birthday = DateComponents()
birthday.year = 1990
birthday.month = 5
birthday.day = 15

newContact.birthday = birthday

// 연도 없이 생일만 설정 (매년 반복)
var birthdayWithoutYear = DateComponents()
birthdayWithoutYear.month = 5
birthdayWithoutYear.day = 15

newContact.birthday = birthdayWithoutYear
