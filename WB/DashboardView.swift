//
//  DashboardView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var bodyMeasurements: [BodyMeasurements]
    @Query private var mealLogs: [MealLog]
    @Query private var waterLogs: [WaterLog]
    @Query private var workoutLogs: [WorkoutLog]
    
    @State private var showingUserProfile = false
    @State private var showingBodyMeasurements = false
    @State private var showingNutritionHistory = false
    @State private var showingWorkoutHistory = false
    @State private var selectedMonth = Date()
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingPhotoOptions = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Picture Section
                    if let userProfile = userProfiles.first {
                        VStack {
                            Button(action: { showingPhotoOptions = true }) {
                                if let data = userProfile.profileImage, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 16)
                            .confirmationDialog("Profile Photo", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
                                Button("Update Profile Photo") { showingImagePicker = true }
                                if userProfile.profileImage != nil {
                                    Button("Delete Profile Photo", role: .destructive) {
                                        userProfile.profileImage = nil
                                        try? modelContext.save()
                                    }
                                }
                                Button("Cancel", role: .cancel) {}
                            }
                            .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhotoItem, matching: .images)
                            .onChange(of: selectedPhotoItem, initial: false) { _, newItem in
                                if let newItem {
                                    Task {
                                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                                            userProfile.profileImage = data
                                            try? modelContext.save()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // User Information Section
                    UserInfoSection(
                        userProfile: userProfiles.first,
                        onEdit: { showingUserProfile = true }
                    )
                    
                    // Body Measurements Section
                    BodyMeasurementsSection(
                        measurements: latestBodyMeasurements,
                        onEdit: { showingBodyMeasurements = true }
                    )
                    
                    // Statistics Section
                    StatisticsSection(
                        selectedMonth: $selectedMonth,
                        mealLogs: mealLogs,
                        waterLogs: waterLogs,
                        workoutLogs: workoutLogs,
                        onNutritionTap: { showingNutritionHistory = true },
                        onWorkoutTap: { showingWorkoutHistory = true }
                    )
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showingUserProfile) {
                UserProfileView(userProfile: userProfiles.first)
            }
            .sheet(isPresented: $showingBodyMeasurements) {
                BodyMeasurementsView(measurements: latestBodyMeasurements)
            }
            .sheet(isPresented: $showingNutritionHistory) {
                NutritionHistoryView()
            }
            .sheet(isPresented: $showingWorkoutHistory) {
                WorkoutHistoryView()
            }
        }
    }
    
    private var latestBodyMeasurements: BodyMeasurements? {
        bodyMeasurements.max(by: { $0.date < $1.date })
    }
}

// MARK: - User Info Section
struct UserInfoSection: View {
    let userProfile: UserProfile?
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("User Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Edit") {
                    onEdit()
                }
                .foregroundColor(.blue)
            }
            
            if let profile = userProfile {
                VStack(spacing: 12) {
                    InfoRow(label: "Name", value: profile.name.isEmpty ? "Not set" : profile.name)
                    InfoRow(label: "Age", value: profile.age == 0 ? "Not set" : "\(profile.age) years")
                    InfoRow(label: "Sex", value: profile.sex.isEmpty ? "Not set" : profile.sex)
                    InfoRow(label: "Height", value: profile.height == 0 ? "Not set" : "\(Int(profile.height)) cm")
                    InfoRow(label: "Weight", value: profile.weight == 0 ? "Not set" : "\(String(format: "%.1f", profile.weight)) kg")
                    InfoRow(label: "Goal", value: profile.personalGoal.isEmpty ? "Not set" : profile.personalGoal)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No user profile")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Tap Edit to create your profile")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Body Measurements Section
struct BodyMeasurementsSection: View {
    let measurements: BodyMeasurements?
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Body Measurements")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Edit") {
                    onEdit()
                }
                .foregroundColor(.blue)
            }
            
            if let measurements = measurements {
                VStack(spacing: 12) {
                    InfoRow(label: "Height", value: "\(Int(measurements.height)) cm")
                    InfoRow(label: "Weight", value: "\(String(format: "%.1f", measurements.weight)) kg")
                    InfoRow(label: "Arm Circumference", value: "\(String(format: "%.1f", measurements.armCircumference)) cm")
                    InfoRow(label: "Leg Circumference", value: "\(String(format: "%.1f", measurements.legCircumference)) cm")
                    InfoRow(label: "Belly Circumference", value: "\(String(format: "%.1f", measurements.bellyCircumference)) cm")
                    InfoRow(label: "Body Fat %", value: "\(String(format: "%.1f", measurements.bodyFatPercentage))%")
                    InfoRow(label: "Muscle Mass", value: "\(String(format: "%.1f", measurements.muscleMass)) kg")
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "ruler")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No measurements")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Tap Edit to add your measurements")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Statistics Section
struct StatisticsSection: View {
    @Binding var selectedMonth: Date
    let mealLogs: [MealLog]
    let waterLogs: [WaterLog]
    let workoutLogs: [WorkoutLog]
    let onNutritionTap: () -> Void
    let onWorkoutTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Statistics")
                .font(.title2)
                .fontWeight(.bold)
            
            // Month Selector
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Calendar View
            MonthlyCalendarView(
                selectedMonth: selectedMonth,
                mealLogs: mealLogs,
                waterLogs: waterLogs,
                workoutLogs: workoutLogs,
                onNutritionTap: onNutritionTap,
                onWorkoutTap: onWorkoutTap
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
}

// MARK: - Monthly Calendar View
struct MonthlyCalendarView: View {
    let selectedMonth: Date
    let mealLogs: [MealLog]
    let waterLogs: [WaterLog]
    let workoutLogs: [WorkoutLog]
    let onNutritionTap: () -> Void
    let onWorkoutTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Day headers
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            hasMeals: hasMeals(on: date),
                            hasWater: hasWater(on: date),
                            hasWorkouts: hasWorkouts(on: date),
                            onNutritionTap: onNutritionTap,
                            onWorkoutTap: onWorkoutTap
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
    }
    
    private var calendarDays: [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedMonth)?.start ?? selectedMonth
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty days for padding
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasMeals(on date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        return mealLogs.contains { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    private func hasWater(on date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        return waterLogs.contains { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    private func hasWorkouts(on date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        return workoutLogs.contains { $0.date >= startOfDay && $0.date < endOfDay }
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let hasMeals: Bool
    let hasWater: Bool
    let hasWorkouts: Bool
    let onNutritionTap: () -> Void
    let onWorkoutTap: () -> Void
    
    var body: some View {
        Button(action: {
            if hasMeals || hasWater {
                onNutritionTap()
            } else if hasWorkouts {
                onWorkoutTap()
            }
        }) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.caption)
                    .fontWeight(.medium)
                
                HStack(spacing: 2) {
                    if hasMeals {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 4, height: 4)
                    }
                    if hasWater {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 4, height: 4)
                    }
                    if hasWorkouts {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(hasMeals || hasWater || hasWorkouts ? Color(.systemGray5) : Color.clear)
            )
        }
        .disabled(!hasMeals && !hasWater && !hasWorkouts)
    }
}

// MARK: - Supporting Views
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [UserProfile.self, BodyMeasurements.self, MealLog.self, WaterLog.self, WorkoutLog.self], inMemory: true)
} 