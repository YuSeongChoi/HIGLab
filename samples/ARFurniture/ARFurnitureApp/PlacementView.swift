//
//  PlacementView.swift
//  ARFurniture
//
//  가구 배치 컨트롤 뷰
//

import SwiftUI

/// 배치 컨트롤 뷰
struct PlacementView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var arManager: ARManager
    
    /// 회전 각도 (도)
    @State private var rotationAngle: Double = 0
    
    /// 크기 비율 (1.0 = 100%)
    @State private var scaleFactor: Double = 1.0
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // 선택된 가구 정보
            if let item = arManager.selectedFurniture {
                selectedItemInfo(item)
            }
            
            // 조절 컨트롤
            controlsSection
            
            // 액션 버튼
            actionButtons
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
    }
    
    // MARK: - Selected Item Info
    
    /// 선택된 가구 정보
    private func selectedItemInfo(_ item: FurnitureItem) -> some View {
        HStack(spacing: 12) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: item.category.iconName)
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.formattedPrice)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 변경 버튼
            Button {
                arManager.selectedFurniture = nil
                arManager.removePreview()
            } label: {
                Text("변경")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - Controls Section
    
    /// 조절 컨트롤 섹션
    private var controlsSection: some View {
        VStack(spacing: 12) {
            // 회전 컨트롤
            rotationControl
            
            // 크기 컨트롤
            scaleControl
        }
    }
    
    /// 회전 컨트롤
    private var rotationControl: some View {
        VStack(spacing: 8) {
            HStack {
                Label("회전", systemImage: "rotate.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(rotationAngle))°")
                    .font(.subheadline.monospacedDigit())
            }
            
            HStack(spacing: 16) {
                // 45° 회전 버튼들
                ForEach([0, 45, 90, 135, 180], id: \.self) { angle in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            rotationAngle = Double(angle)
                            applyRotation()
                        }
                    } label: {
                        Text("\(angle)°")
                            .font(.caption.bold())
                            .foregroundColor(rotationAngle == Double(angle) ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                rotationAngle == Double(angle)
                                    ? AnyShapeStyle(Color.blue)
                                    : AnyShapeStyle(Color(.systemGray5))
                            )
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    /// 크기 컨트롤
    private var scaleControl: some View {
        VStack(spacing: 8) {
            HStack {
                Label("크기", systemImage: "arrow.up.left.and.arrow.down.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(scaleFactor * 100))%")
                    .font(.subheadline.monospacedDigit())
            }
            
            Slider(value: $scaleFactor, in: 0.5...2.0, step: 0.1) { _ in
                applyScale()
            }
            .tint(.blue)
        }
    }
    
    // MARK: - Action Buttons
    
    /// 액션 버튼
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // 취소 버튼
            Button {
                cancelPlacement()
            } label: {
                HStack {
                    Image(systemName: "xmark")
                    Text("취소")
                }
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            // 배치 안내
            VStack(spacing: 4) {
                Image(systemName: "hand.tap.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("평면을 탭하여 배치")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Actions
    
    /// 회전 적용
    private func applyRotation() {
        guard let previewEntity = arManager.previewEntity else { return }
        
        let radians = Float(rotationAngle) * .pi / 180
        previewEntity.transform.rotation = simd_quatf(angle: radians, axis: [0, 1, 0])
    }
    
    /// 크기 적용
    private func applyScale() {
        guard let previewEntity = arManager.previewEntity else { return }
        
        let scale = Float(scaleFactor)
        previewEntity.scale = SIMD3<Float>(repeating: scale)
    }
    
    /// 배치 취소
    private func cancelPlacement() {
        arManager.removePreview()
        arManager.selectedFurniture = nil
        rotationAngle = 0
        scaleFactor = 1.0
    }
}

// MARK: - Placed Furniture List

/// 배치된 가구 목록 뷰
struct PlacedFurnitureListView: View {
    
    @EnvironmentObject var arManager: ARManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if arManager.placedFurnitures.isEmpty {
                    emptyState
                } else {
                    furnitureList
                }
            }
            .navigationTitle("배치된 가구")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                
                if !arManager.placedFurnitures.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("전체 삭제") {
                            arManager.removeAllFurniture()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    /// 빈 상태
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("배치된 가구가 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("카탈로그에서 가구를 선택하고\n평면을 탭하여 배치하세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// 가구 목록
    private var furnitureList: some View {
        List {
            ForEach(arManager.placedFurnitures) { furniture in
                PlacedFurnitureRow(furniture: furniture)
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    let furniture = arManager.placedFurnitures[index]
                    arManager.removeFurniture(furniture)
                }
            }
        }
    }
}

/// 배치된 가구 행
struct PlacedFurnitureRow: View {
    
    let furniture: PlacedFurniture
    @EnvironmentObject var arManager: ARManager
    
    var body: some View {
        HStack(spacing: 12) {
            // 아이콘
            Image(systemName: furniture.item.category.iconName)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(furniture.item.name)
                    .font(.subheadline.bold())
                
                Text(formatDate(furniture.placedAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 삭제 버튼
            Button {
                arManager.removeFurniture(furniture)
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
    
    /// 날짜 포맷팅
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        PlacementView()
    }
    .background(Color.black)
    .environmentObject(ARManager())
}
