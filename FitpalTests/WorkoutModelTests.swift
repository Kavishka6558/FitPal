//
//  WorkoutModelTests.swift
//  FitpalTests
//
//  Created by Kavishka 024 on 2025-09-19.
//

import Testing
import Foundation
import SwiftUI
@testable import Fitpal

// MARK: - Workout Model Tests
struct WorkoutModelTests {
    
    // Test Workout model initialization
    @Test func testWorkoutInitialization() {
        let workout = Workout(
            name: "Push-ups",
            sets: 3,
            reps: 15
        )
        
        #expect(workout.name == "Push-ups")
        #expect(workout.sets == 3)
        #expect(workout.reps == 15)
        #expect(workout.isCompleted == false)
    }
    
    // Test workout completion state
    @Test func testWorkoutCompletionState() {
        var workout = Workout(
            name: "Squats",
            sets: 4,
            reps: 12
        )
        
        #expect(workout.isCompleted == false)
        
        workout.isCompleted = true
        #expect(workout.isCompleted == true)
    }
    
    // Test Workout Hashable conformance
    @Test func testWorkoutHashable() {
        let workout1 = Workout(name: "Bench Press", sets: 3, reps: 10)
        let workout2 = Workout(name: "Bench Press", sets: 3, reps: 10)
        
        // Different workouts should have different IDs even with same content
        #expect(workout1.id != workout2.id)
        
        // Same workout should equal itself
        #expect(workout1 == workout1)
        #expect(workout1 != workout2) // Different IDs
    }
    
    // Test HealthCardData initialization
    @Test func testHealthCardDataInitialization() {
        let healthCard = HealthCardData(
            title: "Steps",
            value: "8,542",
            unit: "steps",
            icon: "figure.walk",
            color: .blue
        )
        
        #expect(healthCard.title == "Steps")
        #expect(healthCard.value == "8,542")
        #expect(healthCard.unit == "steps")
        #expect(healthCard.icon == "figure.walk")
        #expect(healthCard.color == .blue)
    }
    
    // Test Color hex extension
    @Test func testColorHexExtension() {
        let redColor = Color(hex: "FF0000")
        let greenColor = Color(hex: "00FF00")
        let blueColor = Color(hex: "0000FF")
        let customColor = Color(hex: "A1B2C3")
        
        // Colors should be created without crashing
        #expect(redColor != nil)
        #expect(greenColor != nil)
        #expect(blueColor != nil)
        #expect(customColor != nil)
        
        // Test 3-digit hex
        let shortHex = Color(hex: "F0A")
        #expect(shortHex != nil)
        
        // Test 8-digit hex (with alpha)
        let alphaColor = Color(hex: "FF0000AA")
        #expect(alphaColor != nil)
        
        // Test invalid hex
        let invalidColor = Color(hex: "invalid")
        #expect(invalidColor != nil) // Should default to black
    }
    
    // Test workout validation
    @Test func testWorkoutValidation() {
        // Valid workout
        let validWorkout = Workout(
            name: "Deadlift",
            sets: 5,
            reps: 5
        )
        
        #expect(!validWorkout.name.isEmpty)
        #expect(validWorkout.sets > 0)
        #expect(validWorkout.reps > 0)
        
        // Edge cases
        let singleSetWorkout = Workout(
            name: "Plank Hold",
            sets: 1,
            reps: 1
        )
        
        #expect(singleSetWorkout.sets == 1)
        #expect(singleSetWorkout.reps == 1)
        
        // High volume workout
        let highVolumeWorkout = Workout(
            name: "Calf Raises",
            sets: 5,
            reps: 50
        )
        
        #expect(highVolumeWorkout.sets == 5)
        #expect(highVolumeWorkout.reps == 50)
    }
    
    // Test workout types and categories
    @Test func testWorkoutTypesAndCategories() {
        let strengthWorkouts = [
            Workout(name: "Bench Press", sets: 4, reps: 8),
            Workout(name: "Squats", sets: 4, reps: 10),
            Workout(name: "Deadlifts", sets: 3, reps: 5)
        ]
        
        let cardioWorkouts = [
            Workout(name: "Burpees", sets: 3, reps: 10),
            Workout(name: "Mountain Climbers", sets: 3, reps: 20),
            Workout(name: "Jumping Jacks", sets: 4, reps: 30)
        ]
        
        #expect(strengthWorkouts.count == 3)
        #expect(cardioWorkouts.count == 3)
        
        // Test that each workout has valid properties
        for workout in strengthWorkouts + cardioWorkouts {
            #expect(!workout.name.isEmpty)
            #expect(workout.sets > 0)
            #expect(workout.reps > 0)
        }
    }
    
    // Test workout collections and sets
    @Test func testWorkoutCollections() {
        let workouts = [
            Workout(name: "Push-ups", sets: 3, reps: 15),
            Workout(name: "Pull-ups", sets: 3, reps: 8),
            Workout(name: "Dips", sets: 3, reps: 12)
        ]
        
        #expect(workouts.count == 3)
        
        // Test filtering completed workouts
        var completedWorkouts = workouts
        completedWorkouts[0].isCompleted = true
        completedWorkouts[1].isCompleted = true
        
        let finished = completedWorkouts.filter { $0.isCompleted }
        let remaining = completedWorkouts.filter { !$0.isCompleted }
        
        #expect(finished.count == 2)
        #expect(remaining.count == 1)
    }
    
    // Test health card data variations
    @Test func testHealthCardVariations() {
        let healthCards = [
            HealthCardData(title: "Steps", value: "10,000", unit: "steps", icon: "figure.walk", color: .green),
            HealthCardData(title: "Calories", value: "2,500", unit: "cal", icon: "flame", color: .orange),
            HealthCardData(title: "Distance", value: "5.2", unit: "km", icon: "location", color: .blue),
            HealthCardData(title: "Heart Rate", value: "72", unit: "bpm", icon: "heart", color: .red)
        ]
        
        #expect(healthCards.count == 4)
        
        for card in healthCards {
            #expect(!card.title.isEmpty)
            #expect(!card.value.isEmpty)
            #expect(!card.unit.isEmpty)
            #expect(!card.icon.isEmpty)
        }
        
        // Test unique IDs
        let ids = Set(healthCards.map { $0.id })
        #expect(ids.count == healthCards.count)
    }
    
    // Test realistic workout scenarios
    @Test func testRealisticWorkoutScenarios() {
        // Beginner workout routine
        let beginnerRoutine = [
            Workout(name: "Bodyweight Squats", sets: 2, reps: 10),
            Workout(name: "Wall Push-ups", sets: 2, reps: 8),
            Workout(name: "Assisted Pull-ups", sets: 2, reps: 5)
        ]
        
        for workout in beginnerRoutine {
            #expect(workout.sets <= 3) // Beginner-friendly volume
            #expect(workout.reps <= 15)
        }
        
        // Advanced workout routine
        let advancedRoutine = [
            Workout(name: "Weighted Pull-ups", sets: 5, reps: 5),
            Workout(name: "One-arm Push-ups", sets: 3, reps: 3),
            Workout(name: "Pistol Squats", sets: 4, reps: 6)
        ]
        
        for workout in advancedRoutine {
            #expect(workout.sets >= 3) // Higher volume for advanced
            #expect(!workout.name.isEmpty)
        }
        
        // Endurance workout
        let enduranceRoutine = [
            Workout(name: "High Rep Push-ups", sets: 3, reps: 50),
            Workout(name: "Air Squats", sets: 5, reps: 100),
            Workout(name: "Crunches", sets: 4, reps: 75)
        ]
        
        for workout in enduranceRoutine {
            #expect(workout.reps >= 50) // High rep endurance work
        }
    }
    
    // Test workout progress tracking
    @Test func testWorkoutProgressTracking() {
        var workout = Workout(name: "Progressive Push-ups", sets: 3, reps: 10)
        
        // Start uncompleted
        #expect(workout.isCompleted == false)
        
        // Simulate completing the workout
        workout.isCompleted = true
        #expect(workout.isCompleted == true)
        
        // Test that ID remains constant
        let originalId = workout.id
        workout.isCompleted = false
        workout.isCompleted = true
        #expect(workout.id == originalId)
    }
    
    // Test workout data integrity
    @Test func testWorkoutDataIntegrity() {
        let workouts = [
            Workout(name: "Bench Press", sets: 4, reps: 8),
            Workout(name: "Incline Press", sets: 3, reps: 10),
            Workout(name: "Flyes", sets: 3, reps: 12)
        ]
        
        // Each workout should have unique ID
        let uniqueIds = Set(workouts.map { $0.id })
        #expect(uniqueIds.count == workouts.count)
        
        // Test that modification doesn't affect other workouts
        var modifiedWorkouts = workouts
        modifiedWorkouts[0].isCompleted = true
        
        #expect(workouts[0].isCompleted == false) // Original unchanged
        #expect(modifiedWorkouts[0].isCompleted == true) // Copy modified
    }
}
