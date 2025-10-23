//
//  ContentView.swift
//  FitnessApp10.23
//
//  Created by Clovis Nzoyisaba on 10/23/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var stepTracker = StepTracker()
    
    var body: some View {
        NavigationView {
            StepProgressView(stepTracker: stepTracker)
                .navigationTitle("Step Tracker")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}
