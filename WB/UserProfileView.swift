//
//  UserProfileView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI
import SwiftData

struct UserProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let userProfile: UserProfile?
    
    @State private var name = ""
    @State private var age = ""
    @State private var sex = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var personalGoal = ""
    @State private var useMetric = true
    
    let sexOptions = ["Male", "Female", "Other", "Prefer not to say"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    Picker("Sex", selection: $sex) {
                        Text("Select").tag("")
                        ForEach(sexOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("Physical Information")) {
                    Picker("Units", selection: $useMetric) {
                        Text("Metric (cm, kg)").tag(true)
                        Text("Imperial (in, lb)").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 4)
                    
                    HStack {
                        TextField(useMetric ? "Height (cm)" : "Height (in)", text: Binding(
                            get: {
                                if useMetric {
                                    return height
                                } else if let cm = Double(height) {
                                    return String(format: "%.1f", cm / 2.54)
                                } else {
                                    return ""
                                }
                            },
                            set: { newValue in
                                if useMetric {
                                    height = newValue
                                } else if let inches = Double(newValue) {
                                    height = String(format: "%.1f", inches * 2.54)
                                } else {
                                    height = ""
                                }
                            }
                        ))
                        .keyboardType(.decimalPad)
                        Text(useMetric ? "cm" : "in")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField(useMetric ? "Weight (kg)" : "Weight (lb)", text: Binding(
                            get: {
                                if useMetric {
                                    return weight
                                } else if let kg = Double(weight) {
                                    return String(format: "%.1f", kg * 2.20462)
                                } else {
                                    return ""
                                }
                            },
                            set: { newValue in
                                if useMetric {
                                    weight = newValue
                                } else if let lbs = Double(newValue) {
                                    weight = String(format: "%.1f", lbs / 2.20462)
                                } else {
                                    weight = ""
                                }
                            }
                        ))
                        .keyboardType(.decimalPad)
                        Text(useMetric ? "kg" : "lb")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Goals")) {
                    TextField("Personal Goal", text: $personalGoal, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("User Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
            .onAppear {
                loadProfile()
            }
        }
    }
    
    private func loadProfile() {
        if let profile = userProfile {
            name = profile.name
            age = profile.age > 0 ? String(profile.age) : ""
            sex = profile.sex
            height = profile.height > 0 ? String(format: "%.1f", profile.height) : ""
            weight = profile.weight > 0 ? String(format: "%.1f", profile.weight) : ""
            personalGoal = profile.personalGoal
        }
    }
    
    private func saveProfile() {
        if let existingProfile = userProfile {
            // Update existing profile
            existingProfile.name = name
            existingProfile.age = Int(age) ?? 0
            existingProfile.sex = sex
            existingProfile.height = Double(height) ?? 0
            existingProfile.weight = Double(weight) ?? 0
            existingProfile.personalGoal = personalGoal
            existingProfile.updatedAt = Date()
        } else {
            // Create new profile
            let newProfile = UserProfile(
                name: name,
                age: Int(age) ?? 0,
                sex: sex,
                height: Double(height) ?? 0,
                weight: Double(weight) ?? 0,
                personalGoal: personalGoal
            )
            modelContext.insert(newProfile)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving user profile: \(error)")
        }
    }
}

#Preview {
    UserProfileView(userProfile: nil)
        .modelContainer(for: UserProfile.self, inMemory: true)
} 