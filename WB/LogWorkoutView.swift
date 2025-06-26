//
//  LogWorkoutView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI
import SwiftData

struct LogWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var dataManager = DataManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var selectedDifficulty: String?
    @State private var selectedExercises: [Exercise] = []
    
    let onWorkoutCreated: (WorkoutLog) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter
                VStack(spacing: 12) {
                    TextField("Search exercises...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(dataManager.exerciseCategories(), id: \.self) { category in
                                FilterChip(title: category, isSelected: selectedCategory == category) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All Levels", isSelected: selectedDifficulty == nil) {
                                selectedDifficulty = nil
                            }
                            
                            ForEach(dataManager.exerciseDifficulties(), id: \.self) { difficulty in
                                FilterChip(title: difficulty, isSelected: selectedDifficulty == difficulty) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Exercises List
                List {
                    ForEach(dataManager.filteredExercises(searchText: searchText, selectedCategory: selectedCategory, selectedDifficulty: selectedDifficulty)) { exercise in
                        ExerciseRow(
                            exercise: exercise,
                            isSelected: selectedExercises.contains { $0.exercise == exercise.exercise }
                        ) {
                            if selectedExercises.contains(where: { $0.exercise == exercise.exercise }) {
                                selectedExercises.removeAll { $0.exercise == exercise.exercise }
                            } else {
                                selectedExercises.append(exercise)
                            }
                        }
                    }
                }
                
                // Selected Exercises Summary
                if !selectedExercises.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Exercises (\(selectedExercises.count))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(selectedExercises, id: \.exercise) { exercise in
                                    SelectedExerciseRow(exercise: exercise) {
                                        selectedExercises.removeAll { $0.exercise == exercise.exercise }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                    }
                    .padding(.vertical)
                    .background(Color(.systemGray6))
                }
            }
            .navigationTitle("Log Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start") {
                        startWorkout()
                    }
                    .disabled(selectedExercises.isEmpty)
                }
            }
        }
    }
    
    private func startWorkout() {
        let workoutExercises = selectedExercises.map { exercise in
            let isCardio = dataManager.isCardioExercise(exercise)
            return WorkoutExercise(
                exercise: exercise.exercise,
                category: exercise.category,
                difficulty: exercise.difficulty,
                isCardio: isCardio
            )
        }
        
        let workout = WorkoutLog(
            date: Date(),
            name: "",
            exercises: workoutExercises
        )
        
        modelContext.insert(workout)
        
        do {
            try modelContext.save()
            onWorkoutCreated(workout)
            dismiss()
        } catch {
            print("Error creating workout: \(error)")
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exercise)
                    .font(.headline)
                
                HStack {
                    Text(exercise.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    Text(exercise.difficulty)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(difficultyColor.opacity(0.2))
                        .foregroundColor(difficultyColor)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            Button(isSelected ? "Remove" : "Add") {
                onToggle()
            }
            .foregroundColor(isSelected ? .red : .blue)
        }
        .padding(.vertical, 4)
    }
    
    private var difficultyColor: Color {
        switch exercise.difficulty.lowercased() {
        case "beginner":
            return .green
        case "intermediate":
            return .orange
        case "advanced":
            return .red
        case "elite":
            return .purple
        default:
            return .gray
        }
    }
}

struct SelectedExerciseRow: View {
    let exercise: Exercise
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exercise)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(exercise.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    LogWorkoutView { _ in }
        .modelContainer(for: WorkoutLog.self, inMemory: true)
} 