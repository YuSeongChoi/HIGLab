// SoundPickerView.swift
// WakeUp - AlarmKit 샘플 프로젝트
// 알람 사운드 선택 화면

import SwiftUI
import AVFoundation

// MARK: - 사운드 피커 뷰

/// 알람 사운드를 선택하는 시트
struct SoundPickerView: View {
    
    // MARK: - 환경 및 상태
    
    @Environment(\.dismiss) private var dismiss
    
    /// 선택된 사운드 (바인딩)
    @Binding var selectedSound: AlarmSound
    
    /// 현재 미리듣기 중인 사운드
    @State private var previewingSound: AlarmSound?
    
    /// 오디오 플레이어
    @State private var audioPlayer: AVAudioPlayer?
    
    // MARK: - 본문
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(AlarmSound.orderedCategories) { category in
                    Section(category.displayName) {
                        ForEach(category.sounds) { sound in
                            SoundRow(
                                sound: sound,
                                isSelected: selectedSound == sound,
                                isPreviewing: previewingSound == sound,
                                onSelect: {
                                    selectSound(sound)
                                },
                                onPreview: {
                                    togglePreview(sound)
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("알람 사운드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        stopPreview()
                        dismiss()
                    }
                }
            }
            .onDisappear {
                stopPreview()
            }
        }
        .presentationDetents([.large])
    }
    
    // MARK: - 액션
    
    /// 사운드 선택
    private func selectSound(_ sound: AlarmSound) {
        selectedSound = sound
        
        // 선택 시 짧은 미리듣기
        playPreview(sound, duration: 2.0)
    }
    
    /// 미리듣기 토글
    private func togglePreview(_ sound: AlarmSound) {
        if previewingSound == sound {
            stopPreview()
        } else {
            playPreview(sound, duration: 5.0)
        }
    }
    
    /// 미리듣기 재생
    private func playPreview(_ sound: AlarmSound, duration: TimeInterval) {
        stopPreview()
        
        guard sound.hasSound else {
            // 진동만 또는 무음인 경우
            if sound.hasVibration {
                // 진동 피드백
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
            return
        }
        
        previewingSound = sound
        
        // 실제 앱에서는 번들의 사운드 파일을 재생
        // 여기서는 시스템 사운드 사용 예시
        // guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "m4a") else {
        //     return
        // }
        
        // 데모용: 타이머로 미리듣기 종료
        Task {
            try? await Task.sleep(for: .seconds(duration))
            await MainActor.run {
                if previewingSound == sound {
                    stopPreview()
                }
            }
        }
    }
    
    /// 미리듣기 정지
    private func stopPreview() {
        audioPlayer?.stop()
        audioPlayer = nil
        previewingSound = nil
    }
}

// MARK: - 사운드 행

/// 개별 사운드를 표시하는 행
struct SoundRow: View {
    
    let sound: AlarmSound
    let isSelected: Bool
    let isPreviewing: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 사운드 아이콘
            Image(systemName: sound.iconName)
                .font(.title3)
                .foregroundStyle(isSelected ? .orange : .secondary)
                .frame(width: 32)
            
            // 사운드 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(sound.displayName)
                    .fontWeight(isSelected ? .medium : .regular)
                
                Text(sound.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 미리듣기 버튼
            if sound.hasSound {
                Button {
                    onPreview()
                } label: {
                    Image(systemName: isPreviewing ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(isPreviewing ? .orange : .secondary)
                }
                .buttonStyle(.plain)
            }
            
            // 선택 표시
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - 사운드 프리뷰 카드

/// 현재 선택된 사운드를 표시하는 카드
struct SoundPreviewCard: View {
    
    let sound: AlarmSound
    @State private var isPlaying: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(Color.orange.gradient)
                    .frame(width: 56, height: 56)
                
                Image(systemName: sound.iconName)
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(sound.displayName)
                    .font(.headline)
                
                Text(sound.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // 속성 태그
                HStack(spacing: 8) {
                    if sound.hasSound {
                        Label("소리", systemImage: "speaker.wave.2.fill")
                    }
                    if sound.hasVibration {
                        Label("진동", systemImage: "waveform")
                    }
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            // 재생 버튼
            if sound.hasSound {
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 사운드 그리드 뷰

/// 사운드를 그리드로 표시하는 대안적 뷰
struct SoundGridView: View {
    
    @Binding var selectedSound: AlarmSound
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(AlarmSound.allCases) { sound in
                SoundGridItem(
                    sound: sound,
                    isSelected: selectedSound == sound
                ) {
                    selectedSound = sound
                }
            }
        }
        .padding()
    }
}

/// 그리드의 개별 사운드 아이템
struct SoundGridItem: View {
    
    let sound: AlarmSound
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.orange : Color.secondary.opacity(0.2))
                        .frame(height: 64)
                    
                    Image(systemName: sound.iconName)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
                
                Text(sound.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .medium : .regular)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 미리보기

#Preview("사운드 피커") {
    @Previewable @State var sound = AlarmSound.sunrise
    SoundPickerView(selectedSound: $sound)
}

#Preview("사운드 카드") {
    SoundPreviewCard(sound: .sunrise)
        .padding()
}

#Preview("사운드 그리드") {
    @Previewable @State var sound = AlarmSound.energetic
    SoundGridView(selectedSound: $sound)
}
