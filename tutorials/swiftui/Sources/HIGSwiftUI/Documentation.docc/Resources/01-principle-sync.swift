import SwiftUI

// 원칙 3: 자동 동기화 (Automatic Synchronization)
// 데이터가 바뀌면 UI가 자동으로 따라갑니다!

struct AutoSyncExample: View {
    @State private var servings = 2
    @State private var ingredients = ["돼지고기 150g", "김치 200g", "두부 1/2모"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 인원 수 조절
            Stepper("인원: \(servings)명", value: $servings, in: 1...10)
            
            Divider()
            
            // 재료 목록 - servings에 따라 자동 업데이트!
            Text("재료 (\(servings)인분 기준)")
                .font(.headline)
            
            ForEach(ingredients, id: \.self) { ingredient in
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.green)
                    Text(adjustAmount(ingredient, for: servings))
                }
            }
        }
        .padding()
    }
    
    // 인원 수에 맞게 재료 양 조절
    func adjustAmount(_ ingredient: String, for servings: Int) -> String {
        // 기본 2인분 기준으로 계산
        let multiplier = Double(servings) / 2.0
        return "\(ingredient) × \(String(format: "%.1f", multiplier))"
    }
}

// servings 값만 바꾸면 모든 재료 양이 자동 업데이트!
// 수동으로 UI 갱신할 필요 없음!

#Preview {
    AutoSyncExample()
}
