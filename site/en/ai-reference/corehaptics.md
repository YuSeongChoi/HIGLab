# Core Haptics AI Reference

> 햅틱 피드백 구현 가이드. 이 문서를 읽고 Core Haptics 코드를 생성할 수 있습니다.

## 개요

Core Haptics는 커스텀 햅틱(진동) 패턴을 생성하고 재생하는 프레임워크입니다.
게임, 알림, UI 피드백에 풍부한 촉각 경험을 제공합니다.

## 필수 Import

```swift
import CoreHaptics
```

## 핵심 구성요소

### 1. 햅틱 엔진 설정

```swift
class HapticManager {
    private var engine: CHHapticEngine?
    
    init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("햅틱 미지원 기기")
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // 엔진 리셋 핸들러
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            
            // 엔진 중지 핸들러
            engine?.stoppedHandler = { reason in
                print("엔진 중지: \(reason)")
            }
        } catch {
            print("햅틱 엔진 초기화 실패: \(error)")
        }
    }
}
```

### 2. 간단한 UIKit 햅틱

```swift
// 가장 간단한 방법 (UIKit)
let impact = UIImpactFeedbackGenerator(style: .medium)
impact.impactOccurred()

// 스타일: .light, .medium, .heavy, .soft, .rigid

// 알림 햅틱
let notification = UINotificationFeedbackGenerator()
notification.notificationOccurred(.success)  // .success, .warning, .error

// 선택 햅틱
let selection = UISelectionFeedbackGenerator()
selection.selectionChanged()
```

## 전체 작동 예제

```swift
import SwiftUI
import CoreHaptics

// MARK: - Haptic Manager
@Observable
class HapticManager {
    private var engine: CHHapticEngine?
    var supportsHaptics: Bool
    
    init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        setupEngine()
    }
    
    private func setupEngine() {
        guard supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            engine?.playsHapticsOnly = true
            
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            
            try engine?.start()
        } catch {
            print("햅틱 엔진 설정 실패: \(error)")
        }
    }
    
    // MARK: - 기본 햅틱
    func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - 커스텀 햅틱 패턴
    func playCustomPattern() {
        guard let engine else { return }
        
        do {
            // 이벤트 정의
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            
            // 탭 이벤트
            let tap = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [sharpness, intensity],
                relativeTime: 0
            )
            
            // 연속 진동
            let continuous = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [sharpness, intensity],
                relativeTime: 0.1,
                duration: 0.3
            )
            
            let pattern = try CHHapticPattern(events: [tap, continuous], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("커스텀 햅틱 재생 실패: \(error)")
        }
    }
    
    // 심박동 패턴
    func playHeartbeat() {
        guard let engine else { return }
        
        do {
            var events: [CHHapticEvent] = []
            
            for beat in 0..<4 {
                let time = Double(beat) * 0.6
                
                // 강한 박동
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                    ],
                    relativeTime: time
                ))
                
                // 약한 박동 (0.15초 후)
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: time + 0.15
                ))
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("심박동 햅틱 실패: \(error)")
        }
    }
    
    // 성공 패턴
    func playSuccess() {
        guard let engine else { return }
        
        do {
            let events = [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                    ],
                    relativeTime: 0
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                    ],
                    relativeTime: 0.1
                )
            ]
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("성공 햅틱 실패: \(error)")
        }
    }
    
    // 에러 패턴
    func playError() {
        guard let engine else { return }
        
        do {
            var events: [CHHapticEvent] = []
            
            for i in 0..<3 {
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                    ],
                    relativeTime: Double(i) * 0.1
                ))
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("에러 햅틱 실패: \(error)")
        }
    }
}

// MARK: - Views
struct HapticDemoView: View {
    @State private var haptic = HapticManager()
    
    var body: some View {
        NavigationStack {
            List {
                Section("기본 햅틱") {
                    Button("Light Impact") {
                        haptic.playImpact(style: .light)
                    }
                    
                    Button("Medium Impact") {
                        haptic.playImpact(style: .medium)
                    }
                    
                    Button("Heavy Impact") {
                        haptic.playImpact(style: .heavy)
                    }
                    
                    Button("Selection") {
                        haptic.playSelection()
                    }
                }
                
                Section("알림 햅틱") {
                    Button("Success") {
                        haptic.playNotification(type: .success)
                    }
                    .tint(.green)
                    
                    Button("Warning") {
                        haptic.playNotification(type: .warning)
                    }
                    .tint(.orange)
                    
                    Button("Error") {
                        haptic.playNotification(type: .error)
                    }
                    .tint(.red)
                }
                
                Section("커스텀 패턴") {
                    Button("Custom Pattern") {
                        haptic.playCustomPattern()
                    }
                    
                    Button("Heartbeat 💓") {
                        haptic.playHeartbeat()
                    }
                    
                    Button("Success ✓") {
                        haptic.playSuccess()
                    }
                    
                    Button("Error ✗") {
                        haptic.playError()
                    }
                }
                
                if !haptic.supportsHaptics {
                    Section {
                        Text("이 기기는 햅틱을 지원하지 않습니다")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("햅틱 데모")
        }
    }
}
```

## 고급 패턴

### 1. AHAP 파일 사용

```swift
// AHAP (Apple Haptic Audio Pattern) 파일 로드
func playFromFile(named filename: String) {
    guard let engine,
          let url = Bundle.main.url(forResource: filename, withExtension: "ahap") else { return }
    
    do {
        try engine.playPattern(from: url)
    } catch {
        print("AHAP 재생 실패: \(error)")
    }
}
```

**AHAP 파일 예시 (success.ahap)**:
```json
{
  "Version": 1.0,
  "Pattern": [
    {
      "Event": {
        "Time": 0.0,
        "EventType": "HapticTransient",
        "EventParameters": [
          {"ParameterID": "HapticIntensity", "ParameterValue": 0.8},
          {"ParameterID": "HapticSharpness", "ParameterValue": 0.4}
        ]
      }
    },
    {
      "Event": {
        "Time": 0.1,
        "EventType": "HapticTransient",
        "EventParameters": [
          {"ParameterID": "HapticIntensity", "ParameterValue": 1.0},
          {"ParameterID": "HapticSharpness", "ParameterValue": 0.6}
        ]
      }
    }
  ]
}
```

### 2. 실시간 파라미터 조절

```swift
func playWithDynamicControl() throws {
    guard let engine else { return }
    
    // 연속 진동 이벤트
    let event = CHHapticEvent(
        eventType: .hapticContinuous,
        parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        ],
        relativeTime: 0,
        duration: 2.0
    )
    
    // 동적 파라미터 (시간에 따라 변화)
    let curve = CHHapticParameterCurve(
        parameterID: .hapticIntensityControl,
        controlPoints: [
            CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.2),
            CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 1.0),
            CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 0.2)
        ],
        relativeTime: 0
    )
    
    let pattern = try CHHapticPattern(events: [event], parameterCurves: [curve])
    let player = try engine.makeAdvancedPlayer(with: pattern)
    try player.start(atTime: 0)
}
```

### 3. 오디오와 햅틱 동기화

```swift
func playAudioHaptic() {
    guard let engine else { return }
    
    engine.playsHapticsOnly = false  // 오디오도 재생
    
    do {
        let audioEvent = CHHapticEvent(
            eventType: .audioContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .audioVolume, value: 0.5)
            ],
            relativeTime: 0,
            duration: 1.0
        )
        
        let hapticEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
            ],
            relativeTime: 0,
            duration: 1.0
        )
        
        let pattern = try CHHapticPattern(events: [audioEvent, hapticEvent], parameters: [])
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: 0)
    } catch {
        print("오디오-햅틱 실패: \(error)")
    }
}
```

## 주의사항

1. **기기 지원 확인**
   ```swift
   CHHapticEngine.capabilitiesForHardware().supportsHaptics
   CHHapticEngine.capabilitiesForHardware().supportsAudio
   ```

2. **엔진 라이프사이클**
   - 앱 백그라운드 시 엔진 자동 중지
   - `resetHandler`에서 재시작 처리

3. **배터리 고려**
   - 과도한 햅틱은 배터리 소모
   - 짧고 의미 있는 피드백 권장

4. **시뮬레이터 제한**
   - 시뮬레이터에서는 햅틱 체험 불가
   - 실제 기기에서 테스트 필요
