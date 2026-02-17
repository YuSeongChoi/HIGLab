// PDFReaderApp.swift
// PDFReader - HIG Lab 샘플 프로젝트
//
// 앱 진입점: @main 구조체

import SwiftUI
import PDFKit

// MARK: - 메인 앱
@main
struct PDFReaderApp: App {
    
    // MARK: - 상태 관리
    
    /// 북마크 관리자 (앱 전역)
    @StateObject private var bookmarkManager = BookmarkManager()
    
    /// 주석 관리자 (앱 전역)
    @StateObject private var annotationManager = AnnotationManager()
    
    // MARK: - 씬 구성
    
    var body: some Scene {
        // 메인 윈도우 그룹
        WindowGroup {
            ContentView()
                .environmentObject(bookmarkManager)
                .environmentObject(annotationManager)
        }
        #if os(macOS)
        // macOS 전용 설정
        .commands {
            // 파일 메뉴 커맨드
            CommandGroup(after: .newItem) {
                Button("PDF 열기...") {
                    openDocument()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            
            // 편집 메뉴 커맨드
            CommandGroup(after: .undoRedo) {
                Button("실행 취소") {
                    annotationManager.undo()
                }
                .keyboardShortcut("z", modifiers: .command)
                .disabled(!annotationManager.canUndo)
            }
            
            // 보기 메뉴 커맨드
            CommandMenu("보기") {
                Button("썸네일 표시") {
                    // 썸네일 패널 토글 (NotificationCenter 사용)
                    NotificationCenter.default.post(
                        name: .toggleThumbnailPanel,
                        object: nil
                    )
                }
                .keyboardShortcut("t", modifiers: [.command, .option])
                
                Divider()
                
                Button("검색") {
                    NotificationCenter.default.post(
                        name: .toggleSearchPanel,
                        object: nil
                    )
                }
                .keyboardShortcut("f", modifiers: .command)
            }
            
            // 북마크 메뉴
            CommandMenu("북마크") {
                Button("북마크 추가/제거") {
                    NotificationCenter.default.post(
                        name: .toggleBookmark,
                        object: nil
                    )
                }
                .keyboardShortcut("d", modifiers: .command)
                
                Divider()
                
                Button("다음 북마크로 이동") {
                    NotificationCenter.default.post(
                        name: .goToNextBookmark,
                        object: nil
                    )
                }
                .keyboardShortcut("]", modifiers: [.command, .option])
                
                Button("이전 북마크로 이동") {
                    NotificationCenter.default.post(
                        name: .goToPreviousBookmark,
                        object: nil
                    )
                }
                .keyboardShortcut("[", modifiers: [.command, .option])
            }
        }
        #endif
        
        #if os(macOS)
        // macOS 설정 윈도우
        Settings {
            SettingsView()
        }
        #endif
    }
    
    // MARK: - macOS 문서 열기
    
    #if os(macOS)
    /// 파일 열기 대화상자 표시
    private func openDocument() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                NotificationCenter.default.post(
                    name: .openDocument,
                    object: url
                )
            }
        }
    }
    #endif
}

// MARK: - 알림 이름 확장
extension Notification.Name {
    /// 썸네일 패널 토글
    static let toggleThumbnailPanel = Notification.Name("toggleThumbnailPanel")
    
    /// 검색 패널 토글
    static let toggleSearchPanel = Notification.Name("toggleSearchPanel")
    
    /// 북마크 토글
    static let toggleBookmark = Notification.Name("toggleBookmark")
    
    /// 다음 북마크로 이동
    static let goToNextBookmark = Notification.Name("goToNextBookmark")
    
    /// 이전 북마크로 이동
    static let goToPreviousBookmark = Notification.Name("goToPreviousBookmark")
    
    /// 문서 열기
    static let openDocument = Notification.Name("openDocument")
}

// MARK: - macOS 설정 뷰
#if os(macOS)
struct SettingsView: View {
    
    /// 기본 확대율
    @AppStorage("defaultZoom") private var defaultZoom = 1.0
    
    /// 연속 스크롤 모드
    @AppStorage("continuousScroll") private var continuousScroll = true
    
    /// 기본 주석 색상
    @AppStorage("defaultAnnotationColor") private var defaultAnnotationColor = "yellow"
    
    var body: some View {
        Form {
            // 보기 설정
            Section("보기") {
                Slider(value: $defaultZoom, in: 0.5...3.0, step: 0.25) {
                    Text("기본 확대율: \(Int(defaultZoom * 100))%")
                }
                
                Toggle("연속 스크롤 모드", isOn: $continuousScroll)
            }
            
            // 주석 설정
            Section("주석") {
                Picker("기본 주석 색상", selection: $defaultAnnotationColor) {
                    ForEach(AnnotationColor.allCases) { color in
                        HStack {
                            Circle()
                                .fill(color.color)
                                .frame(width: 12, height: 12)
                            Text(color.displayName)
                        }
                        .tag(color.rawValue)
                    }
                }
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}
#endif

// MARK: - 앱 상수
enum AppConstants {
    /// 앱 이름
    static let appName = "PDFReader"
    
    /// 버전
    static let version = "1.0.0"
    
    /// 지원 파일 확장자
    static let supportedExtensions = ["pdf"]
    
    /// 최근 파일 최대 개수
    static let maxRecentFiles = 10
    
    /// 썸네일 기본 크기
    static let thumbnailSize = CGSize(width: 120, height: 160)
    
    /// 검색 결과 최대 개수
    static let maxSearchResults = 100
}
