//
//  SavedWorkoutsView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI
import SwiftData

struct SavedWorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\SavedWorkout.createdAt, order: .reverse)]) var savedWorkouts: [SavedWorkout]
    @State private var showingAddWorkout = false
    @State private var newWorkoutExercises: [Exercise] = []
    @State private var newWorkoutName: String = ""
    @State private var activeWorkout: WorkoutLog?
    @State private var showingActiveWorkout = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    if savedWorkouts.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No saved workouts")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Save a workout as a template or add a new one to see it here.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(savedWorkouts) { workout in
                            NavigationLink(destination: SavedWorkoutDetailView(workout: workout, onStart: { log in
                                activeWorkout = log
                                showingActiveWorkout = true
                            })) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.name.isEmpty ? "Saved Workout" : workout.name)
                                        .font(.headline)
                                    Text("\(workout.exercises.count) exercises")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteWorkouts)
                    }
                }
                .listStyle(PlainListStyle())
                Spacer(minLength: 0)
                Button(action: { showingAddWorkout = true }) {
                    Text("Add New Saved Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                        .padding([.horizontal, .bottom])
                }
            }
            .navigationTitle("Saved Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddSavedWorkoutView { name, exercises in
                    let savedExercises = exercises.map { ex in
                        SavedWorkoutExercise(
                            exercise: ex.exercise,
                            category: ex.category,
                            difficulty: ex.difficulty,
                            isCardio: DataManager.shared.isCardioExercise(ex),
                            defaultSets: 3,
                            defaultReps: 10,
                            defaultWeight: 0,
                            defaultDuration: nil,
                            defaultDistance: nil
                        )
                    }
                    let newWorkout = SavedWorkout(name: name, exercises: savedExercises)
                    modelContext.insert(newWorkout)
                    do { try modelContext.save() } catch { print("Error saving new workout: \(error)") }
                }
            }
            .sheet(isPresented: $showingActiveWorkout) {
                if let workout = activeWorkout {
                    ActiveWorkoutView(workout: workout) {
                        activeWorkout = nil
                        showingActiveWorkout = false
                    }
                }
            }
        }
    }
    
    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            let workout = savedWorkouts[index]
            modelContext.delete(workout)
        }
        do { try modelContext.save() } catch { print("Error deleting workout: \(error)") }
    }
}

struct SavedWorkoutDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var workout: SavedWorkout
    @FocusState private var nameFieldFocused: Bool
    @State private var showingEditExercises = false
    @State private var editingExercise: SavedWorkoutExercise?
    var onStart: ((WorkoutLog) -> Void)? = nil
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
                        ForEach(Array(workout.exercises.enumerated()), id: \.offset) { idx, ex in
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
                                    Button(action: { editingExercise = ex }) {
                                        Image(systemName: "pencil")
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { editingExercise = ex }
                        }
                        .onDelete { indices in
                            workout.exercises.remove(atOffsets: indices)
                            save()
                        }
                    }
                    Button("Edit Exercises") { showingEditExercises = true }
                }
                Section {
                    Button(role: .destructive) {
                        modelContext.delete(workout)
                        do { try modelContext.save() } catch { print("Error deleting workout: \(error)") }
                    } label: {
                        Label("Delete Workout", systemImage: "trash")
                    }
                }
            }
            Spacer(minLength: 0)
            Button(action: {
                // Convert SavedWorkout to WorkoutLog and start
                let workoutExercises = workout.exercises.map { ex in
                    let sets = (0..<ex.defaultSets).map { i in
                        ExerciseSet(setNumber: i + 1, reps: ex.defaultReps, weight: ex.defaultWeight)
                    }
                    return WorkoutExercise(
                        exercise: ex.exercise,
                        category: ex.category,
                        difficulty: ex.difficulty,
                        sets: sets,
                        isCardio: ex.isCardio,
                        cardioTime: ex.defaultDuration,
                        cardioDistance: ex.defaultDistance
                    )
                }
                let log = WorkoutLog(
                    date: Date(),
                    name: workout.name,
                    exercises: workoutExercises
                )
                modelContext.insert(log)
                do { try modelContext.save() } catch { print("Error starting workout: \(error)") }
                onStart?(log)
            }) {
                Text("Start Workout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(16)
                    .padding([.horizontal, .bottom])
            }
        }
        .navigationTitle(workout.name.isEmpty ? "Saved Workout" : workout.name)
        .onDisappear { save() }
        .sheet(isPresented: $showingEditExercises) {
            AddSavedWorkoutView(
                initialName: workout.name,
                initialExercises: workout.exercises.map { ex in
                    Exercise(
                        difficulty: ex.difficulty,
                        category: ex.category,
                        exercise: ex.exercise,
                        visualExample: ""
                    )
                },
                onSave: { name, exercises in
                    workout.name = name
                    workout.exercises = exercises.map { ex in
                        SavedWorkoutExercise(
                            exercise: ex.exercise,
                            category: ex.category,
                            difficulty: ex.difficulty,
                            isCardio: DataManager.shared.isCardioExercise(ex),
                            defaultSets: 3,
                            defaultReps: 10,
                            defaultWeight: 0,
                            defaultDuration: nil,
                            defaultDistance: nil
                        )
                    }
                    save()
                }
            )
        }
        .sheet(item: $editingExercise) { ex in
            EditSavedWorkoutExerciseView(exercise: ex) { updated in
                if let idx = workout.exercises.firstIndex(where: { $0.exercise == updated.exercise }) {
                    workout.exercises[idx] = updated
                    save()
                }
            }
        }
    }
    private func save() {
        do { try modelContext.save() } catch { print("Error saving workout: \(error)") }
    }
}

struct AddSavedWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedExercises: [Exercise]
    @State private var name: String
    let onSave: (String, [Exercise]) -> Void
    init(initialName: String = "", initialExercises: [Exercise] = [], onSave: @escaping (String, [Exercise]) -> Void) {
        _name = State(initialValue: initialName)
        _selectedExercises = State(initialValue: initialExercises)
        self.onSave = onSave
    }
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search exercises...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                List(DataManager.shared.filteredExercises(searchText: searchText, selectedCategory: nil, selectedDifficulty: nil)) { exercise in
                    HStack {
                        Text(exercise.exercise)
                        Spacer()
                        if selectedExercises.contains(where: { $0.exercise == exercise.exercise }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let idx = selectedExercises.firstIndex(where: { $0.exercise == exercise.exercise }) {
                            selectedExercises.remove(at: idx)
                        } else {
                            selectedExercises.append(exercise)
                        }
                    }
                }
                .frame(maxHeight: 300)
                Form {
                    Section(header: Text("Workout Name")) {
                        TextField("Name", text: $name)
                    }
                    Section {
                        Button("Save Workout") {
                            onSave(name, selectedExercises)
                            dismiss()
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || selectedExercises.isEmpty)
                    }
                }
            }
            .navigationTitle("Add Saved Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct EditSavedWorkoutExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State var exercise: SavedWorkoutExercise
    let onSave: (SavedWorkoutExercise) -> Void
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise")) {
                    Text(exercise.exercise)
                    Text(exercise.category)
                        .foregroundColor(.secondary)
                }
                if exercise.isCardio {
                    Section(header: Text("Cardio Defaults")) {
                        HStack {
                            Text("Default Duration (min)")
                            Spacer()
                            TextField("Duration", value: $exercise.defaultDuration, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Default Distance (m)")
                            Spacer()
                            TextField("Distance", value: $exercise.defaultDistance, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                } else {
                    Section(header: Text("Strength Defaults")) {
                        Stepper(value: $exercise.defaultSets, in: 1...10) {
                            Text("Sets: \(exercise.defaultSets)")
                        }
                        Stepper(value: $exercise.defaultReps, in: 1...50) {
                            Text("Reps: \(exercise.defaultReps)")
                        }
                        HStack {
                            Text("Weight (kg)")
                            Spacer()
                            TextField("Weight", value: $exercise.defaultWeight, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
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
                        onSave(exercise)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SavedWorkoutsView()
        .modelContainer(for: SavedWorkout.self, inMemory: true)
} 