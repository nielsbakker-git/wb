//
//  MealLogView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI
import SwiftData

struct MealLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var dataManager = DataManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var selectedMealType = "breakfast"
    @State private var selectedFoodItems: [FoodItem] = []
    @State private var foodQuantities: [String: Double] = [:]
    
    let mealTypes = ["breakfast", "lunch", "dinner", "snack"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Meal Type Selector
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(mealTypes, id: \.self) { type in
                        Text(type.capitalized).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Search and Filter
                VStack(spacing: 12) {
                    TextField("Search food items...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(dataManager.foodCategories(), id: \.self) { category in
                                FilterChip(title: category, isSelected: selectedCategory == category) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Food Items List
                List {
                    ForEach(dataManager.filteredFoodItems(searchText: searchText, selectedCategory: selectedCategory)) { foodItem in
                        FoodItemRow(
                            foodItem: foodItem,
                            isSelected: selectedFoodItems.contains { $0.foodItem == foodItem.foodItem },
                            quantity: foodQuantities[foodItem.foodItem] ?? 1.0
                        ) {
                            if selectedFoodItems.contains(where: { $0.foodItem == foodItem.foodItem }) {
                                selectedFoodItems.removeAll { $0.foodItem == foodItem.foodItem }
                                foodQuantities.removeValue(forKey: foodItem.foodItem)
                            } else {
                                selectedFoodItems.append(foodItem)
                                foodQuantities[foodItem.foodItem] = 1.0
                            }
                        } quantityChanged: { newQuantity in
                            foodQuantities[foodItem.foodItem] = newQuantity
                        }
                    }
                }
                
                // Selected Items Summary
                if !selectedFoodItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Items (\(selectedFoodItems.count))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(selectedFoodItems, id: \.foodItem) { foodItem in
                                    SelectedFoodItemRow(
                                        foodItem: foodItem,
                                        quantity: foodQuantities[foodItem.foodItem] ?? 1.0
                                    ) {
                                        selectedFoodItems.removeAll { $0.foodItem == foodItem.foodItem }
                                        foodQuantities.removeValue(forKey: foodItem.foodItem)
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
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMeal()
                    }
                    .disabled(selectedFoodItems.isEmpty)
                }
            }
        }
    }
    
    private func saveMeal() {
        let mealFoodItems = selectedFoodItems.map { foodItem in
            let quantity = foodQuantities[foodItem.foodItem] ?? 1.0
            let calories = (Double(foodItem.calories) ?? 0) * quantity
            let protein = (Double(foodItem.protein) ?? 0) * quantity
            let carbs = (Double(foodItem.carb) ?? 0) * quantity
            let fat = (Double(foodItem.fat) ?? 0) * quantity
            let fiber = (Double(foodItem.fiber) ?? 0) * quantity
            
            return MealFoodItem(
                foodItem: foodItem.foodItem,
                measure: foodItem.measure,
                quantity: quantity,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber
            )
        }
        
        let meal = MealLog(
            date: Date(),
            mealType: selectedMealType,
            foodItems: mealFoodItems
        )
        
        modelContext.insert(meal)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving meal: \(error)")
        }
    }
}

struct FoodItemRow: View {
    let foodItem: FoodItem
    let isSelected: Bool
    let quantity: Double
    let onToggle: () -> Void
    let quantityChanged: (Double) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(foodItem.foodItem)
                    .font(.headline)
                
                Text(foodItem.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let calories = Double(foodItem.calories), calories > 0 {
                    Text("\(Int(calories)) kcal per \(foodItem.measure)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isSelected {
                VStack(spacing: 8) {
                    Stepper(value: Binding(
                        get: { quantity },
                        set: { quantityChanged($0) }
                    ), in: 0.1...10.0, step: 0.1) {
                        Text("Qty: \(quantity, specifier: "%.1f")")
                            .font(.caption)
                    }
                    
                    Button("Remove") {
                        onToggle()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            } else {
                Button("Add") {
                    onToggle()
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SelectedFoodItemRow: View {
    let foodItem: FoodItem
    let quantity: Double
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(foodItem.foodItem)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(quantity, specifier: "%.1f") x \(foodItem.measure)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let calories = Double(foodItem.calories) {
                Text("\(Int(calories * quantity)) kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MealLogView()
        .modelContainer(for: MealLog.self, inMemory: true)
} 