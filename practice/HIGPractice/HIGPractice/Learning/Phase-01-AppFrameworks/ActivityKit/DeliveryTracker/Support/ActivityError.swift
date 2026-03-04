//
//  ActivityError.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/4/26.
//

import Foundation
import ActivityKit
import os

// 이 파일은 ActivityKit 동작 중 발생 가능한 에러를 분류하고 안전 호출 래퍼를 제공합니다.
// MARK: - Activity 에러 정리
enum ActivityError: LocalizedError {
    case notSupported
    case disabled
    case limitExceeded
    case startFailed(Error)
    case updateFailed(Error)
    case endFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notSupported:
            return "이 기기는 Live Activity를 지원하지 않습니다"
        case .disabled:
            return "Live Activity가 비활성화되어 있습니다"
        case .limitExceeded:
            return "최대 Activity 개수를 초과했습니다"
        case .startFailed(let error):
            return "Activity 시작 실패: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Activity 업데이트 실패: \(error.localizedDescription)"
        case .endFailed(let error):
            return "Activity 종료 실패: \(error.localizedDescription)"
        }
    }
}

// MARK: - 안전한 Activity 관리자
struct SafeActivityManager {
    
    // 권한 확인 및 시작
    static func safeStart<T: ActivityAttributes>(
        attributes: T,
        state: T.ContentState,
        enablePushToken: Bool = false
    ) async throws -> Activity<T> {
        // 1. 지원 여부 확인
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            AppActivityLogger.logError(ActivityError.disabled, context: "시작 전 확인")
            throw ActivityError.disabled
        }
        
        // 2. 기존 Activity 정리 (필요시)
        let existingCount = Activity<T>.activities.count
        if existingCount >= 5 {
            AppActivityLogger.lifecycle.warning(
                "⚠️ Activity 개수 많음: \(existingCount). 정리 권장"
            )
        }
        
        // 3. 시작 시도
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: enablePushToken ? .token : nil
            )
            AppActivityLogger.logStart(id: activity.id, attributes: attributes)
            return activity
        } catch {
            AppActivityLogger.logError(error, context: "Activity 시작")
            throw ActivityError.startFailed(error)
        }
    }
    
    // 안전한 업데이트
    static func safeUpdate<T: ActivityAttributes>(
        activity: Activity<T>,
        state: T.ContentState
    ) async {
        do {
            await activity.update(
                ActivityContent(state: state, staleDate: nil)
            )
            AppActivityLogger.logUpdate(id: activity.id, state: state)
        } catch {
            AppActivityLogger.logError(error, context: "Activity 업데이트")
        }
    }

    // 안전한 종료
    static func safeEnd<T: ActivityAttributes>(
        activity: Activity<T>,
        finalState: T.ContentState? = nil,
        dismissalPolicy: ActivityUIDismissalPolicy = .default
    ) async {
        do {
            if let finalState {
                await activity.end(
                    ActivityContent(state: finalState, staleDate: nil),
                    dismissalPolicy: dismissalPolicy
                )
            } else {
                await activity.end(nil, dismissalPolicy: dismissalPolicy)
            }
            AppActivityLogger.logEnd(id: activity.id, reason: "단일 종료")
        } catch {
            AppActivityLogger.logError(error, context: "Activity 종료")
        }
    }
    
    // 모든 Activity 종료
    static func endAll<T: ActivityAttributes>(
        ofType type: T.Type,
        dismissalPolicy: ActivityUIDismissalPolicy = .immediate
    ) async {
        for activity in Activity<T>.activities {
            await activity.end(nil, dismissalPolicy: dismissalPolicy)
            AppActivityLogger.logEnd(id: activity.id, reason: "일괄 종료")
        }
    }
    
}
