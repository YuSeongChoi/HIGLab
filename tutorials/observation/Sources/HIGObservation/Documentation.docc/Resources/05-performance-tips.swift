import SwiftUI
import Observation

/// 성능 측정 및 최적화 팁

// MARK: - 1. Instruments 사용

/*
 Xcode Instruments의 "SwiftUI" 프로파일러로 측정할 수 있습니다:
 
 1. Product → Profile (Cmd + I)
 2. SwiftUI 템플릿 선택
 3. 녹화 시작 후 앱 조작
 4. View Body 트랙에서 업데이트 횟수 확인
 
 💡 팁: 빨간색으로 표시된 "slow" 뷰에 주목하세요.
*/

// MARK: - 2. Debug Overlay

#if DEBUG
struct PerformanceOverlay: ViewModifier {
    @State private var updateCount = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Text("Updates: \(updateCount)")
                    .font(.caption2)
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .onAppear { updateCount += 1 }
            }
    }
}

extension View {
    func debugUpdateCount() -> some View {
        modifier(PerformanceOverlay())
    }
}
#endif

// MARK: - 3. 최적화 체크리스트

/*
 ✅ 뷰 분리
 - 각 뷰가 필요한 프로퍼티만 읽는지?
 - 자주 변하는 데이터와 정적 데이터 분리?
 
 ✅ 계산 비용
 - body에서 무거운 계산 피하기
 - 계산 프로퍼티 대신 캐시된 값 사용?
 
 ✅ 컬렉션 최적화
 - LazyVStack/LazyHStack 사용?
 - ForEach에 적절한 id 제공?
 
 ✅ 이미지 처리
 - 비동기 이미지 로딩?
 - 적절한 크기로 리사이즈?
*/

// MARK: - 4. Computed Property 주의사항

@Observable
class CachedStore {
    var items: [String] = []
    
    // ❌ 매번 정렬하면 느림
    var sortedItemsBad: [String] {
        items.sorted() // 매 접근마다 정렬!
    }
    
    // ✅ 캐시 사용
    private var _cachedSortedItems: [String]?
    var sortedItemsGood: [String] {
        if let cached = _cachedSortedItems {
            return cached
        }
        let sorted = items.sorted()
        // 주의: @Observable에서는 이 방식이 복잡해질 수 있음
        return sorted
    }
    
    // ✅ 더 나은 방법: 변경 시점에 정렬
    private(set) var sortedItems: [String] = []
    
    func addItem(_ item: String) {
        items.append(item)
        sortedItems = items.sorted() // 변경 시점에 한 번만 정렬
    }
}
