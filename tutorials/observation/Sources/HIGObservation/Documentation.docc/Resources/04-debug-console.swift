import SwiftUI
import Observation

/// 디버그 콘솔 뷰
/// 개발 중 상태 변화를 실시간으로 확인할 수 있습니다.

#if DEBUG
struct DebugConsoleView: View {
    @Bindable var debug: DebugStore
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Text("Debug Console")
                    .font(.headline)
                
                Spacer()
                
                // 필터 메뉴
                Menu {
                    Button("전체") { debug.filter = nil }
                    Divider()
                    ForEach([
                        DebugStore.LogEntry.Category.cart,
                        .product,
                        .network,
                        .error,
                        .info
                    ], id: \.self) { category in
                        Button("\(category.rawValue) \(category.rawValue)") {
                            debug.filter = category
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                
                Button(action: debug.clear) {
                    Image(systemName: "trash")
                }
                
                Button(action: debug.toggleVisibility) {
                    Image(systemName: "xmark.circle.fill")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))
            
            // 로그 목록
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(debug.filteredLogs) { entry in
                            LogEntryRow(entry: entry)
                                .id(entry.id)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .onChange(of: debug.logs.count) { _, _ in
                    if let last = debug.filteredLogs.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .frame(height: 200)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 5)
    }
}

struct LogEntryRow: View {
    let entry: DebugStore.LogEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(entry.category.rawValue)
            
            Text(entry.formattedTime)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            
            Text(entry.message)
                .font(.caption)
                .lineLimit(2)
        }
        .padding(.vertical, 2)
    }
}

/// 디버그 콘솔 오버레이 Modifier
struct DebugConsoleModifier: ViewModifier {
    @Bindable var debug: DebugStore
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if debug.isVisible {
                    DebugConsoleView(debug: debug)
                        .padding()
                        .transition(.move(edge: .bottom))
                }
            }
    }
}

extension View {
    func debugConsole(_ debug: DebugStore = .shared) -> some View {
        modifier(DebugConsoleModifier(debug: debug))
    }
}
#endif
