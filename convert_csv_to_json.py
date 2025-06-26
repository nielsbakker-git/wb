#!/usr/bin/env python3
import csv
import json
import os

def convert_food_items():
    """Convert fooditems.csv to JSON format"""
    food_items = []
    
    with open('fooditems.csv', 'r', encoding='utf-8-sig') as file:
        reader = csv.DictReader(file)
        
        for row in reader:
            try:
                food_item = {
                    "category": row.get('Category', ''),
                    "foodItem": row.get('Food', ''),
                    "measure": row.get('Measure', ''),
                    "grams": row.get('Grams', ''),
                    "calories": row.get('Calories', '0'),
                    "protein": row.get('Protein', '0'),
                    "carb": row.get('Carb', '0'),
                    "fiber": row.get('Fiber', '0'),
                    "fat": row.get('Fat', '0'),
                    "saturatedFat": row.get('Saturated fat', '0')
                }
                food_items.append(food_item)
            except Exception as e:
                print(f"Error processing row: {row}, Error: {e}")
    
    # Write to JSON file
    with open('fooditems.json', 'w', encoding='utf-8') as json_file:
        json.dump(food_items, json_file, indent=2, ensure_ascii=False)
    
    print(f"Converted {len(food_items)} food items to fooditems.json")

def convert_exercises():
    """Convert allexercises.csv to JSON format"""
    exercises = []
    
    with open('allexercises.csv', 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        
        for row in reader:
            exercise = {
                "difficulty": row.get('Dificulty', ''),
                "category": row.get('Category', ''),
                "exercise": row.get('Exercise', ''),
                "visualExample": row.get('Visual Example', '')
            }
            exercises.append(exercise)
    
    # Write to JSON file
    with open('WB/allexercises.json', 'w', encoding='utf-8') as json_file:
        json.dump(exercises, json_file, indent=2, ensure_ascii=False)
    
    print(f"Converted {len(exercises)} exercises to allexercises.json")

if __name__ == "__main__":
    # Create WB directory if it doesn't exist
    os.makedirs('WB', exist_ok=True)
    
    # Convert both files
    convert_food_items()
    convert_exercises()
    
    print("Conversion completed successfully!") 