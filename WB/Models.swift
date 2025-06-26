//
//  Models.swift
//  WB
//
//  Created by Niels Bakker on 25/06/2025.
//

import Foundation
import SwiftData

// MARK: - User Profile
@Model
final class UserProfile {
    var name: String
    var age: Int
    var sex: String
    var height: Double // in cm
    var weight: Double // in kg
    var personalGoal: String
    var profileImage: Data?
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String = "", age: Int = 0, sex: String = "", height: Double = 0, weight: Double = 0, personalGoal: String = "", profileImage: Data? = nil) {
        self.name = name
        self.age = age
        self.sex = sex
        self.height = height
        self.weight = weight
        self.personalGoal = personalGoal
        self.profileImage = profileImage
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Body Measurements
@Model
final class BodyMeasurements {
    var date: Date
    var height: Double // in cm
    var weight: Double // in kg
    var armCircumference: Double // in cm
    var legCircumference: Double // in cm
    var bellyCircumference: Double // in cm
    var bodyFatPercentage: Double
    var muscleMass: Double // in kg
    var createdAt: Date
    
    init(date: Date = Date(), height: Double = 0, weight: Double = 0, armCircumference: Double = 0, legCircumference: Double = 0, bellyCircumference: Double = 0, bodyFatPercentage: Double = 0, muscleMass: Double = 0) {
        self.date = date
        self.height = height
        self.weight = weight
        self.armCircumference = armCircumference
        self.legCircumference = legCircumference
        self.bellyCircumference = bellyCircumference
        self.bodyFatPercentage = bodyFatPercentage
        self.muscleMass = muscleMass
        self.createdAt = Date()
    }
}

// MARK: - Nutrition Models
@Model
final class MealLog {
    var date: Date
    var mealType: String // breakfast, lunch, dinner, snack
    var foodItems: [MealFoodItem]
    var createdAt: Date
    
    var totalCalories: Double { foodItems.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { foodItems.reduce(0) { $0 + $1.protein } }
    var totalCarbs: Double { foodItems.reduce(0) { $0 + $1.carbs } }
    var totalFat: Double { foodItems.reduce(0) { $0 + $1.fat } }
    
    init(date: Date = Date(), mealType: String = "", foodItems: [MealFoodItem] = []) {
        self.date = date
        self.mealType = mealType
        self.foodItems = foodItems
        self.createdAt = Date()
    }
}

@Model
final class MealFoodItem {
    var foodItem: String
    var measure: String
    var quantity: Double
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    
    init(foodItem: String, measure: String, quantity: Double, calories: Double, protein: Double, carbs: Double, fat: Double, fiber: Double) {
        self.foodItem = foodItem
        self.measure = measure
        self.quantity = quantity
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
    }
}

@Model
final class WaterLog {
    var date: Date
    var amount: Double // in ml
    var unit: String // ml or oz
    var createdAt: Date
    
    init(date: Date = Date(), amount: Double = 0, unit: String = "ml") {
        self.date = date
        self.amount = amount
        self.unit = unit
        self.createdAt = Date()
    }
}

// MARK: - Workout Models
@Model
final class WorkoutLog {
    var date: Date
    var name: String
    var exercises: [WorkoutExercise]
    var duration: TimeInterval // in seconds
    var isCompleted: Bool
    var createdAt: Date
    
    init(date: Date = Date(), name: String = "", exercises: [WorkoutExercise] = []) {
        self.date = date
        self.name = name
        self.exercises = exercises
        self.duration = 0
        self.isCompleted = false
        self.createdAt = Date()
    }
}

@Model
final class WorkoutExercise {
    var exercise: String
    var category: String
    var difficulty: String
    var sets: [ExerciseSet]
    var isCardio: Bool
    var cardioTime: TimeInterval? // in seconds
    var cardioDistance: Double? // in meters
    
    init(exercise: String, category: String, difficulty: String, sets: [ExerciseSet] = [], isCardio: Bool = false, cardioTime: TimeInterval? = nil, cardioDistance: Double? = nil) {
        self.exercise = exercise
        self.category = category
        self.difficulty = difficulty
        self.sets = sets
        self.isCardio = isCardio
        self.cardioTime = cardioTime
        self.cardioDistance = cardioDistance
    }
}

@Model
final class ExerciseSet {
    var setNumber: Int
    var reps: Int
    var weight: Double // in kg
    var duration: TimeInterval? // in seconds for timed exercises
    
    init(setNumber: Int, reps: Int = 0, weight: Double = 0, duration: TimeInterval? = nil) {
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.duration = duration
    }
}

@Model
final class SavedWorkout {
    var name: String
    var exercises: [SavedWorkoutExercise]
    var createdAt: Date
    
    init(name: String = "", exercises: [SavedWorkoutExercise] = []) {
        self.name = name
        self.exercises = exercises
        self.createdAt = Date()
    }
}

@Model
final class SavedWorkoutExercise {
    var exercise: String
    var category: String
    var difficulty: String
    var isCardio: Bool
    var defaultSets: Int
    var defaultReps: Int
    var defaultWeight: Double
    var defaultDuration: TimeInterval?
    var defaultDistance: Double?
    
    init(exercise: String, category: String, difficulty: String, isCardio: Bool = false, defaultSets: Int = 3, defaultReps: Int = 10, defaultWeight: Double = 0, defaultDuration: TimeInterval? = nil, defaultDistance: Double? = nil) {
        self.exercise = exercise
        self.category = category
        self.difficulty = difficulty
        self.isCardio = isCardio
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.defaultWeight = defaultWeight
        self.defaultDuration = defaultDuration
        self.defaultDistance = defaultDistance
    }
}

// MARK: - Data Models for JSON Resources
struct FoodItem: Codable, Identifiable {
    var id: UUID = UUID()
    let category: String
    let foodItem: String
    let measure: String
    let grams: String
    let calories: String
    let protein: String
    let carb: String
    let fiber: String
    let fat: String
    let saturatedFat: String

    private enum CodingKeys: String, CodingKey {
        case category, foodItem, measure, grams, calories, protein, carb, fiber, fat, saturatedFat
    }
}

struct Exercise: Codable, Identifiable {
    var id: UUID = UUID()
    let difficulty: String
    let category: String
    let exercise: String
    let visualExample: String

    private enum CodingKeys: String, CodingKey {
        case difficulty, category, exercise, visualExample
    }
} 