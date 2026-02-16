// MARK: - Chapter 2-5: PKPass 구조 & 패스 관리

// 02-01-load-pass.swift
func loadPass(from url: URL) throws -> PKPass {
    let passData = try Data(contentsOf: url)
    return try PKPass(data: passData)
}

// 02-02-pass-properties.swift
func inspectPass(_ pass: PKPass) {
    print("Serial: \(pass.serialNumber)")
    print("Organization: \(pass.organizationName)")
    print("Description: \(pass.localizedDescription)")
    print("Type: \(pass.passType)")
    
    if let icon = pass.icon {
        print("Icon size: \(icon.size)")
    }
}

// 02-03-field-structure.swift
/*
 pass.json 필드 구조:
 {
   "key": "memberName",
   "label": "회원 이름",
   "value": "홍길동"
 }
*/

// 02-04-store-card-layout.swift
/*
 storeCard 레이아웃:
 ┌─────────────────────────────┐
 │ [logo]           [header]  │  ← headerFields (포인트)
 │                            │
 │ ═══════════════════════════│
 │ [strip image 배경]          │
 │ ═══════════════════════════│
 │                            │
 │    [primaryFields]         │  ← 회원 이름
 │                            │
 │ [secondary]  [secondary]   │  ← 등급, 포인트
 │                            │
 │ [auxiliary]  [auxiliary]   │  ← 가입일, 유효기간
 │                            │
 │ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ │  ← 바코드
 │         123456789          │
 └─────────────────────────────┘
*/

// 02-05-field-types.swift
/*
 필드 데이터 타입:
 - dateStyle: "PKDateStyleShort", "PKDateStyleMedium"
 - timeStyle: "PKTimeStyleShort"
 - currencyCode: "KRW"
 - numberStyle: "PKNumberStyleDecimal"
*/

// 02-06-image-assets.swift
/*
 필요한 이미지 에셋:
 
 icon.png      (29×29)   icon@2x.png   (58×58)   icon@3x.png   (87×87)
 logo.png      (160×50)  logo@2x.png   (320×100) logo@3x.png   (480×150)
 strip.png     (375×123) strip@2x.png  (750×246) strip@3x.png  (1125×369)
*/

// 02-08-barcode.swift
/*
 바코드 형식:
 {
   "barcodes": [{
     "format": "PKBarcodeFormatQR",
     "message": "MEMBER123456",
     "messageEncoding": "iso-8859-1"
   }]
 }
*/

// 02-09-nfc.swift
/*
 NFC 설정 (지원 기기에서 탭으로 인식):
 {
   "nfc": {
     "message": "MEMBER123456",
     "encryptionPublicKey": "..."
   }
 }
*/

// MARK: - Chapter 3: 패스 디자인 (pass.json)

// 03-01-basic-pass.swift
let basicPassJson = """
{
    "formatVersion": 1,
    "passTypeIdentifier": "pass.com.myapp.membership",
    "serialNumber": "MEMBER123456",
    "teamIdentifier": "ABCD1234EF",
    "organizationName": "MyStore",
    "description": "MyStore 멤버십 카드",
    
    "storeCard": {
        "primaryFields": [],
        "secondaryFields": [],
        "auxiliaryFields": [],
        "backFields": []
    }
}
"""

// 03-02-colors.swift
let colorConfig = """
{
    "backgroundColor": "rgb(25, 25, 112)",
    "foregroundColor": "rgb(255, 255, 255)",
    "labelColor": "rgb(200, 200, 200)"
}
"""

// 03-03-primary-fields.swift
let primaryFieldsJson = """
{
    "primaryFields": [{
        "key": "memberName",
        "label": "회원 이름",
        "value": "홍길동"
    }]
}
"""

// 03-04-secondary-fields.swift
let secondaryFieldsJson = """
{
    "secondaryFields": [
        {
            "key": "points",
            "label": "포인트",
            "value": 12500,
            "numberStyle": "PKNumberStyleDecimal"
        },
        {
            "key": "tier",
            "label": "등급",
            "value": "Gold"
        }
    ]
}
"""

// 03-05-auxiliary-fields.swift
let auxiliaryFieldsJson = """
{
    "auxiliaryFields": [
        {
            "key": "joinDate",
            "label": "가입일",
            "value": "2024-01-15T00:00:00Z",
            "dateStyle": "PKDateStyleMedium"
        },
        {
            "key": "expiryDate",
            "label": "유효기간",
            "value": "2025-01-14T23:59:59Z",
            "dateStyle": "PKDateStyleMedium"
        }
    ]
}
"""

// 03-06-back-fields.swift
let backFieldsJson = """
{
    "backFields": [
        {
            "key": "terms",
            "label": "이용약관",
            "value": "본 멤버십 카드는 MyStore 전 매장에서 사용 가능합니다..."
        },
        {
            "key": "contact",
            "label": "고객센터",
            "value": "1588-0000\\nmystore@example.com"
        }
    ]
}
"""

// 03-07-barcode-config.swift
let barcodeConfig = """
{
    "barcodes": [
        {
            "format": "PKBarcodeFormatQR",
            "message": "MEMBER123456",
            "messageEncoding": "iso-8859-1",
            "altText": "123456"
        },
        {
            "format": "PKBarcodeFormatPDF417",
            "message": "MEMBER123456",
            "messageEncoding": "iso-8859-1"
        }
    ]
}
"""

// 03-09-locations.swift
let locationsJson = """
{
    "locations": [
        {
            "latitude": 37.5665,
            "longitude": 126.9780,
            "relevantText": "서울 본점 근처입니다!"
        },
        {
            "latitude": 35.1796,
            "longitude": 129.0756,
            "relevantText": "부산점 방문을 환영합니다!"
        }
    ],
    "maxDistance": 500
}
"""

// 03-10-relevant-date.swift
let relevantDateJson = """
{
    "relevantDate": "2024-12-25T09:00:00+09:00"
}
"""

// 03-11-complete-pass.swift
let completePassJson = """
{
    "formatVersion": 1,
    "passTypeIdentifier": "pass.com.myapp.membership",
    "serialNumber": "MEMBER123456",
    "teamIdentifier": "ABCD1234EF",
    "organizationName": "MyStore",
    "description": "MyStore 멤버십 카드",
    
    "backgroundColor": "rgb(25, 25, 112)",
    "foregroundColor": "rgb(255, 255, 255)",
    "labelColor": "rgb(200, 200, 200)",
    
    "logoText": "MyStore",
    
    "storeCard": {
        "headerFields": [{
            "key": "balance",
            "label": "잔액",
            "value": 50000,
            "currencyCode": "KRW"
        }],
        "primaryFields": [{
            "key": "memberName",
            "label": "회원 이름",
            "value": "홍길동"
        }],
        "secondaryFields": [
            {"key": "points", "label": "포인트", "value": 12500},
            {"key": "tier", "label": "등급", "value": "Gold"}
        ],
        "auxiliaryFields": [
            {"key": "joinDate", "label": "가입일", "value": "2024-01-15T00:00:00Z", "dateStyle": "PKDateStyleShort"}
        ],
        "backFields": [
            {"key": "terms", "label": "이용약관", "value": "..."}
        ]
    },
    
    "barcodes": [{
        "format": "PKBarcodeFormatQR",
        "message": "MEMBER123456",
        "messageEncoding": "iso-8859-1"
    }],
    
    "locations": [{
        "latitude": 37.5665,
        "longitude": 126.9780,
        "relevantText": "포인트 2배 적립 중!"
    }]
}
"""
