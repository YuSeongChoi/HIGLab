//
//  ContentView.swift
//  VisionScanner
//
//  기능 선택 메인 화면
//

import SwiftUI

/// 메인 화면 - Vision 기능 선택
struct ContentView: View {
    
    /// Vision 매니저
    @EnvironmentObject var visionManager: VisionManager
    
    var body: some View {
        NavigationStack {
            List {
                // 헤더 섹션
                Section {
                    headerView
                }
                .listRowBackground(Color.clear)
                
                // 기능 선택 섹션
                Section("Vision 기능") {
                    // 텍스트 인식 (OCR)
                    NavigationLink {
                        TextRecognitionView()
                    } label: {
                        featureRow(
                            icon: "doc.text.viewfinder",
                            iconColor: .blue,
                            title: "텍스트 인식",
                            subtitle: "이미지에서 텍스트를 추출합니다 (OCR)"
                        )
                    }
                    
                    // 바코드/QR 스캔
                    NavigationLink {
                        BarcodeView()
                    } label: {
                        featureRow(
                            icon: "barcode.viewfinder",
                            iconColor: .green,
                            title: "바코드 스캔",
                            subtitle: "바코드와 QR 코드를 인식합니다"
                        )
                    }
                    
                    // 얼굴 인식
                    NavigationLink {
                        FaceDetectionView()
                    } label: {
                        featureRow(
                            icon: "face.smiling",
                            iconColor: .orange,
                            title: "얼굴 인식",
                            subtitle: "이미지에서 얼굴을 감지합니다"
                        )
                    }
                }
                
                // 정보 섹션
                Section("정보") {
                    infoRow(title: "Vision 프레임워크", value: "iOS 11+")
                    infoRow(title: "지원 기능", value: "OCR, 바코드, 얼굴")
                    infoRow(title: "처리 방식", value: "온디바이스")
                }
            }
            .navigationTitle("VisionScanner")
        }
    }
    
    // MARK: - 서브뷰
    
    /// 헤더 뷰
    private var headerView: some View {
        VStack(spacing: 16) {
            // 앱 아이콘
            Image(systemName: "eye.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 앱 설명
            Text("Apple Vision 프레임워크를 활용한\n이미지 분석 샘플 앱")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    /// 기능 행 뷰
    /// - Parameters:
    ///   - icon: SF Symbol 이름
    ///   - iconColor: 아이콘 색상
    ///   - title: 제목
    ///   - subtitle: 부제목
    private func featureRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 16) {
            // 아이콘
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // 텍스트
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    /// 정보 행 뷰
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    ContentView()
        .environmentObject(VisionManager())
}
