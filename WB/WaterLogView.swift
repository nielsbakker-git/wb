//
//  WaterLogView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI
import SwiftData

struct WaterLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var waterLog: WaterLog?
    @State private var amount: Double = 250
    @State private var unit = "ml"
    @State private var customAmount = ""
    
    let units = ["ml", "oz"]
    let commonAmounts = [100, 200, 250, 300, 500, 750, 1000]
    
    init(waterLog: WaterLog? = nil) {
        self.waterLog = waterLog
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Unit Selector
                Picker("Unit", selection: $unit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit.uppercased()).tag(unit)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Amount Display
                VStack(spacing: 16) {
                    Text("\(Int(amount)) \(unit)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    // Amount Slider
                    VStack(spacing: 8) {
                        Slider(value: $amount, in: 50...2000, step: 50)
                            .accentColor(.blue)
                        
                        HStack {
                            Text("50 \(unit)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("2000 \(unit)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Common Amounts
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Add")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(commonAmounts, id: \.self) { commonAmount in
                            Button(action: {
                                amount = Double(commonAmount)
                            }) {
                                Text("\(commonAmount) \(unit)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(amount == Double(commonAmount) ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(amount == Double(commonAmount) ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Custom Amount
                VStack(alignment: .leading, spacing: 12) {
                    Text("Custom Amount")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        TextField("Enter amount", text: $customAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        Text(unit)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("Set") {
                            if let customValue = Double(customAmount) {
                                amount = customValue
                                customAmount = ""
                            }
                        }
                        .disabled(customAmount.isEmpty)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Save Button
                Button(action: saveWaterLog) {
                    Text(waterLog == nil ? "Log Water" : "Save Changes")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
                if waterLog != nil {
                    Button(action: deleteWaterLog) {
                        Text("Delete Water Log")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle(waterLog == nil ? "Log Water" : "Edit Water Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let log = waterLog {
                amount = log.amount
                unit = log.unit
            }
        }
    }
    
    private func saveWaterLog() {
        if let log = waterLog {
            log.amount = amount
            log.unit = unit
            log.date = Date()
        } else {
            let newLog = WaterLog(
                date: Date(),
                amount: amount,
                unit: unit
            )
            modelContext.insert(newLog)
        }
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving water log: \(error)")
        }
    }
    
    private func deleteWaterLog() {
        if let log = waterLog {
            modelContext.delete(log)
            do {
                try modelContext.save()
                dismiss()
            } catch {
                print("Error deleting water log: \(error)")
            }
        }
    }
}

#Preview {
    WaterLogView()
        .modelContainer(for: WaterLog.self, inMemory: true)
} 