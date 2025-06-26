//
//  BodyMeasurementsView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI
import SwiftData

struct BodyMeasurementsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let measurements: BodyMeasurements?
    
    @State private var height = ""
    @State private var weight = ""
    @State private var armCircumference = ""
    @State private var legCircumference = ""
    @State private var bellyCircumference = ""
    @State private var bodyFatPercentage = ""
    @State private var muscleMass = ""
    @State private var measurementDate = Date()
    @State private var useMetric = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units")) {
                    Picker("Units", selection: $useMetric) {
                        Text("Metric (cm, kg)").tag(true)
                        Text("Imperial (in, lb)").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Measurement Date")) {
                    DatePicker("Date", selection: $measurementDate, displayedComponents: .date)
                }
                
                Section(header: Text("Basic Measurements")) {
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
                
                Section(header: Text("Circumference Measurements")) {
                    HStack {
                        TextField(useMetric ? "Arm Circumference (cm)" : "Arm Circumference (in)", text: Binding(
                            get: {
                                if useMetric {
                                    return armCircumference
                                } else if let cm = Double(armCircumference) {
                                    return String(format: "%.1f", cm / 2.54)
                                } else {
                                    return ""
                                }
                            },
                            set: { newValue in
                                if useMetric {
                                    armCircumference = newValue
                                } else if let inches = Double(newValue) {
                                    armCircumference = String(format: "%.1f", inches * 2.54)
                                } else {
                                    armCircumference = ""
                                }
                            }
                        ))
                        .keyboardType(.decimalPad)
                        Text(useMetric ? "cm" : "in")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField(useMetric ? "Leg Circumference (cm)" : "Leg Circumference (in)", text: Binding(
                            get: {
                                if useMetric {
                                    return legCircumference
                                } else if let cm = Double(legCircumference) {
                                    return String(format: "%.1f", cm / 2.54)
                                } else {
                                    return ""
                                }
                            },
                            set: { newValue in
                                if useMetric {
                                    legCircumference = newValue
                                } else if let inches = Double(newValue) {
                                    legCircumference = String(format: "%.1f", inches * 2.54)
                                } else {
                                    legCircumference = ""
                                }
                            }
                        ))
                        .keyboardType(.decimalPad)
                        Text(useMetric ? "cm" : "in")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField(useMetric ? "Belly Circumference (cm)" : "Belly Circumference (in)", text: Binding(
                            get: {
                                if useMetric {
                                    return bellyCircumference
                                } else if let cm = Double(bellyCircumference) {
                                    return String(format: "%.1f", cm / 2.54)
                                } else {
                                    return ""
                                }
                            },
                            set: { newValue in
                                if useMetric {
                                    bellyCircumference = newValue
                                } else if let inches = Double(newValue) {
                                    bellyCircumference = String(format: "%.1f", inches * 2.54)
                                } else {
                                    bellyCircumference = ""
                                }
                            }
                        ))
                        .keyboardType(.decimalPad)
                        Text(useMetric ? "cm" : "in")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Body Composition")) {
                    HStack {
                        TextField("Body Fat Percentage", text: $bodyFatPercentage)
                            .keyboardType(.decimalPad)
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField(useMetric ? "Muscle Mass (kg)" : "Muscle Mass (lb)", text: Binding(
                            get: {
                                if useMetric {
                                    return muscleMass
                                } else if let kg = Double(muscleMass) {
                                    return String(format: "%.1f", kg * 2.20462)
                                } else {
                                    return ""
                                }
                            },
                            set: { newValue in
                                if useMetric {
                                    muscleMass = newValue
                                } else if let lbs = Double(newValue) {
                                    muscleMass = String(format: "%.1f", lbs / 2.20462)
                                } else {
                                    muscleMass = ""
                                }
                            }
                        ))
                        .keyboardType(.decimalPad)
                        Text(useMetric ? "kg" : "lb")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Body Measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMeasurements()
                    }
                }
            }
            .onAppear {
                loadMeasurements()
            }
        }
    }
    
    private func loadMeasurements() {
        if let measurements = measurements {
            height = measurements.height > 0 ? String(format: "%.1f", measurements.height) : ""
            weight = measurements.weight > 0 ? String(format: "%.1f", measurements.weight) : ""
            armCircumference = measurements.armCircumference > 0 ? String(format: "%.1f", measurements.armCircumference) : ""
            legCircumference = measurements.legCircumference > 0 ? String(format: "%.1f", measurements.legCircumference) : ""
            bellyCircumference = measurements.bellyCircumference > 0 ? String(format: "%.1f", measurements.bellyCircumference) : ""
            bodyFatPercentage = measurements.bodyFatPercentage > 0 ? String(format: "%.1f", measurements.bodyFatPercentage) : ""
            muscleMass = measurements.muscleMass > 0 ? String(format: "%.1f", measurements.muscleMass) : ""
            measurementDate = measurements.date
        }
    }
    
    private func saveMeasurements() {
        let newMeasurements = BodyMeasurements(
            date: measurementDate,
            height: Double(height) ?? 0,
            weight: Double(weight) ?? 0,
            armCircumference: Double(armCircumference) ?? 0,
            legCircumference: Double(legCircumference) ?? 0,
            bellyCircumference: Double(bellyCircumference) ?? 0,
            bodyFatPercentage: Double(bodyFatPercentage) ?? 0,
            muscleMass: Double(muscleMass) ?? 0
        )
        
        modelContext.insert(newMeasurements)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving body measurements: \(error)")
        }
    }
}

#Preview {
    BodyMeasurementsView(measurements: nil)
        .modelContainer(for: BodyMeasurements.self, inMemory: true)
} 