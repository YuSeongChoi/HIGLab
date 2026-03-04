//
//  ActivityMonitor.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/4/26.
//

import Foundation
import ActivityKit
import Combine
import os

// 이 파일은 활성 Live Activity 목록을 실시간으로 추적하는 모니터링 도우미입니다.
// MARK: - Activity 모니터링 유틸리티
@MainActor
final class ActivityMonitor<T: ActivityAttributes>: ObservableObject {
    @Published private(set) var activities: [Activity<T>] = []
    private var updateTask: Task<Void, Never>?
    
    init() {
        refreshActivities()
        startMonitoring()
    }
    
    deinit {
        updateTask?.cancel()
    }
    
    // MARK: - 활성 Activity 조회
    
    func refreshActivities() {
        activities = Activity<T>.activities
    }
    
    // MARK: - 실시간 모니터링
    
    private func startMonitoring() {
        updateTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await activity in Activity<T>.activityUpdates {
                AppActivityLogger.lifecycle.debug("Activity 업데이트 감지: \(activity.id)")
                self.refreshActivities()
            }
        }
    }
}
