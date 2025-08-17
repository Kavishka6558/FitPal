import Foundation
import Combine
import SwiftUI

class BloodSugarService: ObservableObject {
    @Published var readings: [BloodSugarReading] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let storageKey = "blood_sugar_readings"
    
    init() {
        loadReadings()
    }
    
    // MARK: - Public Methods
    
    func addReading(_ reading: BloodSugarReading) {
        readings.append(reading)
        readings.sort { $0.date > $1.date } // Sort by most recent first
        saveReadings()
    }
    
    func updateReading(_ reading: BloodSugarReading) {
        if let index = readings.firstIndex(where: { $0.id == reading.id }) {
            readings[index] = reading
            readings.sort { $0.date > $1.date }
            saveReadings()
        }
    }
    
    func deleteReading(_ reading: BloodSugarReading) {
        readings.removeAll { $0.id == reading.id }
        saveReadings()
    }
    
    func getRecentReadings(days: Int = 30) -> [BloodSugarReading] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return readings.filter { $0.date >= cutoffDate }
    }
    
    func getAverageGlucose(for type: BloodSugarType, days: Int = 30) -> Double? {
        let recentReadings = getRecentReadings(days: days)
        let filteredReadings = recentReadings.filter { $0.readingType == type }
        
        guard !filteredReadings.isEmpty else { return nil }
        
        let total = filteredReadings.reduce(0) { $0 + $1.glucoseLevel }
        return total / Double(filteredReadings.count)
    }
    
    func getRiskTrend(days: Int = 30) -> RiskTrend {
        let recentReadings = getRecentReadings(days: days)
        guard recentReadings.count >= 2 else { return .stable }
        
        let firstHalf = recentReadings.suffix(recentReadings.count / 2)
        let secondHalf = recentReadings.prefix(recentReadings.count / 2)
        
        let firstAverage = firstHalf.reduce(0) { $0 + $1.glucoseLevel } / Double(firstHalf.count)
        let secondAverage = secondHalf.reduce(0) { $0 + $1.glucoseLevel } / Double(secondHalf.count)
        
        let difference = secondAverage - firstAverage
        
        if difference > 10 { return .improving }
        else if difference < -10 { return .worsening }
        else { return .stable }
    }
    
    func getLatestReading() -> BloodSugarReading? {
        return readings.first
    }
    
    func exportData() -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(readings)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    // MARK: - Private Methods
    
    private func loadReadings() {
        if let data = userDefaults.data(forKey: storageKey) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                readings = try decoder.decode([BloodSugarReading].self, from: data)
                readings.sort { $0.date > $1.date }
            } catch {
                // If loading fails, use sample data
                readings = BloodSugarReading.sampleData
                errorMessage = "Failed to load saved data. Using sample data."
            }
        } else {
            // First time user - load sample data
            readings = BloodSugarReading.sampleData
        }
    }
    
    private func saveReadings() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(readings)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            errorMessage = "Failed to save reading: \(error.localizedDescription)"
        }
    }
}

enum RiskTrend {
    case improving
    case stable
    case worsening
    
    var displayName: String {
        switch self {
        case .improving:
            return "Improving"
        case .stable:
            return "Stable"
        case .worsening:
            return "Needs Attention"
        }
    }
    
    var color: Color {
        switch self {
        case .improving:
            return .green
        case .stable:
            return .blue
        case .worsening:
            return .red
        }
    }
    
    var icon: String {
        switch self {
        case .improving:
            return "arrow.up.circle.fill"
        case .stable:
            return "minus.circle.fill"
        case .worsening:
            return "arrow.down.circle.fill"
        }
    }
}
