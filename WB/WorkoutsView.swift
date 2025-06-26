//
//  WorkoutsView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI
import SwiftData

struct WorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedWorkouts: [SavedWorkout]
    @Query private var workoutLogs: [WorkoutLog]
    
    @State private var showingLogWorkout = false
    @State private var showingSavedWorkouts = false
    @State private var showingActiveWorkout = false
    @State private var activeWorkout: WorkoutLog?
    @State private var editingWorkout: WorkoutLog?
    @State private var showingRecentWorkoutDetail = false
    @State private var selectedRecentWorkout: WorkoutLog?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Statistics at the top
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This Week")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Calories Burnt",
                                value: "\(thisWeekCalories)",
                                unit: "kcal",
                                color: .orange,
                                icon: "flame.fill"
                            )
                            StatCard(
                                title: "Workouts Logged",
                                value: "\(thisWeekWorkouts.count)",
                                unit: "",
                                color: .green,
                                icon: "dumbbell.fill"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Active Workout Section
                    if let activeWorkout = activeWorkout {
                        ActiveWorkoutCard(
                            workout: activeWorkout,
                            onContinue: { showingActiveWorkout = true }
                        )
                    }
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: { showingLogWorkout = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Log Workout")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showingSavedWorkouts = true }) {
                            HStack {
                                Image(systemName: "bookmark.fill")
                                Text("Saved Workouts")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Workouts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Workouts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if recentWorkouts.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "dumbbell")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No recent workouts")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("Start by logging your first workout")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(recentWorkouts.prefix(5)) { workout in
                                    Button(action: { selectedRecentWorkout = workout }) {
                                        RecentWorkoutRow(workout: workout)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Workouts")
            .sheet(isPresented: $showingLogWorkout) {
                LogWorkoutView { workout in
                    activeWorkout = workout
                    showingActiveWorkout = true
                }
            }
            .sheet(isPresented: $showingSavedWorkouts) {
                SavedWorkoutsView()
            }
            .sheet(isPresented: $showingActiveWorkout) {
                if let workout = activeWorkout {
                    ActiveWorkoutView(workout: workout) {
                        activeWorkout = nil
                    }
                }
            }
            .sheet(item: $selectedRecentWorkout) { workout in
                NavigationView {
                    RecentWorkoutDetailView(workout: workout, onStart: { log in
                        activeWorkout = log
                        showingActiveWorkout = true
                    }, onDelete: {
                        selectedRecentWorkout = nil
                    })
                }
            }
        }
    }
    
    private var recentWorkouts: [WorkoutLog] {
        workoutLogs.filter { $0.isCompleted }
            .sorted { $0.date > $1.date }
    }
    
    private var thisWeekWorkouts: [WorkoutLog] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return workoutLogs.filter { $0.date >= startOfWeek && $0.isCompleted }
    }
    
    private var thisWeekDuration: TimeInterval {
        thisWeekWorkouts.reduce(0) { $0 + $1.duration }
    }
    
    private var thisWeekCalories: Int {
        thisWeekWorkouts.reduce(0) { total, log in
            total + log.estimatedCaloriesBurnt
        }
    }
}

// MARK: - Active Workout Card
struct ActiveWorkoutCard: View {
    let workout: WorkoutLog
    let onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Workout")
                        .font(.headline)
                    Text("\(workout.exercises.count) exercises")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Continue") {
                    onContinue()
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Recent Workout Row
struct RecentWorkoutRow: View {
    let workout: WorkoutLog
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name.isEmpty ? "Workout" : workout.name)
                    .font(.headline)
                Text("\(workout.exercises.count) exercises")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatDuration(workout.duration))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Add this struct at the top-level (outside of any view)
struct ExerciseIndex: Identifiable {
    let id: Int
}

struct EditWorkoutLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var workout: WorkoutLog
    let onDelete: (Bool) -> Void
    @State private var showingAddExercise = false
    @State private var editingExerciseIndex: ExerciseIndex?
    @State private var showingDeleteAlert = false
    
    private var exercisesList: some View {
        List {
            ForEach(workout.exercises.indices, id: \ .self) { idx in
                HStack {
                    VStack(alignment: .leading) {
                        Text(workout.exercises[idx].exercise)
                            .font(.headline)
                        Text(workout.exercises[idx].category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: { editingExerciseIndex = ExerciseIndex(id: idx) }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .listRowBackground(Color.clear)
            }
            .onDelete { indices in
                for index in indices.sorted(by: >) {
                    workout.exercises.remove(at: index)
                }
            }
        }
        .listStyle(PlainListStyle())
        .frame(height: min(CGFloat(workout.exercises.count) * 72, 320))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("WORKOUT NAME")) {
                        TextField("Name", text: $workout.name)
                    }
                    Section(header: Text("EXERCISES")) {
                        if workout.exercises.isEmpty {
                            Text("No exercises")
                                .foregroundColor(.secondary)
                        } else {
                            exercisesList
                        }
                    }
                }
                .padding(.bottom, 0)
                // Add Exercise Button
                Button(action: { showingAddExercise = true }) {
                    Text("Add Exercise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                        .padding([.horizontal, .top])
                }
                Spacer(minLength: 0)
                // Delete Workout Button
                Button(action: { showingDeleteAlert = true }) {
                    Text("Delete Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(16)
                        .padding([.horizontal, .bottom])
                }
            }
            .navigationTitle("Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseToWorkoutView { exercise in
                    let newExercise = WorkoutExercise(
                        exercise: exercise.exercise,
                        category: exercise.category,
                        difficulty: exercise.difficulty,
                        isCardio: DataManager.shared.isCardioExercise(exercise)
                    )
                    workout.exercises.append(newExercise)
                }
            }
            .sheet(item: $editingExerciseIndex) { exerciseIndex in
                EditExerciseSetsView(exercise: workout.exercises[exerciseIndex.id]) { updated in
                    workout.exercises[exerciseIndex.id] = updated
                }
            }
            .alert("Delete Workout?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(workout)
                    do { try modelContext.save() } catch {}
                    onDelete(true)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
        }
    }
    private func saveWorkout() {
        do { try modelContext.save() } catch {}
    }
}

struct RecentWorkoutDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var workout: WorkoutLog
    @FocusState private var nameFieldFocused: Bool
    @State private var showingEditExercises = false
    @State private var editingExerciseIndex: Int?
    @State private var showDeleteAlert = false
    let onStart: (WorkoutLog) -> Void
    let onDelete: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Workout Name")) {
                    TextField("Name", text: $workout.name)
                        .focused($nameFieldFocused)
                        .onSubmit { save() }
                }
                Section(header: Text("Exercises")) {
                    if workout.exercises.isEmpty {
                        Text("No exercises")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(Array(workout.exercises.enumerated()), id: \ .offset) { idx, ex in
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(ex.exercise)
                                            .font(.headline)
                                        Text(ex.category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button(action: { editingExerciseIndex = idx }) {
                                        Image(systemName: "pencil")
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { editingExerciseIndex = idx }
                        }
                        .onDelete { indices in
                            for index in indices.sorted(by: >) {
                                workout.exercises.remove(at: index)
                            }
                            save()
                        }
                    }
                    Button("Edit Exercises") { showingEditExercises = true }
                }
                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Workout", systemImage: "trash")
                    }
                }
            }
            Spacer(minLength: 0)
            Button(action: {
                onStart(workout)
                dismiss()
            }) {
                Text(workout.isCompleted ? "Resume Workout" : "Start Workout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(16)
                    .padding([.horizontal, .bottom])
            }
        }
        .navigationTitle(workout.name.isEmpty ? "Recent Workout" : workout.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") { dismiss() }
            }
        }
        .onDisappear { save() }
        .sheet(isPresented: $showingEditExercises) {
            AddExerciseToWorkoutView { exercise in
                let newExercise = WorkoutExercise(
                    exercise: exercise.exercise,
                    category: exercise.category,
                    difficulty: exercise.difficulty,
                    isCardio: DataManager.shared.isCardioExercise(exercise)
                )
                workout.exercises.append(newExercise)
                save()
            }
        }
        .sheet(item: Binding(get: {
            editingExerciseIndex.map { idx in workout.exercises[idx] }
        }, set: { _ in }), content: { ex in
            EditExerciseSetsView(exercise: ex) { updated in
                if let idx = editingExerciseIndex {
                    workout.exercises[idx] = updated
                    save()
                }
            }
        })
        .alert("Delete Workout?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(workout)
                do { try modelContext.save() } catch { print("Error deleting workout: \(error)") }
                onDelete()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this workout? This cannot be undone.")
        }
    }
    private func save() {
        do { try modelContext.save() } catch { print("Error saving workout: \(error)") }
    }
}

#Preview {
    WorkoutsView()
        .modelContainer(for: [SavedWorkout.self, WorkoutLog.self], inMemory: true)
}

extension WorkoutLog {
    var estimatedCaloriesBurnt: Int {
        exercises.reduce(0) { sum, ex in
            if ex.isCardio {
                // Estimate: 8 kcal per min of cardio
                let mins = (ex.cardioTime ?? 0) / 60
                return sum + Int(mins * 8)
            } else {
                // Estimate: 0.1 kcal per rep * weight
                let setCals = ex.sets.reduce(0) { $0 + Int(Double($1.reps) * $1.weight * 0.1) }
                return sum + setCals
            }
        }
    }
} 