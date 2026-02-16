import SwiftUI

// ContentView.swift
// ChefBook의 첫 화면!

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            // 앱 아이콘
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
            
            // 앱 이름
            Text("ChefBook")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // 서브타이틀
            Text("나만의 레시피를 저장하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
