//
//  MainTabView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI

enum MainTab: Hashable {
    case nutrition, dashboard, workouts
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NutritionView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Nutrition")
                }
                .tag(MainTab.nutrition)
            
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .tag(MainTab.dashboard)
            
            WorkoutsView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workouts")
                }
                .tag(MainTab.workouts)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [UserProfile.self, BodyMeasurements.self, MealLog.self, WaterLog.self, WorkoutLog.self], inMemory: true)
} 