import SwiftUI
import TipKit

// MARK: - 팝오버 팁 예제 뷰
// .popoverTip() 수정자를 사용하여 특정 UI 요소에 팁을 연결하는 방법을 시연합니다.
// 팝오버 팁은 특정 버튼이나 컨트롤 위에 말풍선 형태로 표시됩니다.

struct PopoverTipView: View {
    
    // MARK: - 팁 인스턴스
    
    /// 공유 팁
    private let shareTip = ShareTip()
    
    /// 다크 모드 팁
    private let darkModeTip = DarkModeTip()
    
    /// 알림 팁
    private let notificationTip = NotificationTip()
    
    /// 위젯 팁
    private let widgetTip = WidgetTip()
    
    // MARK: - 상태
    
    @State private var showShareSheet = false
    @State private var isDarkModeEnabled = false
    @State private var notificationsEnabled = false
    @State private var showActionAlert = false
    @State private var actionAlertMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - 소개 섹션
                    introSection
                    
                    // MARK: - 공유 버튼 예제
                    shareButtonSection
                    
                    // MARK: - 다중 팝오버 예제
                    multiplePopoversSection
                    
                    // MARK: - 화살표 방향 옵션
                    arrowEdgeSection
                    
                    // MARK: - API 설명
                    apiExplanationSection
                }
                .padding()
            }
            .navigationTitle("팝오버 팁")
            .sheet(isPresented: $showShareSheet) {
                ShareSheetView()
            }
            .alert("알림", isPresented: $showActionAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(actionAlertMessage)
            }
        }
    }
    
    // MARK: - 소개 섹션
    
    private var introSection: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(
                    icon: "bubble.left.fill",
                    title: ".popoverTip()",
                    description: "특정 UI 요소에 팁을 연결합니다. 팁은 해당 요소 근처에 말풍선으로 표시됩니다.",
                    iconColor: .purple
                )
                
                Divider()
                
                Text("팝오버 팁은 특정 버튼이나 기능을 처음 발견하도록 유도할 때 효과적입니다. 화살표가 대상 요소를 가리킵니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 공유 버튼 섹션
    
    private var shareButtonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("공유 버튼 팝오버", subtitle: "기본 팝오버 팁 사용법")
            
            // 콘텐츠 카드
            CardContainer {
                VStack(spacing: 20) {
                    // 샘플 이미지
                    ZStack {
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        Image(systemName: "photo.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // 콘텐츠 정보
                    VStack(spacing: 8) {
                        Text("멋진 사진")
                            .font(.headline)
                        
                        Text("이 콘텐츠를 친구들과 공유해보세요!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 공유 버튼 - 팝오버 팁 연결
                    Button {
                        showShareSheet = true
                        shareTip.invalidate(reason: .actionPerformed)
                        FeatureDiscoveryParameters.hasUsedSharing = true
                        
                        Task {
                            await TipEventRecorder.recordContentShared()
                        }
                    } label: {
                        Label("공유하기", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    // 팝오버 팁 연결 - 화살표가 아래를 향함
                    .popoverTip(shareTip, arrowEdge: .bottom)
                }
            }
            
            // 코드 예제
            CodeSnippet(
                """
                Button("공유하기") {
                    // 공유 액션
                }
                .popoverTip(shareTip, arrowEdge: .bottom)
                """
            )
        }
    }
    
    // MARK: - 다중 팝오버 섹션
    
    private var multiplePopoversSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("다중 팝오버 팁", subtitle: "여러 UI 요소에 팁 연결")
            
            // 설정 옵션들
            CardContainer {
                VStack(spacing: 0) {
                    // 다크 모드 토글
                    SettingsRow(
                        icon: "moon.fill",
                        title: "다크 모드",
                        color: .purple
                    ) {
                        Toggle("", isOn: $isDarkModeEnabled)
                            .labelsHidden()
                            .onChange(of: isDarkModeEnabled) { _, newValue in
                                if newValue {
                                    darkModeTip.invalidate(reason: .actionPerformed)
                                    FeatureDiscoveryParameters.hasToggledDarkMode = true
                                }
                            }
                    }
                    .popoverTip(darkModeTip, arrowEdge: .leading)
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    // 알림 토글
                    SettingsRow(
                        icon: "bell.fill",
                        title: "알림",
                        color: .red
                    ) {
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                            .onChange(of: notificationsEnabled) { _, newValue in
                                if newValue {
                                    notificationTip.invalidate(reason: .actionPerformed)
                                    FeatureDiscoveryParameters.hasConfiguredNotifications = true
                                }
                            }
                    }
                    .popoverTip(notificationTip, arrowEdge: .leading)
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    // 위젯 설정
                    SettingsRow(
                        icon: "square.grid.2x2.fill",
                        title: "위젯 설정",
                        color: .green
                    ) {
                        Button {
                            actionAlertMessage = "위젯 설정 화면으로 이동합니다."
                            showActionAlert = true
                            widgetTip.invalidate(reason: .actionPerformed)
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .popoverTip(widgetTip, arrowEdge: .leading)
                }
            }
            
            // 안내 텍스트
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text("각 설정 항목에 팝오버 팁이 연결되어 있습니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 화살표 방향 섹션
    
    private var arrowEdgeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("화살표 방향 옵션", subtitle: "arrowEdge 파라미터 사용")
            
            // 화살표 방향 설명
            CardContainer {
                VStack(spacing: 16) {
                    Text("arrowEdge 옵션")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ArrowEdgeOption(edge: .top, description: "위쪽 화살표")
                        ArrowEdgeOption(edge: .bottom, description: "아래쪽 화살표")
                        ArrowEdgeOption(edge: .leading, description: "왼쪽 화살표")
                        ArrowEdgeOption(edge: .trailing, description: "오른쪽 화살표")
                    }
                }
            }
            
            // 코드 예제
            CodeSnippet(
                """
                // 화살표 방향 지정
                .popoverTip(tip, arrowEdge: .top)     // 위쪽
                .popoverTip(tip, arrowEdge: .bottom)  // 아래쪽
                .popoverTip(tip, arrowEdge: .leading) // 왼쪽
                .popoverTip(tip, arrowEdge: .trailing) // 오른쪽
                """
            )
        }
    }
    
    // MARK: - API 설명 섹션
    
    private var apiExplanationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("관련 TipKit API", subtitle: "팝오버 팁에 사용되는 주요 API")
            
            CardContainer {
                VStack(alignment: .leading, spacing: 16) {
                    APIRow(
                        name: ".popoverTip(_:arrowEdge:)",
                        description: "뷰에 팝오버 팁을 연결하는 수정자"
                    )
                    
                    Divider()
                    
                    APIRow(
                        name: "Edge",
                        description: "화살표 방향: .top, .bottom, .leading, .trailing"
                    )
                    
                    Divider()
                    
                    APIRow(
                        name: "Tip.invalidate(reason:)",
                        description: "팁을 프로그래매틱하게 무효화"
                    )
                    
                    Divider()
                    
                    APIRow(
                        name: "InvalidationReason",
                        description: ".actionPerformed, .tipClosed, .displayCountExceeded 등"
                    )
                }
            }
            
            // InvalidationReason 상세
            CardContainer {
                VStack(alignment: .leading, spacing: 12) {
                    Text("InvalidationReason 옵션")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InvalidationReasonRow(
                            name: ".actionPerformed",
                            description: "사용자가 팁에서 안내한 동작을 수행함"
                        )
                        
                        InvalidationReasonRow(
                            name: ".tipClosed",
                            description: "사용자가 팁을 직접 닫음"
                        )
                        
                        InvalidationReasonRow(
                            name: ".displayCountExceeded",
                            description: "최대 표시 횟수 초과"
                        )
                    }
                }
            }
        }
    }
}

// MARK: - 설정 행 뷰

struct SettingsRow<Accessory: View>: View {
    let icon: String
    let title: String
    let color: Color
    let accessory: () -> Accessory
    
    init(
        icon: String,
        title: String,
        color: Color,
        @ViewBuilder accessory: @escaping () -> Accessory
    ) {
        self.icon = icon
        self.title = title
        self.color = color
        self.accessory = accessory
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            accessory()
        }
        .padding(.vertical, 12)
    }
}

// MARK: - 화살표 방향 옵션 뷰

struct ArrowEdgeOption: View {
    let edge: Edge
    let description: String
    
    var edgeName: String {
        switch edge {
        case .top: return "top"
        case .bottom: return "bottom"
        case .leading: return "leading"
        case .trailing: return "trailing"
        }
    }
    
    var arrowRotation: Double {
        switch edge {
        case .top: return 0
        case .bottom: return 180
        case .leading: return 270
        case .trailing: return 90
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 60)
                
                Image(systemName: "arrow.up")
                    .font(.title2)
                    .rotationEffect(.degrees(arrowRotation))
                    .foregroundStyle(.blue)
            }
            
            VStack(spacing: 2) {
                Text(".\(edgeName)")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - InvalidationReason 행 뷰

struct InvalidationReasonRow: View {
    let name: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - 공유 시트 뷰

struct ShareSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 성공 아이콘
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                
                // 메시지
                VStack(spacing: 8) {
                    Text("공유 완료!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("콘텐츠가 성공적으로 공유되었습니다.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // 공유 옵션 그리드
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ShareOption(icon: "message.fill", name: "메시지", color: .green)
                    ShareOption(icon: "envelope.fill", name: "메일", color: .blue)
                    ShareOption(icon: "link", name: "링크 복사", color: .gray)
                    ShareOption(icon: "ellipsis", name: "더보기", color: .secondary)
                }
                .padding(.vertical)
                
                Spacer()
            }
            .padding()
            .navigationTitle("공유")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 공유 옵션 뷰

struct ShareOption: View {
    let icon: String
    let name: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(name)
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    PopoverTipView()
        .task {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}
