import Foundation
import SwiftUI

// MARK: - Blood Sugar Models
struct BloodSugarReading: Identifiable, Codable {
    let id: UUID
    let date: Date
    let glucoseLevel: Double // mg/dL
    let readingType: BloodSugarType
    let notes: String?
    let medication: String?
    let symptoms: [String]
    let mealTiming: MealTiming?
    
    // Custom initializer with default UUID
    init(id: UUID = UUID(), date: Date, glucoseLevel: Double, readingType: BloodSugarType, notes: String?, medication: String?, symptoms: [String], mealTiming: MealTiming?) {
        self.id = id
        self.date = date
        self.glucoseLevel = glucoseLevel
        self.readingType = readingType
        self.notes = notes
        self.medication = medication
        self.symptoms = symptoms
        self.mealTiming = mealTiming
    }
    
    var riskLevel: RiskLevel {
        switch readingType {
        case .fasting:
            if glucoseLevel < 70 { return .low }
            else if glucoseLevel <= 99 { return .normal }
            else if glucoseLevel <= 125 { return .preDiabetic }
            else { return .diabetic }
            
        case .beforeMeal:
            if glucoseLevel < 70 { return .low }
            else if glucoseLevel <= 130 { return .normal }
            else if glucoseLevel <= 180 { return .preDiabetic }
            else { return .diabetic }
            
        case .postMeal:
            if glucoseLevel < 70 { return .low }
            else if glucoseLevel <= 140 { return .normal }
            else if glucoseLevel <= 199 { return .preDiabetic }
            else { return .diabetic }
            
        case .bedtime:
            if glucoseLevel < 70 { return .low }
            else if glucoseLevel <= 120 { return .normal }
            else if glucoseLevel <= 160 { return .preDiabetic }
            else { return .diabetic }
            
        case .random:
            if glucoseLevel < 70 { return .low }
            else if glucoseLevel <= 140 { return .normal }
            else if glucoseLevel <= 199 { return .preDiabetic }
            else { return .diabetic }
        }
    }
    
    var riskDescription: String {
        switch riskLevel {
        case .low:
            return "Low blood sugar - Consider eating something"
        case .normal:
            return "Normal blood sugar level"
        case .preDiabetic:
            return "Pre-diabetic range - Consult your doctor"
        case .diabetic:
            return "Diabetic range - Seek medical attention"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum BloodSugarType: String, CaseIterable, Codable {
    case fasting = "fasting"
    case beforeMeal = "before_meal"
    case postMeal = "post_meal"
    case bedtime = "bedtime"
    case random = "random"
    
    var displayName: String {
        switch self {
        case .fasting:
            return "Fasting"
        case .beforeMeal:
            return "Before Meal"
        case .postMeal:
            return "Post-Meal (2 hours)"
        case .bedtime:
            return "Bedtime"
        case .random:
            return "Random"
        }
    }
    
    var description: String {
        switch self {
        case .fasting:
            return "8+ hours without food"
        case .beforeMeal:
            return "Before eating a meal"
        case .postMeal:
            return "2 hours after eating"
        case .bedtime:
            return "Before going to sleep"
        case .random:
            return "Any time of day"
        }
    }
    
    var normalRange: String {
        switch self {
        case .fasting:
            return "70-99 mg/dL"
        case .beforeMeal:
            return "70-130 mg/dL"
        case .postMeal:
            return "< 140 mg/dL"
        case .bedtime:
            return "70-120 mg/dL"
        case .random:
            return "< 140 mg/dL"
        }
    }
    
    var prediabeticRange: String {
        switch self {
        case .fasting:
            return "100-125 mg/dL"
        case .beforeMeal:
            return "130-180 mg/dL"
        case .postMeal:
            return "140-199 mg/dL"
        case .bedtime:
            return "120-160 mg/dL"
        case .random:
            return "140-199 mg/dL"
        }
    }
    
    var diabeticRange: String {
        switch self {
        case .fasting:
            return "≥ 126 mg/dL"
        case .beforeMeal:
            return "≥ 180 mg/dL"
        case .postMeal:
            return "≥ 200 mg/dL"
        case .bedtime:
            return "≥ 160 mg/dL"
        case .random:
            return "≥ 200 mg/dL"
        }
    }
}

enum RiskLevel: String, CaseIterable, Codable {
    case low = "low"
    case normal = "normal"
    case preDiabetic = "pre_diabetic"
    case diabetic = "diabetic"
    
    var color: Color {
        switch self {
        case .low:
            return .orange
        case .normal:
            return .green
        case .preDiabetic:
            return .yellow
        case .diabetic:
            return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .normal:
            return "Normal"
        case .preDiabetic:
            return "Pre-Diabetic"
        case .diabetic:
            return "Diabetic"
        }
    }
}

enum MealTiming: String, CaseIterable, Codable {
    case beforeBreakfast = "before_breakfast"
    case afterBreakfast = "after_breakfast"
    case beforeLunch = "before_lunch"
    case afterLunch = "after_lunch"
    case beforeDinner = "before_dinner"
    case afterDinner = "after_dinner"
    case beforeSnack = "before_snack"
    case afterSnack = "after_snack"
    
    var displayName: String {
        switch self {
        case .beforeBreakfast:
            return "Before Breakfast"
        case .afterBreakfast:
            return "After Breakfast"
        case .beforeLunch:
            return "Before Lunch"
        case .afterLunch:
            return "After Lunch"
        case .beforeDinner:
            return "Before Dinner"
        case .afterDinner:
            return "After Dinner"
        case .beforeSnack:
            return "Before Snack"
        case .afterSnack:
            return "After Snack"
        }
    }
}

// MARK: - Sample Data
extension BloodSugarReading {
    static let sampleData: [BloodSugarReading] = [
        BloodSugarReading(
            date: Date().addingTimeInterval(-86400 * 2),
            glucoseLevel: 95,
            readingType: .fasting,
            notes: "Feeling good this morning",
            medication: "Metformin 500mg",
            symptoms: [],
            mealTiming: .beforeBreakfast
        ),
        BloodSugarReading(
            date: Date().addingTimeInterval(-86400),
            glucoseLevel: 145,
            readingType: .postMeal,
            notes: "After pasta dinner",
            medication: nil,
            symptoms: ["Slightly tired"],
            mealTiming: .afterDinner
        ),
        BloodSugarReading(
            date: Date().addingTimeInterval(-3600),
            glucoseLevel: 88,
            readingType: .random,
            notes: nil,
            medication: nil,
            symptoms: [],
            mealTiming: nil
        )
    ]
}

import SwiftUI
