import SwiftUI

// MARK: - 스캔 결과 뷰

/// 스캔된 NFC 태그의 상세 정보를 표시하는 뷰
struct ScanResultView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var historyManager: ScanHistoryManager
    
    let message: NDEFMessage
    
    /// 선택된 레코드
    @State private var selectedRecord: NDEFRecord?
    
    /// 공유 시트 표시 여부
    @State private var showShareSheet = false
    
    /// 복사 완료 알림
    @State private var showCopiedAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 헤더 카드
                    headerCard
                    
                    // 태그 정보
                    tagInfoCard
                    
                    // 레코드 목록
                    recordsSection
                    
                    // 액션 버튼
                    actionButtons
                }
                .padding()
            }
            .background(Color.nfcBackground)
            .navigationTitle("스캔 결과")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedRecord) { record in
                RecordDetailView(record: record)
            }
            .alert("복사됨", isPresented: $showCopiedAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("클립보드에 복사되었습니다")
            }
        }
    }
    
    // MARK: - 헤더 카드
    
    private var headerCard: some View {
        VStack(spacing: 16) {
            // 콘텐츠 타입 아이콘
            ZStack {
                Circle()
                    .fill(Color.nfcPrimary.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: message.primaryContentType.iconName)
                    .font(.system(size: 35))
                    .foregroundColor(.nfcPrimary)
            }
            
            // 콘텐츠 타입
            Text(message.primaryContentType.displayName)
                .font(.headline)
                .foregroundColor(.secondary)
            
            // 요약 정보
            Text(message.summary)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    // MARK: - 태그 정보 카드
    
    private var tagInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("태그 정보")
                .font(.headline)
            
            Divider()
            
            // 태그 타입
            InfoRow(
                icon: message.tagType.iconName,
                title: "태그 타입",
                value: message.tagType.rawValue
            )
            
            // 태그 ID
            InfoRow(
                icon: "number",
                title: "태그 ID",
                value: message.tagIdentifierString
            )
            
            // 쓰기 가능 여부
            InfoRow(
                icon: message.isWritable ? "pencil.circle" : "lock.circle",
                title: "쓰기 가능",
                value: message.isWritable ? "예" : "아니오"
            )
            
            // 용량 정보
            if message.capacity > 0 {
                InfoRow(
                    icon: "externaldrive",
                    title: "용량",
                    value: "\(message.usedSize) / \(message.capacity) bytes"
                )
                
                // 용량 게이지
                CapacityGauge(usageRatio: message.usageRatio)
            }
            
            // 레코드 수
            InfoRow(
                icon: "list.bullet",
                title: "레코드 수",
                value: "\(message.records.count)개"
            )
        }
        .cardStyle()
    }
    
    // MARK: - 레코드 섹션
    
    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NDEF 레코드")
                .font(.headline)
            
            ForEach(Array(message.records.enumerated()), id: \.element.id) { index, record in
                RecordRow(index: index + 1, record: record)
                    .onTapGesture {
                        selectedRecord = record
                    }
            }
        }
        .cardStyle()
    }
    
    // MARK: - 액션 버튼
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // 콘텐츠에 따른 주요 액션
            primaryActionButton
            
            // 복사 버튼
            Button {
                copyToClipboard()
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("내용 복사")
                }
            }
            .secondaryButtonStyle()
        }
    }
    
    /// 콘텐츠 타입에 따른 주요 액션 버튼
    @ViewBuilder
    private var primaryActionButton: some View {
        switch message.primaryContentType {
        case .url:
            if let urlContent = getURLContent() {
                Link(destination: URL(string: urlContent.uri) ?? URL(string: "https://")!) {
                    HStack {
                        Image(systemName: "safari")
                        Text("Safari에서 열기")
                    }
                }
                .primaryButtonStyle()
            }
            
        case .phone:
            if let urlContent = getURLContent() {
                Link(destination: URL(string: urlContent.uri) ?? URL(string: "tel:")!) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("전화 걸기")
                    }
                }
                .primaryButtonStyle()
            }
            
        case .email:
            if let urlContent = getURLContent() {
                Link(destination: URL(string: urlContent.uri) ?? URL(string: "mailto:")!) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("이메일 보내기")
                    }
                }
                .primaryButtonStyle()
            }
            
        case .contact:
            Button {
                // 연락처 추가 기능
            } label: {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("연락처에 추가")
                }
            }
            .primaryButtonStyle()
            
        default:
            EmptyView()
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    private func getURLContent() -> URIContent? {
        guard let record = message.records.first,
              case .uri(let content) = record.parsedContent else {
            return nil
        }
        return content
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = message.summary
        showCopiedAlert = true
    }
}

// MARK: - 정보 행

/// 정보 표시용 행 컴포넌트
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.nfcPrimary)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

// MARK: - 용량 게이지

/// 태그 용량 사용률 게이지
struct CapacityGauge: View {
    let usageRatio: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                
                // 사용량
                RoundedRectangle(cornerRadius: 4)
                    .fill(gaugeColor)
                    .frame(width: geometry.size.width * usageRatio)
            }
        }
        .frame(height: 8)
    }
    
    private var gaugeColor: Color {
        if usageRatio < 0.5 {
            return .green
        } else if usageRatio < 0.8 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - 레코드 행

/// NDEF 레코드 행 컴포넌트
struct RecordRow: View {
    let index: Int
    let record: NDEFRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // 인덱스
            Text("\(index)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.nfcPrimary)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                // TNF 타입
                Text(record.tnf.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 레코드 요약
                Text(record.summary)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// MARK: - 레코드 상세 뷰

/// NDEF 레코드 상세 정보 뷰
struct RecordDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let record: NDEFRecord
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 기본 정보
                    basicInfoSection
                    
                    // 파싱된 콘텐츠
                    if let content = record.parsedContent {
                        parsedContentSection(content)
                    }
                    
                    // Raw 데이터
                    rawDataSection
                }
                .padding()
            }
            .background(Color.nfcBackground)
            .navigationTitle("레코드 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("기본 정보")
                .font(.headline)
            
            Divider()
            
            InfoRow(
                icon: "tag",
                title: "TNF",
                value: record.tnf.description
            )
            
            InfoRow(
                icon: "text.alignleft",
                title: "타입",
                value: record.typeString
            )
            
            InfoRow(
                icon: "doc.text",
                title: "페이로드 크기",
                value: "\(record.payload.count) bytes"
            )
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private func parsedContentSection(_ content: ParsedContent) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("파싱된 콘텐츠")
                .font(.headline)
            
            Divider()
            
            switch content {
            case .text(let textContent):
                InfoRow(icon: "globe", title: "언어", value: textContent.languageCode)
                InfoRow(icon: "textformat", title: "인코딩", value: textContent.encoding.rawValue)
                
                Text("내용:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(textContent.text)
                    .font(.body)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
            case .uri(let uriContent):
                InfoRow(icon: "link", title: "URI", value: uriContent.uri)
                InfoRow(icon: "arrow.right.circle", title: "스키마", value: uriContent.scheme)
                InfoRow(icon: "doc.text", title: "타입", value: uriContent.uriType.iconName)
                
            case .contact(let contactContent):
                InfoRow(icon: "person", title: "이름", value: contactContent.displayName)
                if let phone = contactContent.phone {
                    InfoRow(icon: "phone", title: "전화", value: phone)
                }
                if let email = contactContent.email {
                    InfoRow(icon: "envelope", title: "이메일", value: email)
                }
                if let org = contactContent.organization {
                    InfoRow(icon: "building.2", title: "조직", value: org)
                }
                
            case .raw(let rawContent):
                if let mimeType = rawContent.mimeType {
                    InfoRow(icon: "doc", title: "MIME 타입", value: mimeType)
                }
                InfoRow(icon: "number", title: "크기", value: "\(rawContent.data.count) bytes")
            }
        }
        .cardStyle()
    }
    
    private var rawDataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Raw 데이터")
                .font(.headline)
            
            Divider()
            
            Text("타입 (Hex):")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(record.type.hexString)
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
            
            Text("페이로드 (Hex):")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: true) {
                Text(record.payload.hexString)
                    .font(.system(.caption, design: .monospaced))
                    .padding(8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(4)
        }
        .cardStyle()
    }
}

// MARK: - 프리뷰

#Preview {
    // 샘플 메시지 생성
    let sampleRecord = NDEFRecord(
        tnf: .wellKnown,
        type: "U".data(using: .utf8)!,
        payload: Data([0x04]) + "example.com".data(using: .utf8)!
    )
    
    let sampleMessage = NDEFMessage(
        records: [sampleRecord],
        tagType: .type2,
        isWritable: true,
        capacity: 504,
        usedSize: 128
    )
    
    return ScanResultView(message: sampleMessage)
        .environmentObject(ScanHistoryManager())
}
