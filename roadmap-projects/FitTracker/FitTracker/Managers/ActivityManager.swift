import Foundation
import ActivityKit

// MARK: - Live Activity Attributes
struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedTime: TimeInterval
        var distance: Double
        var calories: Double
        var heartRate: Int
        var pace: String
    }
    
    var workoutType: String
    var startTime: Date
}

// MARK: - Activity Manager
@Observable
final class ActivityManager {
    private var currentActivity: Activity<WorkoutActivityAttributes>?
    
    var isActivityRunning: Bool {
        currentActivity != nil
    }
    
    // MARK: - Start Activity
    func startActivity(workoutType: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities가 비활성화됨")
            return
        }
        
        let attributes = WorkoutActivityAttributes(
            workoutType: workoutType,
            startTime: Date()
        )
        
        let initialState = WorkoutActivityAttributes.ContentState(
            elapsedTime: 0,
            distance: 0,
            calories: 0,
            heartRate: 0,
            pace: "--:--"
        )
        
        let content = ActivityContent(
            state: initialState,
            staleDate: nil
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Live Activity 시작 실패: \(error)")
        }
    }
    
    // MARK: - Update Activity
    func updateActivity(
        elapsedTime: TimeInterval,
        distance: Double,
        calories: Double,
        heartRate: Int,
        pace: String
    ) async {
        guard let activity = currentActivity else { return }
        
        let updatedState = WorkoutActivityAttributes.ContentState(
            elapsedTime: elapsedTime,
            distance: distance,
            calories: calories,
            heartRate: heartRate,
            pace: pace
        )
        
        let content = ActivityContent(
            state: updatedState,
            staleDate: nil
        )
        
        await activity.update(content)
    }
    
    // MARK: - End Activity
    func endActivity(
        finalDistance: Double,
        finalCalories: Double,
        finalTime: TimeInterval
    ) async {
        guard let activity = currentActivity else { return }
        
        let finalState = WorkoutActivityAttributes.ContentState(
            elapsedTime: finalTime,
            distance: finalDistance,
            calories: finalCalories,
            heartRate: 0,
            pace: "완료"
        )
        
        let content = ActivityContent(
            state: finalState,
            staleDate: nil
        )
        
        await activity.end(content, dismissalPolicy: .default)
        currentActivity = nil
    }
}

// MARK: - Time Formatter
extension TimeInterval {
    var formatted: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
