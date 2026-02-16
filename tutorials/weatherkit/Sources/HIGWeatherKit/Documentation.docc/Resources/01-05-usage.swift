import WeatherKit

// API 사용량 모니터링
// App Store Connect > App Analytics > WeatherKit

/*
 요금 구조:
 - 무료: 월 500,000건
 - 유료: 1,000,000건당 $0.50
 
 API 호출 계산 방식:
 - 각 DataSet 요청이 1건으로 계산
 - .current + .hourly 동시 요청 = 2건
 */

// 효율적인 API 사용을 위한 팁
// 1. 필요한 DataSet만 요청
// 2. 결과 캐싱
// 3. 백그라운드 새로고침 최적화
