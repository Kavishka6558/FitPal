//
//  UserProfileTests.swift
//  FitpalTests
//
//  Created by Kavishka 024 on 2025-09-19.
//

import Testing
import Foundation
@testable import Fitpal

// MARK: - User Profile Model Tests
struct UserProfileTests {
    
    // Test initialization
    @Test func testInitialization() {
        let profile = UserProfile()
        
        #expect(profile.age == nil)
        #expect(profile.heightFeet == nil)
        #expect(profile.heightInches == nil)
        #expect(profile.weight == nil)
        #expect(profile.bloodSugarLevel == nil)
        #expect(profile.totalCholesterol == nil)
        #expect(profile.hdlCholesterol == nil)
        #expect(profile.ldlCholesterol == nil)
        #expect(profile.isCompleted == false)
    }
    
    // Test height conversion
    @Test func testHeightConversion() {
        var profile = UserProfile()
        
        // Test with no height data
        #expect(profile.heightInCm == nil)
        
        // Test with valid height data (5 feet 10 inches)
        profile.heightFeet = 5
        profile.heightInches = 10
        
        let expectedCm = Double(5 * 12 + 10) * 2.54 // 177.8 cm
        #expect(profile.heightInCm == expectedCm)
        
        // Test edge case (0 feet 0 inches)
        profile.heightFeet = 0
        profile.heightInches = 0
        #expect(profile.heightInCm == 0.0)
        
        // Test with only feet
        profile.heightFeet = 6
        profile.heightInches = nil
        #expect(profile.heightInCm == nil)
    }
    
    // Test BMI calculation
    @Test func testBMICalculation() {
        var profile = UserProfile()
        
        // Test with no data
        #expect(profile.bmi == nil)
        
        // Test with complete data (5'10", 170 lbs)
        profile.heightFeet = 5
        profile.heightInches = 10
        profile.weight = 170.0
        
        let heightInMeters = (5 * 12 + 10) * 2.54 / 100 // 1.778 meters
        let weightInKg = 170.0 * 0.453592 // 77.11 kg
        let expectedBMI = weightInKg / (heightInMeters * heightInMeters)
        
        #expect(profile.bmi != nil)
        if let bmi = profile.bmi {
            #expect(abs(bmi - expectedBMI) < 0.01) // Allow small floating point differences
        }
        
        // Test with missing weight
        profile.weight = nil
        #expect(profile.bmi == nil)
    }
    
    // Test BMI categories
    @Test func testBMICategories() {
        var profile = UserProfile()
        
        // Test without BMI data
        #expect(profile.bmiCategory == "Unknown")
        
        // Set height for BMI calculations (5'10")
        profile.heightFeet = 5
        profile.heightInches = 10
        
        // Test Underweight (BMI < 18.5) - ~125 lbs
        profile.weight = 125.0
        #expect(profile.bmiCategory == "Underweight")
        
        // Test Normal (BMI 18.5-24.9) - ~140 lbs
        profile.weight = 140.0
        #expect(profile.bmiCategory == "Normal")
        
        // Test Overweight (BMI 25-29.9) - ~185 lbs
        profile.weight = 185.0
        #expect(profile.bmiCategory == "Overweight")
        
        // Test Obese (BMI >= 30) - ~220 lbs
        profile.weight = 220.0
        #expect(profile.bmiCategory == "Obese")
    }
    
    // Test blood sugar status
    @Test func testBloodSugarStatus() {
        var profile = UserProfile()
        
        // Test without blood sugar data
        #expect(profile.bloodSugarStatus == "Unknown")
        
        // Test Low (< 70)
        profile.bloodSugarLevel = 65.0
        #expect(profile.bloodSugarStatus == "Low")
        
        // Test Normal (70-100)
        profile.bloodSugarLevel = 85.0
        #expect(profile.bloodSugarStatus == "Normal")
        
        // Test Prediabetes (101-125)
        profile.bloodSugarLevel = 110.0
        #expect(profile.bloodSugarStatus == "Prediabetes")
        
        // Test Diabetes (> 125)
        profile.bloodSugarLevel = 150.0
        #expect(profile.bloodSugarStatus == "Diabetes")
        
        // Test edge cases
        profile.bloodSugarLevel = 70.0
        #expect(profile.bloodSugarStatus == "Normal")
        
        profile.bloodSugarLevel = 100.0
        #expect(profile.bloodSugarStatus == "Normal")
        
        profile.bloodSugarLevel = 101.0
        #expect(profile.bloodSugarStatus == "Prediabetes")
        
        profile.bloodSugarLevel = 125.0
        #expect(profile.bloodSugarStatus == "Prediabetes")
    }
    
    // Test cholesterol status
    @Test func testCholesterolStatus() {
        var profile = UserProfile()
        
        // Test without cholesterol data
        #expect(profile.totalCholesterolStatus == "Unknown")
        
        // Test Normal (< 200)
        profile.totalCholesterol = 180.0
        #expect(profile.totalCholesterolStatus == "Normal")
        
        // Test Borderline High (200-239)
        profile.totalCholesterol = 220.0
        #expect(profile.totalCholesterolStatus == "Borderline High")
        
        // Test High (>= 240)
        profile.totalCholesterol = 250.0
        #expect(profile.totalCholesterolStatus == "High")
        
        // Test edge cases
        profile.totalCholesterol = 200.0
        #expect(profile.totalCholesterolStatus == "Borderline High")
        
        profile.totalCholesterol = 239.0
        #expect(profile.totalCholesterolStatus == "Borderline High")
        
        profile.totalCholesterol = 240.0
        #expect(profile.totalCholesterolStatus == "High")
    }
    
    // Test profile completion status
    @Test func testProfileCompletion() {
        var profile = UserProfile()
        
        // Initially not completed
        #expect(profile.isCompleted == false)
        
        // Mark as completed
        profile.isCompleted = true
        #expect(profile.isCompleted == true)
    }
    
    // Test Codable conformance
    @Test func testCodableConformance() throws {
        var profile = UserProfile()
        profile.age = 25
        profile.heightFeet = 5
        profile.heightInches = 10
        profile.weight = 170.0
        profile.bloodSugarLevel = 85.0
        profile.totalCholesterol = 190.0
        profile.hdlCholesterol = 60.0
        profile.ldlCholesterol = 110.0
        profile.isCompleted = true
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(profile)
        #expect(data.count > 0)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedProfile = try decoder.decode(UserProfile.self, from: data)
        
        #expect(decodedProfile.age == profile.age)
        #expect(decodedProfile.heightFeet == profile.heightFeet)
        #expect(decodedProfile.heightInches == profile.heightInches)
        #expect(decodedProfile.weight == profile.weight)
        #expect(decodedProfile.bloodSugarLevel == profile.bloodSugarLevel)
        #expect(decodedProfile.totalCholesterol == profile.totalCholesterol)
        #expect(decodedProfile.hdlCholesterol == profile.hdlCholesterol)
        #expect(decodedProfile.ldlCholesterol == profile.ldlCholesterol)
        #expect(decodedProfile.isCompleted == profile.isCompleted)
    }
    
    // Test realistic health scenarios
    @Test func testRealisticHealthScenarios() {
        // Scenario 1: Healthy young adult
        var healthyProfile = UserProfile()
        healthyProfile.age = 25
        healthyProfile.heightFeet = 5
        healthyProfile.heightInches = 8
        healthyProfile.weight = 150.0
        healthyProfile.bloodSugarLevel = 90.0
        healthyProfile.totalCholesterol = 180.0
        
        #expect(healthyProfile.bmiCategory == "Normal")
        #expect(healthyProfile.bloodSugarStatus == "Normal")
        #expect(healthyProfile.totalCholesterolStatus == "Normal")
        
        // Scenario 2: Person with health risks
        var atRiskProfile = UserProfile()
        atRiskProfile.age = 45
        atRiskProfile.heightFeet = 5
        atRiskProfile.heightInches = 6
        atRiskProfile.weight = 200.0
        atRiskProfile.bloodSugarLevel = 115.0
        atRiskProfile.totalCholesterol = 230.0
        
        #expect(atRiskProfile.bmiCategory == "Obese")
        #expect(atRiskProfile.bloodSugarStatus == "Prediabetes")
        #expect(atRiskProfile.totalCholesterolStatus == "Borderline High")
    }
}
