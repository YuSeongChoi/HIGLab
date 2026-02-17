// FilterChain.swift
// FilterLab - 필터 체인 모델
// HIG Lab 샘플 프로젝트

import Foundation
import SwiftUI

// MARK: - 필터 노드
/// 체인에서 개별 필터를 나타내는 노드
struct FilterNode: Identifiable, Equatable {
    let id = UUID()
    var filterType: FilterType
    var intensity: Float
    var isEnabled: Bool
    
    init(filterType: FilterType, intensity: Float? = nil, isEnabled: Bool = true) {
        self.filterType = filterType
        // 기본값이 없으면 필터 타입의 기본값 사용
        self.intensity = intensity ?? filterType.intensityRange.defaultValue
        self.isEnabled = isEnabled
    }
    
    /// 강도를 0~1 범위로 정규화
    var normalizedIntensity: Float {
        let range = filterType.intensityRange
        return (intensity - range.min) / (range.max - range.min)
    }
    
    /// 정규화된 값에서 실제 강도로 변환
    mutating func setNormalizedIntensity(_ normalized: Float) {
        let range = filterType.intensityRange
        intensity = range.min + normalized * (range.max - range.min)
    }
    
    static func == (lhs: FilterNode, rhs: FilterNode) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 필터 체인
/// 여러 필터를 순서대로 적용하는 체인
@Observable
class FilterChain {
    /// 체인에 포함된 필터 노드들
    var nodes: [FilterNode] = []
    
    /// 활성화된 필터만 반환
    var activeNodes: [FilterNode] {
        nodes.filter { $0.isEnabled }
    }
    
    /// 체인이 비어있는지 확인
    var isEmpty: Bool {
        nodes.isEmpty
    }
    
    /// 활성화된 필터가 있는지 확인
    var hasActiveFilters: Bool {
        !activeNodes.isEmpty
    }
    
    /// 필터 추가
    func addFilter(_ filterType: FilterType) {
        let node = FilterNode(filterType: filterType)
        nodes.append(node)
    }
    
    /// 필터 제거
    func removeFilter(at index: Int) {
        guard nodes.indices.contains(index) else { return }
        nodes.remove(at: index)
    }
    
    /// 필터 제거 (ID로)
    func removeFilter(id: UUID) {
        nodes.removeAll { $0.id == id }
    }
    
    /// 필터 순서 변경
    func moveFilter(from source: IndexSet, to destination: Int) {
        nodes.move(fromOffsets: source, toOffset: destination)
    }
    
    /// 필터 활성화/비활성화 토글
    func toggleFilter(id: UUID) {
        if let index = nodes.firstIndex(where: { $0.id == id }) {
            nodes[index].isEnabled.toggle()
        }
    }
    
    /// 필터 강도 업데이트
    func updateIntensity(id: UUID, intensity: Float) {
        if let index = nodes.firstIndex(where: { $0.id == id }) {
            nodes[index].intensity = intensity
        }
    }
    
    /// 모든 필터 초기화
    func clearAll() {
        nodes.removeAll()
    }
    
    /// 모든 필터 활성화
    func enableAll() {
        for index in nodes.indices {
            nodes[index].isEnabled = true
        }
    }
    
    /// 모든 필터 비활성화
    func disableAll() {
        for index in nodes.indices {
            nodes[index].isEnabled = false
        }
    }
    
    /// 프리셋 적용
    func applyPreset(_ preset: FilterPreset) {
        clearAll()
        for config in preset.filters {
            var node = FilterNode(filterType: config.filterType)
            node.intensity = config.intensity
            nodes.append(node)
        }
    }
}

// MARK: - 필터 프리셋
/// 미리 정의된 필터 조합
struct FilterPreset: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let filters: [FilterConfig]
    
    struct FilterConfig {
        let filterType: FilterType
        let intensity: Float
    }
}

// MARK: - 기본 프리셋
extension FilterPreset {
    /// 빈티지 프리셋
    static let vintage = FilterPreset(
        name: "빈티지",
        icon: "clock.arrow.circlepath",
        filters: [
            FilterConfig(filterType: .sepiaTone, intensity: 0.6),
            FilterConfig(filterType: .vignette, intensity: 1.2),
            FilterConfig(filterType: .vibrance, intensity: -0.2)
        ]
    )
    
    /// 드라마틱 프리셋
    static let dramatic = FilterPreset(
        name: "드라마틱",
        icon: "theatermasks",
        filters: [
            FilterConfig(filterType: .photoEffectNoir, intensity: 1.0),
            FilterConfig(filterType: .vignetteEffect, intensity: 0.8)
        ]
    )
    
    /// 몽환적 프리셋
    static let dreamy = FilterPreset(
        name: "몽환적",
        icon: "cloud",
        filters: [
            FilterConfig(filterType: .gaussianBlur, intensity: 3),
            FilterConfig(filterType: .bloom, intensity: 0.7),
            FilterConfig(filterType: .photoEffectFade, intensity: 1.0)
        ]
    )
    
    /// 팝아트 프리셋
    static let popArt = FilterPreset(
        name: "팝아트",
        icon: "star.circle",
        filters: [
            FilterConfig(filterType: .vibrance, intensity: 1.0),
            FilterConfig(filterType: .photoEffectChrome, intensity: 1.0),
            FilterConfig(filterType: .edges, intensity: 0.5)
        ]
    )
    
    /// 레트로 프리셋
    static let retro = FilterPreset(
        name: "레트로",
        icon: "camera.filters",
        filters: [
            FilterConfig(filterType: .photoEffectInstant, intensity: 1.0),
            FilterConfig(filterType: .vignetteEffect, intensity: 0.5),
            FilterConfig(filterType: .colorMonochrome, intensity: 0.2)
        ]
    )
    
    /// 스케치 프리셋
    static let sketch = FilterPreset(
        name: "스케치",
        icon: "pencil.and.outline",
        filters: [
            FilterConfig(filterType: .edgeWork, intensity: 3.0),
            FilterConfig(filterType: .colorInvert, intensity: 1.0)
        ]
    )
    
    /// 모든 프리셋
    static let allPresets: [FilterPreset] = [
        .vintage, .dramatic, .dreamy, .popArt, .retro, .sketch
    ]
}

// MARK: - 체인 상태 저장/복원
extension FilterChain {
    /// 체인 상태를 저장 가능한 형태로 변환
    func exportState() -> [[String: Any]] {
        nodes.map { node in
            [
                "filterType": node.filterType.rawValue,
                "intensity": node.intensity,
                "isEnabled": node.isEnabled
            ]
        }
    }
    
    /// 저장된 상태에서 체인 복원
    func importState(_ state: [[String: Any]]) {
        nodes.removeAll()
        
        for item in state {
            guard let filterTypeRaw = item["filterType"] as? String,
                  let filterType = FilterType(rawValue: filterTypeRaw),
                  let intensity = item["intensity"] as? Float,
                  let isEnabled = item["isEnabled"] as? Bool else {
                continue
            }
            
            var node = FilterNode(filterType: filterType, intensity: intensity)
            node.isEnabled = isEnabled
            nodes.append(node)
        }
    }
}
