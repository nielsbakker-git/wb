//
//  NutritionView.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import SwiftUI
import SwiftData

struct NutritionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealLogs: [MealLog]
    @Query private var waterLogs: [WaterLog]
    @State private var showingMealLog = false
    @State private var showingWaterLog = false
    @State private var selectedMeal: MealLog?
    @State private var selectedWater: WaterLog?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Add this heading below the navigation title
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Today's Calories",
                                value: "\(todayCalories)",
                                unit: "kcal",
                                color: .orange,
                                icon: "flame.fill"
                            )
                            
                            StatCard(
                                title: "Today's Water",
                                value: "\(todayWater)",
                                unit: "ml",
                                color: .blue,
                                icon: "drop.fill"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: { showingMealLog = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Log Meal")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showingWaterLog = true }) {
                            HStack {
                                Image(systemName: "drop.fill")
                                Text("Log Water")
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
                    
                    // Today's Logs
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Logs")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if todayMealLogs.isEmpty && todayWaterLogs.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "fork.knife.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No logs for today")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("Start by logging your first meal or water intake")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            // Meal Logs
                            ForEach(todayMealLogs) { meal in
                                Button(action: { selectedMeal = meal }) {
                                    MealLogRow(meal: meal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Water Logs
                            ForEach(todayWaterLogs) { water in
                                Button(action: { selectedWater = water }) {
                                    WaterLogRow(water: water)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Nutrition")
            .sheet(isPresented: $showingMealLog) {
                MealLogView()
            }
            .sheet(isPresented: $showingWaterLog) {
                WaterLogView()
            }
            .sheet(item: $selectedMeal) { meal in
                MealLogDetailView(meal: meal)
            }
            .sheet(item: $selectedWater) { water in
                WaterLogView(waterLog: water)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var todayMealLogs: [MealLog] {
        let today = Calendar.current.startOfDay(for: Date())
        return mealLogs.filter { Calendar.current.isDate($0.date, inSameDayAs: today) && !$0.foodItems.isEmpty }
    }
    
    private var todayWaterLogs: [WaterLog] {
        let today = Calendar.current.startOfDay(for: Date())
        return waterLogs.filter { Calendar.current.isDate($0.date, inSameDayAs: today) && $0.amount > 0 }
    }
    
    private var todayCalories: Int {
        todayMealLogs.reduce(0) { $0 + Int($1.totalCalories) }
    }
    
    private var todayWater: Int {
        todayWaterLogs.reduce(0) { $0 + Int($1.amount) }
    }
}

// MARK: - Supporting Views
struct MealLogRow: View {
    let meal: MealLog
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.mealType.capitalized)
                    .font(.headline)
                Text("\(Int(meal.totalCalories)) kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(meal.foodItems.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(meal.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct WaterLogRow: View {
    let water: WaterLog
    
    var body: some View {
        HStack {
            Image(systemName: "drop.fill")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Water")
                    .font(.headline)
                Text("\(Int(water.amount)) \(water.unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(water.date, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - Meal Log Detail View
struct MealLogDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var meal: MealLog
    @State private var editingFoodItem: MealFoodItem?
    @State private var showingAddFood = false
    @State private var searchText = ""
    @State private var selectedFood: FoodItem?
    @State private var newQuantity: Double = 1.0
    @State private var showingDeleteAlert = false
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Meal Type")) {
                        TextField("Type", text: $meal.mealType)
                    }
                    Section(header: Text("Food Items")) {
                        if meal.foodItems.isEmpty {
                            Text("No food items")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(Array(meal.foodItems.enumerated()), id: \.offset) { idx, item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.foodItem)
                                            .font(.headline)
                                        Text("Qty: \(String(format: "%.1f", item.quantity)) \(item.measure)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button(action: {
                                        editingFoodItem = item
                                    }) {
                                        Image(systemName: "pencil")
                                    }
                                }
                            }
                            .onDelete { indices in
                                for index in indices {
                                    meal.foodItems.remove(at: index)
                                }
                            }
                        }
                        Button("Add Food Item") { showingAddFood = true }
                    }
                    Section(header: Text("Totals")) {
                        Text("Calories: \(Int(meal.foodItems.reduce(0) { $0 + $1.calories })) kcal")
                        Text("Protein: \(String(format: "%.1f", meal.foodItems.reduce(0) { $0 + $1.protein })) g")
                        Text("Carbs: \(String(format: "%.1f", meal.foodItems.reduce(0) { $0 + $1.carbs })) g")
                        Text("Fat: \(String(format: "%.1f", meal.foodItems.reduce(0) { $0 + $1.fat })) g")
                    }
                }
                Spacer()
                Button(action: { showingDeleteAlert = true }) {
                    Text("Delete Log")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                        .padding([.horizontal, .bottom])
                }
            }
            .navigationTitle(meal.mealType.capitalized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMeal()
                        dismiss()
                    }
                }
            }
            .alert("Delete Meal Log?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(meal)
                    do { try modelContext.save() } catch {}
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
            .sheet(item: $editingFoodItem) { item in
                EditMealFoodItemView(item: item) { updated in
                    if let idx = meal.foodItems.firstIndex(where: { $0.foodItem == updated.foodItem }) {
                        meal.foodItems[idx] = updated
                    }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodToMealView(onAdd: { foodItem, quantity in
                    let calories = (Double(foodItem.calories) ?? 0) * quantity
                    let protein = (Double(foodItem.protein) ?? 0) * quantity
                    let carbs = (Double(foodItem.carb) ?? 0) * quantity
                    let fat = (Double(foodItem.fat) ?? 0) * quantity
                    let fiber = (Double(foodItem.fiber) ?? 0) * quantity
                    let newItem = MealFoodItem(
                        foodItem: foodItem.foodItem,
                        measure: foodItem.measure,
                        quantity: quantity,
                        calories: calories,
                        protein: protein,
                        carbs: carbs,
                        fat: fat,
                        fiber: fiber
                    )
                    meal.foodItems.append(newItem)
                })
            }
        }
    }
    private func saveMeal() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving meal: \(error)")
        }
    }
}

struct EditMealFoodItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State var item: MealFoodItem
    let onSave: (MealFoodItem) -> Void
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Item")) {
                    Text(item.foodItem)
                    Text(item.measure)
                }
                Section(header: Text("Quantity")) {
                    Stepper(value: $item.quantity, in: 0.1...10.0, step: 0.1) {
                        Text("Qty: \(String(format: "%.1f", item.quantity))")
                    }
                }
            }
            .navigationTitle("Edit Food Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(item)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddFoodToMealView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedFood: FoodItem?
    @State private var quantity: Double = 1.0
    let onAdd: (FoodItem, Double) -> Void
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search food items...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                List(DataManager.shared.filteredFoodItems(searchText: searchText, selectedCategory: nil)) { foodItem in
                    Button(action: {
                        selectedFood = foodItem
                        quantity = 1.0
                    }) {
                        HStack {
                            Text(foodItem.foodItem)
                            Spacer()
                            if selectedFood?.foodItem == foodItem.foodItem {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                if let food = selectedFood {
                    Form {
                        Section(header: Text("Quantity")) {
                            Stepper(value: $quantity, in: 0.1...10.0, step: 0.1) {
                                Text("Qty: \(String(format: "%.1f", quantity))")
                            }
                        }
                        Section {
                            Button(action: {
                                onAdd(food, quantity)
                                dismiss()
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Add to Meal")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Food Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NutritionView()
        .modelContainer(for: [MealLog.self, WaterLog.self], inMemory: true)
} 