//
//  DataManager.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import Foundation

class DataManager: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var exercises: [Exercise] = []
    @Published var isLoading = false
    
    static let shared = DataManager()
    
    private init() {
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        // Load food items
        if let url = Bundle.main.url(forResource: "fooditems", withExtension: "json") {
            print("Found fooditems.json at \(url)")
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                foodItems = try decoder.decode([FoodItem].self, from: data)
                print("Loaded \(foodItems.count) food items")
            } catch {
                print("Error loading food items: \(error)")
            }
        } else {
            print("fooditems.json not found in bundle")
        }
        
        // Load exercises
        if let url = Bundle.main.url(forResource: "allexercises", withExtension: "json") {
            print("Found allexercises.json at \(url)")
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                exercises = try decoder.decode([Exercise].self, from: data)
                print("Loaded \(exercises.count) exercises")
            } catch {
                print("Error loading exercises: \(error)")
            }
        } else {
            print("allexercises.json not found in bundle")
        }
        
        isLoading = false
    }
    
    // MARK: - Food Items Filtering
    func filteredFoodItems(searchText: String, selectedCategory: String?) -> [FoodItem] {
        var filtered = foodItems
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.foodItem.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let category = selectedCategory, !category.isEmpty {
            filtered = filtered.filter { $0.category == category }
        }
        
        return filtered
    }
    
    func foodCategories() -> [String] {
        let categories = Set(foodItems.map { $0.category })
        return Array(categories).sorted()
    }
    
    // MARK: - Exercises Filtering
    func filteredExercises(searchText: String, selectedCategory: String?, selectedDifficulty: String?) -> [Exercise] {
        var filtered = exercises
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.exercise.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let category = selectedCategory, !category.isEmpty {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let difficulty = selectedDifficulty, !difficulty.isEmpty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        return filtered
    }
    
    func exerciseCategories() -> [String] {
        let categories = Set(exercises.map { $0.category })
        return Array(categories).sorted()
    }
    
    func exerciseDifficulties() -> [String] {
        let difficulties = Set(exercises.map { $0.difficulty })
        return Array(difficulties).sorted()
    }
    
    // MARK: - Cardio Exercise Detection
    func isCardioExercise(_ exercise: Exercise) -> Bool {
        let cardioKeywords = ["running", "cycling", "walking", "swimming", "rowing", "elliptical", "treadmill", "bike", "jogging", "sprint"]
        return cardioKeywords.contains { keyword in
            exercise.exercise.localizedCaseInsensitiveContains(keyword)
        }
    }
} 