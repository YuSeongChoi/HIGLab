import HealthKit

// MARK: - Predicate로 조회 기간 지정

// 오늘 자정부터 현재까지
let calendar = Calendar.current
let now = Date()
let startOfDay = calendar.startOfDay(for: now)

let todayPredicate = HKQuery.predicateForSamples(
    withStart: startOfDay,
    end: now,
    options: .strictStartDate  // startDate 이후 샘플만
)

// 지난 7일
let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!

let weekPredicate = HKQuery.predicateForSamples(
    withStart: sevenDaysAgo,
    end: now,
    options: .strictStartDate
)

// 특정 소스(기기)로 필터링
let sourcePredigate = HKQuery.predicateForObjects(
    from: HKSource.default()  // 이 앱에서 저장한 데이터만
)

// 여러 조건 결합
let combinedPredicate = NSCompoundPredicate(
    andPredicateWithSubpredicates: [todayPredicate, sourcePredigate]
)
