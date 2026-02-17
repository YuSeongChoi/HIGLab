// ToolService.swift
// 도구 관리 및 실행 서비스
// iOS 26+ | FoundationModels
//
// Foundation Models Tool 프로토콜 기반 도구들을 관리하고 실행

import Foundation
import FoundationModels

// MARK: - 도구 서비스

/// 도구 서비스 - 모든 도구의 등록 및 실행을 관리
@MainActor
@Observable
final class ToolService {
    
    // MARK: - 상태
    
    /// 등록된 모든 도구
    private(set) var registeredTools: [ToolInfo] = []
    
    /// 활성화된 도구 이름
    var enabledToolNames: Set<String> = []
    
    /// 도구 실행 기록
    private(set) var executionHistory: [ToolExecution] = []
    
    // MARK: - 초기화
    
    init() {
        registerDefaultTools()
    }
    
    /// 기본 도구 등록
    private func registerDefaultTools() {
        // 날씨 도구
        register(
            ToolInfo(
                name: "weather",
                displayName: "날씨",
                description: "특정 도시의 현재 날씨 정보를 가져옵니다.",
                iconName: "cloud.sun.fill",
                category: .information,
                tool: WeatherTool()
            )
        )
        
        // 계산기 도구
        register(
            ToolInfo(
                name: "calculator",
                displayName: "계산기",
                description: "수학 계산을 수행합니다.",
                iconName: "plus.forwardslash.minus",
                category: .utility,
                tool: CalculatorTool()
            )
        )
        
        // 날짜/시간 도구
        register(
            ToolInfo(
                name: "datetime",
                displayName: "날짜/시간",
                description: "현재 날짜, 시간, 요일 등을 제공합니다.",
                iconName: "calendar",
                category: .utility,
                tool: DateTimeTool()
            )
        )
        
        // 단위 변환 도구
        register(
            ToolInfo(
                name: "unitconvert",
                displayName: "단위 변환",
                description: "길이, 무게, 온도 등의 단위를 변환합니다.",
                iconName: "arrow.left.arrow.right",
                category: .utility,
                tool: UnitConvertTool()
            )
        )
        
        // 기본으로 모든 도구 활성화
        enabledToolNames = Set(registeredTools.map { $0.name })
    }
    
    // MARK: - 도구 등록
    
    /// 도구 등록
    /// - Parameter info: 도구 정보
    func register(_ info: ToolInfo) {
        // 중복 방지
        if !registeredTools.contains(where: { $0.name == info.name }) {
            registeredTools.append(info)
        }
    }
    
    /// 도구 등록 해제
    /// - Parameter name: 도구 이름
    func unregister(_ name: String) {
        registeredTools.removeAll { $0.name == name }
        enabledToolNames.remove(name)
    }
    
    // MARK: - 도구 활성화/비활성화
    
    /// 도구 활성화/비활성화 토글
    /// - Parameter name: 도구 이름
    func toggle(_ name: String) {
        if enabledToolNames.contains(name) {
            enabledToolNames.remove(name)
        } else {
            enabledToolNames.insert(name)
        }
    }
    
    /// 도구 활성화
    /// - Parameter name: 도구 이름
    func enable(_ name: String) {
        enabledToolNames.insert(name)
    }
    
    /// 도구 비활성화
    /// - Parameter name: 도구 이름
    func disable(_ name: String) {
        enabledToolNames.remove(name)
    }
    
    /// 모든 도구 활성화
    func enableAll() {
        enabledToolNames = Set(registeredTools.map { $0.name })
    }
    
    /// 모든 도구 비활성화
    func disableAll() {
        enabledToolNames.removeAll()
    }
    
    // MARK: - 도구 조회
    
    /// 활성화된 도구들
    var enabledTools: [ToolInfo] {
        registeredTools.filter { enabledToolNames.contains($0.name) }
    }
    
    /// 도구 이름으로 조회
    /// - Parameter name: 도구 이름
    /// - Returns: 도구 정보
    func tool(named name: String) -> ToolInfo? {
        registeredTools.first { $0.name == name }
    }
    
    /// 도구가 활성화되어 있는지 확인
    /// - Parameter name: 도구 이름
    /// - Returns: 활성화 여부
    func isEnabled(_ name: String) -> Bool {
        enabledToolNames.contains(name)
    }
    
    /// 카테고리별 도구 목록
    /// - Parameter category: 도구 카테고리
    /// - Returns: 해당 카테고리의 도구 목록
    func tools(in category: ToolCategory) -> [ToolInfo] {
        registeredTools.filter { $0.category == category }
    }
    
    // MARK: - Foundation Models 도구 배열
    
    /// ChatService에 전달할 도구 배열
    var foundationModelTools: [any Tool] {
        enabledTools.map { $0.tool }
    }
    
    // MARK: - 도구 실행
    
    /// 도구 수동 실행 (테스트용)
    /// - Parameters:
    ///   - name: 도구 이름
    ///   - arguments: 인자
    /// - Returns: 실행 결과
    func execute(
        _ name: String,
        arguments: [String: String]
    ) async throws -> String {
        guard let toolInfo = tool(named: name) else {
            throw ToolServiceError.toolNotFound(name)
        }
        
        guard isEnabled(name) else {
            throw ToolServiceError.toolDisabled(name)
        }
        
        let startTime = Date()
        
        do {
            // 도구별 실행 로직
            let result = try await executeToolInternal(toolInfo.tool, arguments: arguments)
            
            // 실행 기록
            let execution = ToolExecution(
                toolName: name,
                arguments: arguments,
                result: result,
                executionTime: Date().timeIntervalSince(startTime),
                isSuccess: true
            )
            executionHistory.append(execution)
            
            return result
            
        } catch {
            // 실패 기록
            let execution = ToolExecution(
                toolName: name,
                arguments: arguments,
                result: nil,
                error: error.localizedDescription,
                executionTime: Date().timeIntervalSince(startTime),
                isSuccess: false
            )
            executionHistory.append(execution)
            
            throw ToolServiceError.executionFailed(name, error)
        }
    }
    
    /// 도구 내부 실행
    private func executeToolInternal(
        _ tool: any Tool,
        arguments: [String: String]
    ) async throws -> String {
        // 도구 타입에 따라 실행
        switch tool {
        case let weatherTool as WeatherTool:
            let city = arguments["city"] ?? "서울"
            return try await weatherTool.getWeather(city: city)
            
        case let calculatorTool as CalculatorTool:
            let expression = arguments["expression"] ?? "0"
            return calculatorTool.calculate(expression: expression)
            
        case let dateTimeTool as DateTimeTool:
            let format = arguments["format"]
            return dateTimeTool.getCurrentDateTime(format: format)
            
        case let unitTool as UnitConvertTool:
            let value = Double(arguments["value"] ?? "0") ?? 0
            let from = arguments["from"] ?? ""
            let to = arguments["to"] ?? ""
            return unitTool.convert(value: value, from: from, to: to)
            
        default:
            throw ToolServiceError.unsupportedTool(type(of: tool).name)
        }
    }
    
    // MARK: - 실행 기록
    
    /// 실행 기록 초기화
    func clearHistory() {
        executionHistory.removeAll()
    }
    
    /// 특정 도구의 실행 횟수
    /// - Parameter name: 도구 이름
    /// - Returns: 실행 횟수
    func executionCount(for name: String) -> Int {
        executionHistory.filter { $0.toolName == name }.count
    }
    
    /// 특정 도구의 성공률
    /// - Parameter name: 도구 이름
    /// - Returns: 성공률 (0.0~1.0)
    func successRate(for name: String) -> Double {
        let executions = executionHistory.filter { $0.toolName == name }
        guard !executions.isEmpty else { return 1.0 }
        
        let successful = executions.filter { $0.isSuccess }.count
        return Double(successful) / Double(executions.count)
    }
}

// MARK: - 도구 정보

/// 도구 정보 - UI 표시 및 관리용 메타데이터
struct ToolInfo: Identifiable, Sendable {
    let id: UUID
    let name: String            // 고유 이름
    let displayName: String     // 표시 이름
    let description: String     // 설명
    let iconName: String        // SF Symbol 아이콘
    let category: ToolCategory  // 카테고리
    let tool: any Tool          // 실제 도구 인스턴스
    
    init(
        id: UUID = UUID(),
        name: String,
        displayName: String,
        description: String,
        iconName: String,
        category: ToolCategory,
        tool: any Tool
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.description = description
        self.iconName = iconName
        self.category = category
        self.tool = tool
    }
}

/// 도구 카테고리
enum ToolCategory: String, Codable, Sendable, CaseIterable {
    case information    // 정보 조회
    case utility       // 유틸리티
    case productivity  // 생산성
    case entertainment // 엔터테인먼트
    case custom        // 사용자 정의
    
    var displayName: String {
        switch self {
        case .information: return "정보"
        case .utility: return "유틸리티"
        case .productivity: return "생산성"
        case .entertainment: return "엔터테인먼트"
        case .custom: return "사용자 정의"
        }
    }
    
    var iconName: String {
        switch self {
        case .information: return "info.circle.fill"
        case .utility: return "wrench.fill"
        case .productivity: return "chart.bar.fill"
        case .entertainment: return "gamecontroller.fill"
        case .custom: return "person.fill"
        }
    }
}

// MARK: - 도구 실행 기록

/// 도구 실행 기록
struct ToolExecution: Identifiable, Sendable {
    let id: UUID
    let toolName: String
    let arguments: [String: String]
    let result: String?
    let error: String?
    let executionTime: TimeInterval
    let isSuccess: Bool
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        toolName: String,
        arguments: [String: String],
        result: String?,
        error: String? = nil,
        executionTime: TimeInterval,
        isSuccess: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.toolName = toolName
        self.arguments = arguments
        self.result = result
        self.error = error
        self.executionTime = executionTime
        self.isSuccess = isSuccess
        self.timestamp = timestamp
    }
}

// MARK: - 에러 정의

/// 도구 서비스 에러
enum ToolServiceError: LocalizedError {
    case toolNotFound(String)
    case toolDisabled(String)
    case executionFailed(String, Error)
    case unsupportedTool(String)
    case invalidArguments(String)
    
    var errorDescription: String? {
        switch self {
        case .toolNotFound(let name):
            return "도구 '\(name)'을(를) 찾을 수 없습니다."
        case .toolDisabled(let name):
            return "도구 '\(name)'이(가) 비활성화되어 있습니다."
        case .executionFailed(let name, let error):
            return "도구 '\(name)' 실행 실패: \(error.localizedDescription)"
        case .unsupportedTool(let name):
            return "지원되지 않는 도구입니다: \(name)"
        case .invalidArguments(let message):
            return "잘못된 인자: \(message)"
        }
    }
}

// MARK: - 프리뷰 지원

extension ToolService {
    
    /// 프리뷰용 서비스
    static var preview: ToolService {
        ToolService()
    }
}
