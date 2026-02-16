import SwiftUI
import MapKit

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Binding var selectedRestaurant: Restaurant?
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isSearching {
                    HStack {
                        ProgressView()
                        Text("검색 중...")
                    }
                }
                
                ForEach(viewModel.searchResults) { restaurant in
                    Button {
                        selectedRestaurant = restaurant
                    } label: {
                        SearchResultRow(restaurant: restaurant)
                    }
                }
            }
            .navigationTitle("맛집 검색")
            .searchable(
                text: $viewModel.searchText,
                prompt: "맛집 이름 또는 종류"
            )
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.search()
            }
        }
    }
}

struct SearchResultRow: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack {
            Image(systemName: restaurant.category.icon)
                .foregroundStyle(restaurant.category.color)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.headline)
                
                Text(restaurant.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
