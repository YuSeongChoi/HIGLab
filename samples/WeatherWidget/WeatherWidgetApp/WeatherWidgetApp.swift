import SwiftUI

@main
struct WeatherWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 앱 헤더
                VStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 60))
                        .symbolRenderingMode(.multicolor)
                    
                    Text("HIG 날씨 위젯")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("홈 화면에 위젯을 추가해보세요!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                // 위젯 추가 안내
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("위젯 추가 방법", systemImage: "plus.circle.fill")
                            .font(.headline)
                        
                        HowToStep(number: 1, text: "홈 화면을 길게 누르세요")
                        HowToStep(number: 2, text: "왼쪽 상단 + 버튼을 탭하세요")
                        HowToStep(number: 3, text: "'날씨'를 검색하세요")
                        HowToStep(number: 4, text: "원하는 크기를 선택하고 추가하세요")
                    }
                }
                .padding(.horizontal)
                
                // HIG 가이드 링크
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("HIG 위젯 가이드라인", systemImage: "book.fill")
                            .font(.headline)
                        
                        Text("이 위젯은 Apple Human Interface Guidelines의 위젯 디자인 원칙을 따릅니다.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Link("Apple HIG 보기 →",
                             destination: URL(string: "https://developer.apple.com/design/human-interface-guidelines/widgets/")!)
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("")
        }
    }
}

struct HowToStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 24, height: 24)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    ContentView()
}
