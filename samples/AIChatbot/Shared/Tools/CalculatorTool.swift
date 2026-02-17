// CalculatorTool.swift
// 계산기 도구
// iOS 26+ | FoundationModels
//
// 수학 연산을 수행하는 Foundation Models Tool
// 기본 연산부터 고급 수학 함수까지 지원

import Foundation
import FoundationModels

// MARK: - 계산기 도구

/// 수학 계산을 수행하는 도구
@Generable
struct CalculatorTool: Tool {
    
    // MARK: - Tool 프로토콜 구현
    
    static let name = "calculator"
    
    static let description = """
        수학 계산을 수행합니다.
        기본 연산(+, -, *, /), 거듭제곱(^), 괄호, 수학 함수(sin, cos, sqrt, log 등)를 지원합니다.
        예: "2 + 3 * 4", "sqrt(16)", "sin(45)"
        """
    
    struct Arguments: Codable, Sendable {
        /// 계산할 수식
        @Guide(description: "계산할 수학 수식 (예: 2 + 3 * 4, sqrt(16), sin(45))")
        let expression: String
        
        /// 각도 단위 (degrees 또는 radians)
        @Guide(description: "삼각함수의 각도 단위: degrees(도) 또는 radians(라디안)")
        let angleUnit: String?
    }
    
    func call(arguments: Arguments) async throws -> String {
        let expression = arguments.expression
        let angleUnit = arguments.angleUnit ?? "degrees"
        
        do {
            let result = try evaluate(
                expression,
                angleUnit: angleUnit == "radians" ? .radians : .degrees
            )
            return formatResult(expression, result)
        } catch {
            return "❌ 계산 오류: \(error.localizedDescription)"
        }
    }
}

// MARK: - 각도 단위

/// 각도 단위
enum AngleUnit: Sendable {
    case degrees
    case radians
    
    /// 라디안으로 변환
    func toRadians(_ value: Double) -> Double {
        switch self {
        case .degrees:
            return value * .pi / 180
        case .radians:
            return value
        }
    }
    
    /// 도로 변환
    func toDegrees(_ value: Double) -> Double {
        switch self {
        case .degrees:
            return value
        case .radians:
            return value * 180 / .pi
        }
    }
}

// MARK: - 계산 로직

extension CalculatorTool {
    
    /// 수식 계산
    /// - Parameters:
    ///   - expression: 수식 문자열
    ///   - angleUnit: 각도 단위
    /// - Returns: 계산 결과
    func evaluate(_ expression: String, angleUnit: AngleUnit = .degrees) throws -> Double {
        var expr = expression
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
        
        // 수학 상수 치환
        expr = expr
            .replacingOccurrences(of: "pi", with: String(Double.pi))
            .replacingOccurrences(of: "e", with: String(M_E))
        
        // 수학 함수 처리
        expr = try processFunctions(expr, angleUnit: angleUnit)
        
        // 기본 연산 계산
        return try evaluateBasicExpression(expr)
    }
    
    /// 수학 함수 처리
    private func processFunctions(_ expression: String, angleUnit: AngleUnit) throws -> String {
        var result = expression
        
        // 지원하는 함수 목록
        let functions: [(name: String, fn: (Double, AngleUnit) -> Double)] = [
            ("sqrt", { val, _ in sqrt(val) }),
            ("abs", { val, _ in abs(val) }),
            ("sin", { val, unit in sin(unit.toRadians(val)) }),
            ("cos", { val, unit in cos(unit.toRadians(val)) }),
            ("tan", { val, unit in tan(unit.toRadians(val)) }),
            ("asin", { val, unit in unit.toDegrees(asin(val)) }),
            ("acos", { val, unit in unit.toDegrees(acos(val)) }),
            ("atan", { val, unit in unit.toDegrees(atan(val)) }),
            ("log", { val, _ in log10(val) }),
            ("ln", { val, _ in log(val) }),
            ("exp", { val, _ in exp(val) }),
            ("floor", { val, _ in floor(val) }),
            ("ceil", { val, _ in ceil(val) }),
            ("round", { val, _ in round(val) }),
        ]
        
        // 각 함수 처리
        for (name, fn) in functions {
            let pattern = "\(name)\\(([^()]+)\\)"
            let regex = try NSRegularExpression(pattern: pattern)
            
            while let match = regex.firstMatch(
                in: result,
                range: NSRange(result.startIndex..., in: result)
            ) {
                let fullRange = Range(match.range, in: result)!
                let argRange = Range(match.range(at: 1), in: result)!
                let argString = String(result[argRange])
                
                // 인자 계산
                let argValue = try evaluate(argString, angleUnit: angleUnit)
                let calcResult = fn(argValue, angleUnit)
                
                result.replaceSubrange(fullRange, with: String(calcResult))
            }
        }
        
        return result
    }
    
    /// 기본 수식 계산 (연산자 우선순위 적용)
    private func evaluateBasicExpression(_ expression: String) throws -> Double {
        var expr = expression
        
        // 괄호 처리
        while expr.contains("(") {
            let pattern = "\\(([^()]+)\\)"
            let regex = try NSRegularExpression(pattern: pattern)
            
            guard let match = regex.firstMatch(
                in: expr,
                range: NSRange(expr.startIndex..., in: expr)
            ) else {
                throw CalculatorError.invalidExpression("괄호가 올바르지 않습니다")
            }
            
            let fullRange = Range(match.range, in: expr)!
            let innerRange = Range(match.range(at: 1), in: expr)!
            let innerExpr = String(expr[innerRange])
            
            let innerResult = try evaluateBasicExpression(innerExpr)
            expr.replaceSubrange(fullRange, with: String(innerResult))
        }
        
        // 거듭제곱 (^) 처리 - 오른쪽 결합
        expr = try processOperator(expr, pattern: "([\\d.]+)\\^([\\d.]+)") { pow($0, $1) }
        
        // 곱셈, 나눗셈 처리
        expr = try processOperator(expr, pattern: "([\\d.]+)\\*([\\d.]+)") { $0 * $1 }
        expr = try processOperator(expr, pattern: "([\\d.]+)\\/([\\d.]+)") { 
            guard $1 != 0 else { throw CalculatorError.divisionByZero }
            return $0 / $1
        }
        
        // 덧셈, 뺄셈 처리
        expr = try processOperator(expr, pattern: "([\\d.]+)\\+([\\d.]+)") { $0 + $1 }
        expr = try processOperator(expr, pattern: "([\\d.]+)\\-([\\d.]+)") { $0 - $1 }
        
        // 최종 결과 파싱
        guard let result = Double(expr) else {
            throw CalculatorError.invalidExpression("수식을 계산할 수 없습니다: \(expression)")
        }
        
        return result
    }
    
    /// 연산자 처리
    private func processOperator(
        _ expression: String,
        pattern: String,
        operation: (Double, Double) throws -> Double
    ) throws -> String {
        var result = expression
        let regex = try NSRegularExpression(pattern: pattern)
        
        while let match = regex.firstMatch(
            in: result,
            range: NSRange(result.startIndex..., in: result)
        ) {
            let fullRange = Range(match.range, in: result)!
            let leftRange = Range(match.range(at: 1), in: result)!
            let rightRange = Range(match.range(at: 2), in: result)!
            
            guard let left = Double(String(result[leftRange])),
                  let right = Double(String(result[rightRange])) else {
                throw CalculatorError.invalidExpression("숫자를 파싱할 수 없습니다")
            }
            
            let calcResult = try operation(left, right)
            result.replaceSubrange(fullRange, with: String(calcResult))
        }
        
        return result
    }
    
    /// 결과 포맷팅
    func formatResult(_ expression: String, _ result: Double) -> String {
        // 정수인지 확인
        let formatted: String
        if result.truncatingRemainder(dividingBy: 1) == 0 && abs(result) < Double(Int.max) {
            formatted = String(Int(result))
        } else {
            // 소수점 이하 유효숫자 처리
            formatted = String(format: "%.10g", result)
        }
        
        return """
            🧮 계산 결과
            
            수식: \(expression)
            결과: \(formatted)
            """
    }
    
    /// 간단한 계산 (레거시 인터페이스)
    func calculate(expression: String) -> String {
        do {
            let result = try evaluate(expression)
            return formatResult(expression, result)
        } catch {
            return "❌ 계산 오류: \(error.localizedDescription)"
        }
    }
}

// MARK: - 계산 에러

/// 계산기 에러
enum CalculatorError: LocalizedError {
    case invalidExpression(String)
    case divisionByZero
    case invalidArgument(String)
    case overflow
    
    var errorDescription: String? {
        switch self {
        case .invalidExpression(let detail):
            return "잘못된 수식: \(detail)"
        case .divisionByZero:
            return "0으로 나눌 수 없습니다"
        case .invalidArgument(let detail):
            return "잘못된 인수: \(detail)"
        case .overflow:
            return "계산 결과가 너무 큽니다"
        }
    }
}

// MARK: - 추가 계산 기능

extension CalculatorTool {
    
    /// 팩토리얼 계산
    func factorial(_ n: Int) -> Double {
        guard n >= 0 else { return Double.nan }
        guard n <= 170 else { return Double.infinity } // 오버플로우 방지
        
        if n <= 1 { return 1 }
        return Double(n) * factorial(n - 1)
    }
    
    /// 조합 (nCr)
    func combination(_ n: Int, _ r: Int) -> Double {
        guard r >= 0 && r <= n else { return 0 }
        return factorial(n) / (factorial(r) * factorial(n - r))
    }
    
    /// 순열 (nPr)
    func permutation(_ n: Int, _ r: Int) -> Double {
        guard r >= 0 && r <= n else { return 0 }
        return factorial(n) / factorial(n - r)
    }
    
    /// 최대공약수 (GCD)
    func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }
    
    /// 최소공배수 (LCM)
    func lcm(_ a: Int, _ b: Int) -> Int {
        abs(a * b) / gcd(a, b)
    }
    
    /// 소수 판별
    func isPrime(_ n: Int) -> Bool {
        guard n > 1 else { return false }
        guard n != 2 else { return true }
        guard n % 2 != 0 else { return false }
        
        let limit = Int(sqrt(Double(n)))
        for i in stride(from: 3, through: limit, by: 2) {
            if n % i == 0 { return false }
        }
        return true
    }
    
    /// 피보나치 수열
    func fibonacci(_ n: Int) -> Int {
        guard n > 0 else { return 0 }
        guard n > 2 else { return 1 }
        
        var a = 0, b = 1
        for _ in 2...n {
            let temp = a + b
            a = b
            b = temp
        }
        return b
    }
}

// MARK: - 통계 함수

extension CalculatorTool {
    
    /// 평균
    func mean(_ numbers: [Double]) -> Double {
        guard !numbers.isEmpty else { return 0 }
        return numbers.reduce(0, +) / Double(numbers.count)
    }
    
    /// 중앙값
    func median(_ numbers: [Double]) -> Double {
        guard !numbers.isEmpty else { return 0 }
        let sorted = numbers.sorted()
        let mid = sorted.count / 2
        
        if sorted.count % 2 == 0 {
            return (sorted[mid - 1] + sorted[mid]) / 2
        } else {
            return sorted[mid]
        }
    }
    
    /// 표준편차
    func standardDeviation(_ numbers: [Double]) -> Double {
        guard numbers.count > 1 else { return 0 }
        
        let avg = mean(numbers)
        let variance = numbers.reduce(0) { $0 + pow($1 - avg, 2) } / Double(numbers.count - 1)
        return sqrt(variance)
    }
}
