import SwiftUI

struct RestrictedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
            
            VStack(spacing: 8) {
                Text("접근이 제한됨")
                    .font(.title)
                    .bold()
                
                Text("Apple Music 접근이 시스템 수준에서\n제한되어 있습니다.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            // 설명
            VStack(alignment: .leading, spacing: 8) {
                Text("다음과 같은 이유일 수 있습니다:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                BulletPoint(text: "자녀 보호 기능")
                BulletPoint(text: "스크린 타임 제한")
                BulletPoint(text: "MDM(기업/학교) 정책")
            }
            .padding()
            .background(.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            Spacer()
            
            Text("기기 관리자에게 문의하세요.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .frame(width: 4, height: 4)
            Text(text)
                .font(.subheadline)
        }
        .foregroundStyle(.secondary)
    }
}
