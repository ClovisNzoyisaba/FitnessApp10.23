//
//  StepProgressView.swift
//  FitnessApp10.23
//
//  Created by Clovis Nzoyisaba on 10/23/25.
//

import SwiftUI

struct StepProgressView: View {
    @ObservedObject var stepTracker: StepTracker
    @State private var showingGoalSetting = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Today's Steps")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { stepTracker.refreshSteps() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            // Main step display
            VStack(spacing: 16) {
                // Step count with large number
                VStack(spacing: 8) {
                    Text("\(stepTracker.currentSteps)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("steps")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                // Progress ring
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: stepTracker.progressPercentage)
                        .stroke(
                            LinearGradient(
                                colors: stepTracker.isGoalAchieved ? [.green, .mint] : [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: stepTracker.progressPercentage)
                    
                    // Progress percentage
                    VStack {
                        Text("\(Int(stepTracker.progressPercentage * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("of goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Goal information
                VStack(spacing: 8) {
                    HStack {
                        Text("Daily Goal:")
                            .font(.headline)
                        Spacer()
                        Text("\(stepTracker.dailyGoal)")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    if !stepTracker.isGoalAchieved {
                        HStack {
                            Text("Remaining:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(stepTracker.remainingSteps)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Goal achieved!")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            
            // Goal setting button
            Button(action: { showingGoalSetting = true }) {
                HStack {
                    Image(systemName: "target")
                    Text("Set Daily Goal")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingGoalSetting) {
            GoalSettingView(stepTracker: stepTracker)
        }
    }
}

struct GoalSettingView: View {
    @ObservedObject var stepTracker: StepTracker
    @Environment(\.dismiss) private var dismiss
    @State private var newGoal: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Set Your Daily Step Goal")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose a realistic goal that motivates you to stay active throughout the day.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Goal: \(stepTracker.dailyGoal) steps")
                            .font(.headline)
                        
                        TextField("Enter new goal", text: $newGoal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .onAppear {
                                newGoal = String(stepTracker.dailyGoal)
                            }
                    }
                }
                
                // Quick goal buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Goals")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach([5000, 7500, 10000, 12000, 15000], id: \.self) { goal in
                            Button(action: { newGoal = String(goal) }) {
                                Text("\(goal)")
                                    .font(.headline)
                                    .foregroundColor(newGoal == String(goal) ? .white : .blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        newGoal == String(goal) ? Color.blue : Color.blue.opacity(0.1)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Daily Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let goal = Int(newGoal), goal >= 1000 {
                            stepTracker.setDailyGoal(goal)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    StepProgressView(stepTracker: StepTracker())
}
