import Foundation
import MusicKit

// 재생 시간 포맷팅

extension TimeInterval {
    /// "3:45" 형식으로 변환
    var formattedDuration: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
    
    /// "1:23:45" 형식으로 변환 (1시간 이상일 때)
    var formattedDurationLong: String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
}

// Song에서 사용
func displaySongDuration(_ song: Song) {
    if let duration = song.duration {
        print("\(song.title) - \(duration.formattedDuration)")
        // 출력: "Blueming - 3:35"
    }
}

// DateComponentsFormatter 사용 (대안)
let durationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = .pad
    formatter.unitsStyle = .positional
    return formatter
}()

func formatWithFormatter(_ duration: TimeInterval) -> String {
    durationFormatter.string(from: duration) ?? "0:00"
}
