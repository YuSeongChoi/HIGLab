// UnitConvertTool.swift
// 단위 변환 도구
// iOS 26+ | FoundationModels
//
// 길이, 무게, 온도, 부피 등 다양한 단위 변환을 수행

import Foundation
import FoundationModels

// MARK: - 단위 변환 도구

/// 다양한 단위 변환을 수행하는 도구
@Generable
struct UnitConvertTool: Tool {
    
    // MARK: - Tool 프로토콜 구현
    
    static let name = "unitconvert"
    
    static let description = """
        길이, 무게, 온도, 부피, 속도, 면적, 데이터 용량 등의 단위를 변환합니다.
        예: "10 km to miles", "100 celsius to fahrenheit"
        """
    
    struct Arguments: Codable, Sendable {
        /// 변환할 값
        @Guide(description: "변환할 숫자 값")
        let value: Double
        
        /// 원본 단위
        @Guide(description: "원본 단위 (예: km, kg, celsius)")
        let from: String
        
        /// 대상 단위
        @Guide(description: "대상 단위 (예: miles, pounds, fahrenheit)")
        let to: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        let result = convert(
            value: arguments.value,
            from: arguments.from,
            to: arguments.to
        )
        return result
    }
}

// MARK: - 단위 카테고리

/// 단위 카테고리
enum UnitCategory: String, CaseIterable, Sendable {
    case length = "길이"
    case weight = "무게"
    case temperature = "온도"
    case volume = "부피"
    case area = "면적"
    case speed = "속도"
    case time = "시간"
    case data = "데이터"
    case pressure = "압력"
    case energy = "에너지"
    
    var iconName: String {
        switch self {
        case .length: return "ruler"
        case .weight: return "scalemass"
        case .temperature: return "thermometer"
        case .volume: return "drop"
        case .area: return "square"
        case .speed: return "speedometer"
        case .time: return "clock"
        case .data: return "externaldrive"
        case .pressure: return "gauge"
        case .energy: return "bolt"
        }
    }
}

// MARK: - 단위 정보

/// 단위 정보
struct UnitInfo: Sendable {
    let symbol: String
    let name: String
    let category: UnitCategory
    let toBase: (Double) -> Double  // 기준 단위로 변환
    let fromBase: (Double) -> Double // 기준 단위에서 변환
}

// MARK: - 변환 로직

extension UnitConvertTool {
    
    /// 단위 변환 수행
    func convert(value: Double, from: String, to: String) -> String {
        let fromUnit = from.lowercased().trimmingCharacters(in: .whitespaces)
        let toUnit = to.lowercased().trimmingCharacters(in: .whitespaces)
        
        // 같은 단위면 그대로 반환
        if fromUnit == toUnit {
            return formatResult(value, from: from, result: value, to: to)
        }
        
        // 카테고리별 변환 시도
        if let result = convertLength(value, from: fromUnit, to: toUnit) {
            return formatResult(value, from: from, result: result, to: to)
        }
        
        if let result = convertWeight(value, from: fromUnit, to: toUnit) {
            return formatResult(value, from: from, result: result, to: to)
        }
        
        if let result = convertTemperature(value, from: fromUnit, to: toUnit) {
            return formatResult(value, from: from, result: result, to: to)
        }
        
        if let result = convertVolume(value, from: fromUnit, to: toUnit) {
            return formatResult(value, from: from, result: result, to: to)
        }
        
        if let result = convertArea(value, from: fromUnit, to: toUnit) {
            return formatResult(value, from: from, result: result, to: to)
        }
        
        if let result = convertSpeed(value, from: fromUnit, to: toUnit) {
            return formatResult(value, from: from, result: result, to: to)
        }
        
        if let result = convertTime(value, from: fromUnit, to: toUnit) {
            return formatResult(value, from: from, result: result, to: to)
        }
        
        if let result = convertData(value, from: fromUnit, to: toUnit) {
            return formatResult(value, from: from, result: result, to: to)
        }
        
        return """
            ❌ 변환할 수 없는 단위입니다.
            
            입력: \(value) \(from)
            대상: \(to)
            
            지원되는 단위 목록을 확인해주세요.
            """
    }
    
    /// 결과 포맷팅
    private func formatResult(
        _ value: Double,
        from: String,
        result: Double,
        to: String
    ) -> String {
        let formattedValue = formatNumber(value)
        let formattedResult = formatNumber(result)
        
        return """
            🔄 단위 변환 결과
            
            📥 입력: \(formattedValue) \(from)
            📤 결과: \(formattedResult) \(to)
            """
    }
    
    /// 숫자 포맷팅
    private func formatNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 && abs(value) < Double(Int.max) {
            return String(Int(value))
        } else if abs(value) < 0.0001 || abs(value) > 999999999 {
            return String(format: "%.4e", value)
        } else {
            return String(format: "%.6g", value)
        }
    }
}

// MARK: - 길이 변환

extension UnitConvertTool {
    
    /// 길이 단위 변환 (기준: 미터)
    func convertLength(_ value: Double, from: String, to: String) -> Double? {
        let lengthToMeters: [String: Double] = [
            "mm": 0.001,
            "millimeter": 0.001,
            "밀리미터": 0.001,
            "cm": 0.01,
            "centimeter": 0.01,
            "센티미터": 0.01,
            "m": 1.0,
            "meter": 1.0,
            "미터": 1.0,
            "km": 1000.0,
            "kilometer": 1000.0,
            "킬로미터": 1000.0,
            "in": 0.0254,
            "inch": 0.0254,
            "인치": 0.0254,
            "ft": 0.3048,
            "foot": 0.3048,
            "feet": 0.3048,
            "피트": 0.3048,
            "yd": 0.9144,
            "yard": 0.9144,
            "야드": 0.9144,
            "mi": 1609.344,
            "mile": 1609.344,
            "miles": 1609.344,
            "마일": 1609.344,
            "nm": 1852.0,
            "nautical mile": 1852.0,
            "해리": 1852.0,
        ]
        
        guard let fromFactor = lengthToMeters[from],
              let toFactor = lengthToMeters[to] else {
            return nil
        }
        
        let meters = value * fromFactor
        return meters / toFactor
    }
}

// MARK: - 무게 변환

extension UnitConvertTool {
    
    /// 무게 단위 변환 (기준: 킬로그램)
    func convertWeight(_ value: Double, from: String, to: String) -> Double? {
        let weightToKg: [String: Double] = [
            "mg": 0.000001,
            "milligram": 0.000001,
            "밀리그램": 0.000001,
            "g": 0.001,
            "gram": 0.001,
            "그램": 0.001,
            "kg": 1.0,
            "kilogram": 1.0,
            "킬로그램": 1.0,
            "t": 1000.0,
            "ton": 1000.0,
            "톤": 1000.0,
            "oz": 0.0283495,
            "ounce": 0.0283495,
            "온스": 0.0283495,
            "lb": 0.453592,
            "pound": 0.453592,
            "pounds": 0.453592,
            "파운드": 0.453592,
            "근": 0.6,
            "관": 3.75,
        ]
        
        guard let fromFactor = weightToKg[from],
              let toFactor = weightToKg[to] else {
            return nil
        }
        
        let kg = value * fromFactor
        return kg / toFactor
    }
}

// MARK: - 온도 변환

extension UnitConvertTool {
    
    /// 온도 단위 변환
    func convertTemperature(_ value: Double, from: String, to: String) -> Double? {
        // 섭씨로 변환
        let celsius: Double
        switch from {
        case "c", "celsius", "섭씨", "°c":
            celsius = value
        case "f", "fahrenheit", "화씨", "°f":
            celsius = (value - 32) * 5 / 9
        case "k", "kelvin", "켈빈":
            celsius = value - 273.15
        default:
            return nil
        }
        
        // 목표 단위로 변환
        switch to {
        case "c", "celsius", "섭씨", "°c":
            return celsius
        case "f", "fahrenheit", "화씨", "°f":
            return celsius * 9 / 5 + 32
        case "k", "kelvin", "켈빈":
            return celsius + 273.15
        default:
            return nil
        }
    }
}

// MARK: - 부피 변환

extension UnitConvertTool {
    
    /// 부피 단위 변환 (기준: 리터)
    func convertVolume(_ value: Double, from: String, to: String) -> Double? {
        let volumeToLiters: [String: Double] = [
            "ml": 0.001,
            "milliliter": 0.001,
            "밀리리터": 0.001,
            "l": 1.0,
            "liter": 1.0,
            "리터": 1.0,
            "gal": 3.78541,
            "gallon": 3.78541,
            "갤런": 3.78541,
            "qt": 0.946353,
            "quart": 0.946353,
            "쿼트": 0.946353,
            "pt": 0.473176,
            "pint": 0.473176,
            "파인트": 0.473176,
            "cup": 0.236588,
            "컵": 0.236588,
            "fl oz": 0.0295735,
            "fluid ounce": 0.0295735,
            "cc": 0.001,
            "m3": 1000.0,
            "cubic meter": 1000.0,
        ]
        
        guard let fromFactor = volumeToLiters[from],
              let toFactor = volumeToLiters[to] else {
            return nil
        }
        
        let liters = value * fromFactor
        return liters / toFactor
    }
}

// MARK: - 면적 변환

extension UnitConvertTool {
    
    /// 면적 단위 변환 (기준: 제곱미터)
    func convertArea(_ value: Double, from: String, to: String) -> Double? {
        let areaToSqMeters: [String: Double] = [
            "mm2": 0.000001,
            "cm2": 0.0001,
            "m2": 1.0,
            "제곱미터": 1.0,
            "km2": 1000000.0,
            "제곱킬로미터": 1000000.0,
            "in2": 0.00064516,
            "ft2": 0.092903,
            "yd2": 0.836127,
            "acre": 4046.86,
            "에이커": 4046.86,
            "ha": 10000.0,
            "hectare": 10000.0,
            "헥타르": 10000.0,
            "평": 3.30579,
            "坪": 3.30579,
        ]
        
        guard let fromFactor = areaToSqMeters[from],
              let toFactor = areaToSqMeters[to] else {
            return nil
        }
        
        let sqMeters = value * fromFactor
        return sqMeters / toFactor
    }
}

// MARK: - 속도 변환

extension UnitConvertTool {
    
    /// 속도 단위 변환 (기준: m/s)
    func convertSpeed(_ value: Double, from: String, to: String) -> Double? {
        let speedToMps: [String: Double] = [
            "m/s": 1.0,
            "mps": 1.0,
            "km/h": 0.277778,
            "kmh": 0.277778,
            "시속": 0.277778,
            "mph": 0.44704,
            "마일/시": 0.44704,
            "knot": 0.514444,
            "노트": 0.514444,
            "ft/s": 0.3048,
            "fps": 0.3048,
            "mach": 343.0, // 표준 음속
            "마하": 343.0,
        ]
        
        guard let fromFactor = speedToMps[from],
              let toFactor = speedToMps[to] else {
            return nil
        }
        
        let mps = value * fromFactor
        return mps / toFactor
    }
}

// MARK: - 시간 변환

extension UnitConvertTool {
    
    /// 시간 단위 변환 (기준: 초)
    func convertTime(_ value: Double, from: String, to: String) -> Double? {
        let timeToSeconds: [String: Double] = [
            "ms": 0.001,
            "millisecond": 0.001,
            "밀리초": 0.001,
            "s": 1.0,
            "sec": 1.0,
            "second": 1.0,
            "초": 1.0,
            "min": 60.0,
            "minute": 60.0,
            "분": 60.0,
            "h": 3600.0,
            "hr": 3600.0,
            "hour": 3600.0,
            "시간": 3600.0,
            "day": 86400.0,
            "일": 86400.0,
            "week": 604800.0,
            "주": 604800.0,
            "month": 2592000.0, // 30일 기준
            "월": 2592000.0,
            "year": 31536000.0, // 365일 기준
            "년": 31536000.0,
        ]
        
        guard let fromFactor = timeToSeconds[from],
              let toFactor = timeToSeconds[to] else {
            return nil
        }
        
        let seconds = value * fromFactor
        return seconds / toFactor
    }
}

// MARK: - 데이터 용량 변환

extension UnitConvertTool {
    
    /// 데이터 용량 변환 (기준: 바이트)
    func convertData(_ value: Double, from: String, to: String) -> Double? {
        let dataToBytes: [String: Double] = [
            "bit": 0.125,
            "비트": 0.125,
            "b": 1.0,
            "byte": 1.0,
            "바이트": 1.0,
            "kb": 1024.0,
            "kilobyte": 1024.0,
            "킬로바이트": 1024.0,
            "mb": 1048576.0,
            "megabyte": 1048576.0,
            "메가바이트": 1048576.0,
            "gb": 1073741824.0,
            "gigabyte": 1073741824.0,
            "기가바이트": 1073741824.0,
            "tb": 1099511627776.0,
            "terabyte": 1099511627776.0,
            "테라바이트": 1099511627776.0,
            "pb": 1125899906842624.0,
            "petabyte": 1125899906842624.0,
            "페타바이트": 1125899906842624.0,
        ]
        
        guard let fromFactor = dataToBytes[from],
              let toFactor = dataToBytes[to] else {
            return nil
        }
        
        let bytes = value * fromFactor
        return bytes / toFactor
    }
}

// MARK: - 지원 단위 목록

extension UnitConvertTool {
    
    /// 지원되는 단위 카테고리별 목록
    static var supportedUnits: [UnitCategory: [String]] {
        [
            .length: ["mm", "cm", "m", "km", "in", "ft", "yd", "mi", "해리"],
            .weight: ["mg", "g", "kg", "t", "oz", "lb", "근", "관"],
            .temperature: ["celsius(°C)", "fahrenheit(°F)", "kelvin(K)"],
            .volume: ["ml", "l", "gal", "qt", "pt", "cup", "fl oz"],
            .area: ["mm²", "cm²", "m²", "km²", "in²", "ft²", "acre", "ha", "평"],
            .speed: ["m/s", "km/h", "mph", "knot", "mach"],
            .time: ["ms", "s", "min", "h", "day", "week", "month", "year"],
            .data: ["bit", "byte", "KB", "MB", "GB", "TB", "PB"],
        ]
    }
}
