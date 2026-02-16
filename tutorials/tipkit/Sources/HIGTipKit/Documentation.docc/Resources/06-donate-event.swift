import SwiftUI
import TipKit

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    let filterTip = SearchFilterTip()
    
    var body: some View {
        NavigationStack {
            List {
                // 팁 표시 (조건 충족 시)
                TipView(filterTip)
                
                ForEach(searchResults, id: \.self) { result in
                    Text(result)
                }
            }
            .searchable(text: $searchText)
            .onSubmit(of: .search) {
                performSearch()
            }
        }
    }
    
    func performSearch() {
        // 검색 실행
        searchResults = ["결과 1", "결과 2", "결과 3"]
        
        // 🔑 이벤트 기록 (donate)
        // 검색할 때마다 호출하여 횟수 누적
        SearchFilterTip.searchPerformed.donate()
        
        // 5번째 검색 후 필터 팁이 표시됨!
    }
}
