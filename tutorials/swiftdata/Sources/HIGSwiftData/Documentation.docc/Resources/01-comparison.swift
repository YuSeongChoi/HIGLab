import Foundation

// ╔═══════════════════════════════════════════════════════════════════╗
// ║               Core Data vs SwiftData 비교표                        ║
// ╠═══════════════════════════════════════════════════════════════════╣
// ║ 항목              │ Core Data           │ SwiftData              ║
// ╠═══════════════════════════════════════════════════════════════════╣
// ║ 모델 정의         │ .xcdatamodeld 파일   │ @Model 매크로           ║
// ║ 베이스 클래스     │ NSManagedObject      │ 순수 Swift 클래스       ║
// ║ 쿼리              │ NSFetchRequest       │ @Query                 ║
// ║ 필터              │ NSPredicate (문자열) │ #Predicate (타입 안전)  ║
// ║ 컨텍스트          │ NSManagedObjectContext│ ModelContext          ║
// ║ 스토어            │ NSPersistentContainer│ ModelContainer         ║
// ║ 변경 추적         │ 수동 관리 필요       │ 자동                    ║
// ║ SwiftUI 통합      │ @FetchRequest        │ @Query                 ║
// ║ 최소 버전         │ iOS 3               │ iOS 17                 ║
// ║ CloudKit          │ 복잡한 설정 필요     │ 간단한 설정             ║
// ╚═══════════════════════════════════════════════════════════════════╝

// 코드량 비교
// Core Data: ~200줄 (스택 설정 + 모델 + Fetch)
// SwiftData: ~30줄 (같은 기능)

// 학습 곡선
// Core Data: 급경사 📈📈📈
// SwiftData: 완만 📈

// 디버깅 난이도
// Core Data: "The operation couldn't be completed" 🤯
// SwiftData: 명확한 Swift 에러 메시지 😌
