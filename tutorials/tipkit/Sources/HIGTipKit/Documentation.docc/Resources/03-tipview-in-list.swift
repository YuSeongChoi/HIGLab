import SwiftUI
import TipKit

struct FeaturesTip: Tip {
    var title: Text {
        Text("기능 둘러보기")
    }
    
    var message: Text? {
        Text("아래 기능들을 탭하여 자세히 알아보세요")
    }
    
    var image: Image? {
        Image(systemName: "list.bullet.circle")
    }
}

struct FeatureListView: View {
    let featuresTip = FeaturesTip()
    
    let features = ["사진 편집", "필터 적용", "공유하기", "내보내기"]
    
    var body: some View {
        NavigationStack {
            List {
                // 리스트 상단에 팁 삽입
                // 다른 셀들과 자연스럽게 어우러짐
                TipView(featuresTip)
                
                ForEach(features, id: \.self) { feature in
                    NavigationLink(feature) {
                        Text("\(feature) 상세 화면")
                    }
                }
            }
            .navigationTitle("기능")
        }
    }
}
