//
//  ActiveWorkoutView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI
import SwiftData

struct EditingSetInfo: Identifiable, Equatable {
    let exerciseIndex: Int
    let setIndex: Int
    var id: String { "\(exerciseIndex)-\(setIndex)" }
}

struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var workout: WorkoutLog
    let onWorkoutCompleted: () -> Void
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var isTimerRunning = false
    @State private var showingExerciseSelector = false
    @State private var showingSaveTemplate = false
    @State private var templateName = ""
    @State private var showTemplateSavedAlert = false
    struct ExerciseIndex: Identifiable, Equatable {
        let id: Int
    }
    @State private var selectedExerciseIndex: ExerciseIndex?
    @State private var showDeleteAlert = false
    @State private var editingSet: EditingSetInfo? = nil
    @State private var editingSetReps: Int = 0
    @State private var editingSetWeight: Double = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Timer Section
                VStack(spacing: 16) {
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                    
                    HStack(spacing: 20) {
                        Button(action: toggleTimer) {
                            Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(isTimerRunning ? .orange : .green)
                        }
                        
                        Button(action: resetTimer) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Exercises List
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Exercises (\(workout.exercises.count))")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button("Add Exercise") {
                            showingExerciseSelector = true
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    if workout.exercises.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "dumbbell")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No exercises")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Add exercises to start your workout")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(workout.exercises.enumerated()), id: \.offset) { index, exercise in
                                    ExerciseWorkoutRow(
                                        exercise: exercise,
                                        exerciseIndex: index,
                                        onAddSet: { addSet(to: index) },
                                        onRemoveSet: { removeSet(from: index) },
                                        onRemoveExercise: { removeExercise(at: index) },
                                        onEditSet: { setIndex in
                                            selectedExerciseIndex = ExerciseIndex(id: index)
                                        },
                                        onEditSetWithIndex: { exIdx, setIdx in
                                            editingSet = EditingSetInfo(exerciseIndex: exIdx, setIndex: setIdx)
                                            let set = workout.exercises[exIdx].sets[setIdx]
                                            editingSetReps = set.reps
                                            editingSetWeight = set.weight
                                        },
                                        cardioTime: Binding(
                                            get: { workout.exercises[index].cardioTime ?? 0 },
                                            set: { workout.exercises[index].cardioTime = $0 }
                                        ),
                                        cardioDistance: Binding(
                                            get: { workout.exercises[index].cardioDistance ?? 0 },
                                            set: { workout.exercises[index].cardioDistance = $0 }
                                        )
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: finishWorkout) {
                        Text("Finish Workout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(16)
                    }
                    Button(action: { showDeleteAlert = true }) {
                        Text("Cancel Workout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(16)
                    }
                    Button(action: { showingSaveTemplate = true }) {
                        Text("Save as Template")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle(workout.name.isEmpty ? "Active Workout" : workout.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Cancel Workout?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { cancelWorkout() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to cancel and delete this workout? This cannot be undone.")
            }
            .alert("Workout saved as template!", isPresented: $showTemplateSavedAlert) {
                Button("OK", role: .cancel) { }
            }
            .onReceive(timer) { _ in
                if isTimerRunning {
                    elapsedTime += 1
                }
            }
            .sheet(isPresented: $showingExerciseSelector) {
                AddExerciseToWorkoutView { exercise in
                    addExercise(exercise)
                }
            }
            .sheet(item: $selectedExerciseIndex) { index in
                EditExerciseSetsView(exercise: workout.exercises[index.id]) { updatedExercise in
                    workout.exercises[index.id] = updatedExercise
                }
            }
            .sheet(isPresented: $showingSaveTemplate) {
                NavigationView {
                    Form {
                        Section(header: Text("Template Name")) {
                            TextField("Enter name", text: $templateName)
                        }
                    }
                    .navigationTitle("Save as Template")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingSaveTemplate = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                saveAsTemplate()
                                showingSaveTemplate = false
                                templateName = ""
                            }
                            .disabled(templateName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
            }
            .sheet(item: $editingSet, onDismiss: { editingSet = nil }) { edit in
                NavigationView {
                    Form {
                        Section(header: Text("Edit Set \(edit.setIndex + 1)")) {
                            Stepper(value: $editingSetReps, in: 0...100) {
                                Text("Reps: \(editingSetReps)")
                            }
                            HStack {
                                Text("Weight (kg)")
                                Spacer()
                                TextField("Weight", value: $editingSetWeight, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                    .navigationTitle("Edit Set")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { editingSet = nil }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                if let exIdx = editingSet?.exerciseIndex, let setIdx = editingSet?.setIndex, exIdx < workout.exercises.count, setIdx < workout.exercises[exIdx].sets.count {
                                    workout.exercises[exIdx].sets[setIdx].reps = editingSetReps
                                    workout.exercises[exIdx].sets[setIdx].weight = editingSetWeight
                                }
                                editingSet = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func toggleTimer() {
        isTimerRunning.toggle()
    }
    
    private func resetTimer() {
        elapsedTime = 0
        isTimerRunning = false
    }
    
    private func addExercise(_ exercise: Exercise) {
        let isCardio = DataManager.shared.isCardioExercise(exercise)
        let workoutExercise = WorkoutExercise(
            exercise: exercise.exercise,
            category: exercise.category,
            difficulty: exercise.difficulty,
            isCardio: isCardio
        )
        workout.exercises.append(workoutExercise)
    }
    
    private func removeExercise(at index: Int) {
        workout.exercises.remove(at: index)
    }
    
    private func addSet(to exerciseIndex: Int) {
        let exercise = workout.exercises[exerciseIndex]
        let newSetNumber = exercise.sets.count + 1
        let newSet = ExerciseSet(setNumber: newSetNumber)
        workout.exercises[exerciseIndex].sets.append(newSet)
    }
    
    private func removeSet(from exerciseIndex: Int) {
        let exercise = workout.exercises[exerciseIndex]
        if !exercise.sets.isEmpty {
            let newExercise = exercise
            newExercise.sets.removeLast()
            workout.exercises[exerciseIndex] = newExercise
        }
    }
    
    private func finishWorkout() {
        workout.duration = elapsedTime
        workout.isCompleted = true
        saveWorkout()
        onWorkoutCompleted()
        dismiss()
    }
    
    private func cancelWorkout() {
        modelContext.delete(workout)
        onWorkoutCompleted()
        dismiss()
    }
    
    private func saveWorkout() {
        workout.duration = elapsedTime
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func saveAsTemplate() {
        let savedExercises = workout.exercises.map { ex in
            SavedWorkoutExercise(
                exercise: ex.exercise,
                category: ex.category,
                difficulty: ex.difficulty,
                isCardio: ex.isCardio,
                defaultSets: ex.sets.count,
                defaultReps: ex.sets.first?.reps ?? 0,
                defaultWeight: ex.sets.first?.weight ?? 0,
                defaultDuration: ex.cardioTime,
                defaultDistance: ex.cardioDistance
            )
        }
        let savedWorkout = SavedWorkout(name: templateName, exercises: savedExercises)
        modelContext.insert(savedWorkout)
        do {
            try modelContext.save()
            showTemplateSavedAlert = true
        } catch {
            print("Error saving template: \(error)")
        }
    }
}

// MARK: - Exercise Workout Row
struct ExerciseWorkoutRow: View {
    let exercise: WorkoutExercise
    let exerciseIndex: Int
    let onAddSet: () -> Void
    let onRemoveSet: () -> Void
    let onRemoveExercise: () -> Void
    let onEditSet: (Int) -> Void
    let onEditSetWithIndex: (Int, Int) -> Void
    @Binding var cardioTime: TimeInterval
    @Binding var cardioDistance: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                
                Button(action: onRemoveExercise) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            if exercise.isCardio {
                // Cardio exercise view
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cardio Exercise")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Time (min)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Time", value: $cardioTime, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.subheadline)
                                .frame(width: 60)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Distance (m)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Distance", value: $cardioDistance, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.subheadline)
                                .frame(width: 80)
                        }
                    }
                }
            } else {
                // Strength exercise view
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Sets (\(exercise.sets.count))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Stepper(value: Binding(
                            get: { exercise.sets.count },
                            set: { newValue in
                                let diff = newValue - exercise.sets.count
                                if diff > 0 {
                                    for _ in 0..<diff { onAddSet() }
                                } else if diff < 0 {
                                    for _ in 0..<(-diff) { onRemoveSet() }
                                }
                            }
                        ), in: 0...20) {
                            EmptyView()
                        }
                        .labelsHidden()
                    }
                    
                    if !exercise.sets.isEmpty {
                        let sortedSets = exercise.sets.enumerated().sorted { $0.element.setNumber > $1.element.setNumber }
                        ForEach(sortedSets, id: \.offset) { index, set in
                            Button(action: {
                                onEditSetWithIndex(exerciseIndex, set.setNumber - 1)
                            }) {
                                HStack {
                                    Text("Set \(set.setNumber)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(set.reps) reps")
                                        .font(.caption)
                                    Text("\(String(format: "%.1f", set.weight)) kg")
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
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

// MARK: - Add Exercise to Workout View
struct AddExerciseToWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var selectedDifficulty: String?
    
    let onExerciseSelected: (Exercise) -> Void
    
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
                        Button(action: {
                            onExerciseSelected(exercise)
                            dismiss()
                        }) {
                            ExerciseRow(exercise: exercise, isSelected: false) {}
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Edit Exercise Sets View
struct EditExerciseSetsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var exercise: WorkoutExercise
    let onExerciseUpdated: (WorkoutExercise) -> Void
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    Text(exercise.exercise)
                        .font(.headline)
                    Text(exercise.category)
                        .foregroundColor(.secondary)
                }
                if exercise.isCardio {
                    Section(header: Text("Cardio Defaults")) {
                        HStack {
                            Text("Default Duration (min)")
                            Spacer()
                            TextField("Duration", value: $exercise.cardioTime, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Default Distance (m)")
                            Spacer()
                            TextField("Distance", value: $exercise.cardioDistance, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                } else {
                    Section(header: Text("Strength Defaults")) {
                        Stepper(value: Binding(get: { exercise.sets.count }, set: { newValue in
                            let diff = newValue - exercise.sets.count
                            if diff > 0 {
                                for _ in 0..<diff { exercise.sets.append(ExerciseSet(setNumber: exercise.sets.count + 1)) }
                            } else if diff < 0 {
                                for _ in 0..<(-diff) { if !exercise.sets.isEmpty { exercise.sets.removeLast() } }
                            }
                        }), in: 1...10) {
                            Text("Sets: \(exercise.sets.count)")
                        }
                        if !exercise.sets.isEmpty {
                            Stepper(value: $exercise.sets[0].reps, in: 1...50) {
                                Text("Reps: \(exercise.sets[0].reps)")
                            }
                            HStack {
                                Text("Weight (kg)")
                                Spacer()
                                TextField("Weight", value: $exercise.sets[0].weight, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onExerciseUpdated(exercise)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ActiveWorkoutView(
        workout: WorkoutLog(),
        onWorkoutCompleted: {}
    )
    .modelContainer(for: WorkoutLog.self, inMemory: true)
} 