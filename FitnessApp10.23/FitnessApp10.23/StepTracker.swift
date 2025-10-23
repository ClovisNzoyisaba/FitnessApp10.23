//
//  StepTracker.swift
//  FitnessApp10.23
//
//  Created by Clovis Nzoyisaba on 10/23/25.
//

import Foundation
import HealthKit

class StepTracker: ObservableObject {
    @Published var currentSteps: Int = 0
    @Published var dailyGoal: Int = 10000
    @Published var isAuthorized: Bool = false
    
    private let healthStore = HKHealthStore()
    
    init() {
        requestHealthKitPermission()
        loadTodaySteps()
    }
    
    // Request permission to access HealthKit data
    func requestHealthKitPermission() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        healthStore.requestAuthorization(toShare: nil, read: [stepType]) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.loadTodaySteps()
                }
            }
        }
    }
    
    // Load today's step count from HealthKit
    func loadTodaySteps() {
        guard isAuthorized else { return }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let result = result, let sum = result.sumQuantity() {
                    self?.currentSteps = Int(sum.doubleValue(for: HKUnit.count()))
                } else {
                    // If no data available, use a mock value for demonstration
                    self?.currentSteps = Int.random(in: 2000...8000)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // Set daily step goal
    func setDailyGoal(_ goal: Int) {
        dailyGoal = max(1000, goal) // Minimum 1000 steps
    }
    
    // Calculate progress percentage
    var progressPercentage: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(currentSteps) / Double(dailyGoal), 1.0)
    }
    
    // Check if goal is achieved
    var isGoalAchieved: Bool {
        return currentSteps >= dailyGoal
    }
    
    // Get remaining steps to reach goal
    var remainingSteps: Int {
        return max(0, dailyGoal - currentSteps)
    }
    
    // Refresh step count
    func refreshSteps() {
        loadTodaySteps()
    }
}
