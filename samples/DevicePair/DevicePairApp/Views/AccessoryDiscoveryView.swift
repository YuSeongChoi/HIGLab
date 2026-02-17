//
//  AccessoryDiscoveryView.swift
//  DevicePair
//
//  액세서리 검색 뷰 - 새 기기를 검색하고 페어링하는 UI
//

import SwiftUI

// MARK: - 액세서리 검색 뷰

/// 주변 액세서리를 검색하고 페어링하는 뷰
struct AccessoryDiscoveryView: View {
    
    @EnvironmentObject private var sessionManager: AccessorySessionManager
    
    /// 애니메이션 상태
    @State private var isAnimating = false
    
    /// 선택된 발견 액세서리
    @State private var selectedDiscovered: DiscoveredAccessory?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 상태 표시 영역
                    statusSection
                    
                    // 검색 버튼 또는 진행 상태
                    actionSection
                    
                    // 발견된 기기 목록
                    if !sessionManager.discoveredAccessories.isEmpty {
                        discoveredAccessoriesSection
                    }
                    
                    // 페어링 팁
                    tipsSection
                }
                .padding()
            }
            .navigationTitle("기기 추가")
            .sheet(item: $selectedDiscovered) { discovered in
                PairingConfirmationSheet(discovered: discovered) {
                    sessionManager.pairAccessory(discovered)
                    selectedDiscovered = nil
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    // MARK: - 상태 표시 섹션
    
    private var statusSection: some View {
        VStack(spacing: 16) {
            // 애니메이션 아이콘
            ZStack {
                // 외부 펄스 링
                if sessionManager.pairingState.isInProgress {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                            .frame(width: 120 + CGFloat(index * 30), height: 120 + CGFloat(index * 30))
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .opacity(isAnimating ? 0 : 0.6)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                                value: isAnimating
                            )
                    }
                }
                
                // 중앙 원
                Circle()
                    .fill(statusBackgroundGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: statusColor.opacity(0.3), radius: 10, y: 5)
                
                // 상태 아이콘
                Image(systemName: sessionManager.pairingState.iconName)
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .symbolEffect(
                        .pulse,
                        options: .repeating,
                        isActive: sessionManager.pairingState.isInProgress
                    )
            }
            .frame(height: 180)
            .onAppear {
                isAnimating = true
            }
            
            // 상태 텍스트
            VStack(spacing: 8) {
                Text(statusTitle)
                    .font(.title3.bold())
                
                Text(sessionManager.pairingState.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // 진행률 바 (진행 중일 때만)
            if sessionManager.pairingState.isInProgress {
                ProgressView(value: sessionManager.pairingState.progress)
                    .tint(.blue)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    private var statusBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [statusColor, statusColor.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var statusColor: Color {
        switch sessionManager.pairingState {
        case .idle: return .blue
        case .discovering, .pairing, .authenticating, .configuring: return .blue
        case .discovered: return .green
        case .completed: return .green
        case .failed: return .red
        case .cancelled: return .orange
        }
    }
    
    private var statusTitle: String {
        switch sessionManager.pairingState {
        case .idle: return "기기 추가 준비 완료"
        case .discovering: return "검색 중..."
        case .discovered: return "기기 발견!"
        case .pairing: return "페어링 중..."
        case .authenticating: return "인증 중..."
        case .configuring: return "설정 중..."
        case .completed: return "페어링 완료!"
        case .failed: return "페어링 실패"
        case .cancelled: return "취소됨"
        }
    }
    
    // MARK: - 액션 섹션
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            switch sessionManager.pairingState {
            case .idle, .cancelled:
                // 검색 시작 버튼
                Button {
                    sessionManager.startDiscovery()
                } label: {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("기기 검색")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
            case .discovering:
                // 검색 중지 버튼
                Button {
                    sessionManager.stopDiscovery()
                } label: {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("검색 중지")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
            case .failed:
                // 재시도 버튼
                VStack(spacing: 12) {
                    Button {
                        sessionManager.retryPairing()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("다시 시도")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Button {
                        sessionManager.resetPairingState()
                    } label: {
                        Text("취소")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
            case .completed:
                // 완료 후 추가 검색 버튼
                Button {
                    sessionManager.resetPairingState()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("다른 기기 추가")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
            default:
                // 진행 중일 때는 버튼 없음
                EmptyView()
            }
        }
    }
    
    // MARK: - 발견된 액세서리 섹션
    
    private var discoveredAccessoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("발견된 기기")
                .font(.headline)
            
            ForEach(sessionManager.discoveredAccessories) { discovered in
                DiscoveredAccessoryCard(discovered: discovered) {
                    selectedDiscovered = discovered
                }
            }
        }
    }
    
    // MARK: - 팁 섹션
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("페어링 팁")
                .font(.headline)
            
            VStack(spacing: 10) {
                TipRow(
                    icon: "bolt.fill",
                    title: "전원 확인",
                    description: "액세서리의 전원이 켜져 있는지 확인하세요"
                )
                
                TipRow(
                    icon: "antenna.radiowaves.left.and.right",
                    title: "페어링 모드",
                    description: "액세서리를 페어링 모드로 설정하세요"
                )
                
                TipRow(
                    icon: "location.fill",
                    title: "가까이 위치",
                    description: "액세서리를 iPhone 가까이에 두세요"
                )
                
                TipRow(
                    icon: "wifi",
                    title: "블루투스 확인",
                    description: "블루투스가 켜져 있는지 확인하세요"
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - 발견된 액세서리 카드

struct DiscoveredAccessoryCard: View {
    let discovered: DiscoveredAccessory
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                // 카테고리 아이콘
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(discovered.category.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: discovered.category.iconName)
                        .font(.title3)
                        .foregroundStyle(discovered.category.color)
                }
                
                // 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(discovered.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 8) {
                        // 신호 강도
                        HStack(spacing: 4) {
                            Image(systemName: discovered.signalIcon)
                                .font(.caption2)
                            Text(discovered.signalStrengthDescription)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        
                        // 페어링 가능 여부
                        if discovered.isReadyToPair {
                            Text("페어링 가능")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.15))
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue.opacity(0.8))
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 팁 행

struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - 페어링 확인 시트

struct PairingConfirmationSheet: View {
    let discovered: DiscoveredAccessory
    let onConfirm: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(discovered.category.color.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: discovered.category.iconName)
                    .font(.system(size: 32))
                    .foregroundStyle(discovered.category.color)
            }
            
            // 정보
            VStack(spacing: 8) {
                Text(discovered.name)
                    .font(.title2.bold())
                
                Text(discovered.category.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // 설명
            Text("이 기기와 페어링하시겠습니까?")
                .font(.body)
                .foregroundStyle(.secondary)
            
            // 버튼
            VStack(spacing: 12) {
                Button {
                    onConfirm()
                } label: {
                    Text("페어링")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("취소")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - 미리보기

#Preview {
    AccessoryDiscoveryView()
        .environmentObject(AccessorySessionManager())
}
