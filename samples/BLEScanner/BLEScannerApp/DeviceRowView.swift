//
//  DeviceRowView.swift
//  BLEScanner
//
//  발견된 BLE 기기를 리스트에 표시하는 Row 뷰
//

import SwiftUI
import CoreBluetooth

/// 기기 목록의 개별 Row 뷰
struct DeviceRowView: View {
    
    // MARK: - Properties
    
    /// 표시할 기기
    @ObservedObject var device: DiscoveredDevice
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            // 신호 강도 아이콘
            signalIndicator
            
            // 기기 정보
            deviceInfo
            
            Spacer()
            
            // 연결 상태 / RSSI
            trailingInfo
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - 신호 강도 표시
    
    private var signalIndicator: some View {
        ZStack {
            Circle()
                .fill(signalColor.opacity(0.15))
                .frame(width: 44, height: 44)
            
            Image(systemName: device.signalStrength.symbolName)
                .font(.system(size: 20))
                .foregroundColor(signalColor)
        }
    }
    
    /// 신호 강도에 따른 색상
    private var signalColor: Color {
        switch device.signalStrength {
        case .excellent:
            return .green
        case .good:
            return .blue
        case .fair:
            return .orange
        case .weak:
            return .red
        }
    }
    
    // MARK: - 기기 정보
    
    private var deviceInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 기기 이름
            HStack(spacing: 6) {
                Text(device.name)
                    .font(.headline)
                    .lineLimit(1)
                
                // 연결 가능 여부 표시
                if device.isConnectable {
                    Image(systemName: "link")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                // 연결 상태 표시
                if device.connectionState == .connected {
                    Text("연결됨")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            
            // UUID (축약)
            Text(device.id.uuidString.prefix(18) + "...")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            // 광고 서비스 표시
            if !device.advertisedServiceUUIDs.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "cube.box")
                        .font(.caption2)
                    
                    Text(servicesSummary)
                        .font(.caption2)
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    /// 광고 서비스 요약
    private var servicesSummary: String {
        let services = device.advertisedServiceUUIDs
        let names = services.compactMap { StandardBLEService.name(for: $0) }
        
        if names.isEmpty {
            return "\(services.count)개 서비스"
        } else if names.count <= 2 {
            return names.joined(separator: ", ")
        } else {
            return "\(names[0]) 외 \(names.count - 1)개"
        }
    }
    
    // MARK: - 오른쪽 정보
    
    private var trailingInfo: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // RSSI 값
            HStack(spacing: 2) {
                Text("\(device.rssi)")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                Text("dBm")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 마지막 발견 시간
            Text(lastSeenText)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 연결 중 표시
            if device.connectionState == .connecting {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
    }
    
    /// 마지막 발견 시간 텍스트
    private var lastSeenText: String {
        let interval = Date().timeIntervalSince(device.lastSeen)
        
        if interval < 5 {
            return "방금"
        } else if interval < 60 {
            return "\(Int(interval))초 전"
        } else {
            return "\(Int(interval / 60))분 전"
        }
    }
}

// MARK: - RSSI 시각화 컴포넌트

/// RSSI 막대 그래프 뷰
struct RSSIBarView: View {
    let rssi: Int
    
    /// RSSI를 0~1 범위로 정규화
    private var normalizedRSSI: Double {
        // RSSI 범위: -100 (약함) ~ -30 (강함)
        let clamped = min(max(Double(rssi), -100), -30)
        return (clamped + 100) / 70  // 0~1 범위로 변환
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.2))
                
                // 채워진 부분
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor)
                    .frame(width: geometry.size.width * normalizedRSSI)
            }
        }
        .frame(height: 6)
    }
    
    /// 강도에 따른 색상
    private var barColor: Color {
        if normalizedRSSI > 0.7 {
            return .green
        } else if normalizedRSSI > 0.4 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Preview

#Preview("기기 Row") {
    List {
        // 미리보기용 더미 데이터
        VStack {
            Text("실제 기기 데이터는 CoreBluetooth 사용 시 표시됩니다")
                .foregroundColor(.secondary)
        }
    }
}
