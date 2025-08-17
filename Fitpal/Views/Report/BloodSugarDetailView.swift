import SwiftUI

struct BloodSugarDetailView: View {
    let reading: BloodSugarReading
    @ObservedObject var service: BloodSugarService
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingEditForm = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Main Reading Display
                    VStack(spacing: 20) {
                        // Glucose Level Display
                        VStack(spacing: 8) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("\(Int(reading.glucoseLevel))")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(reading.riskLevel.color)
                                
                                Text("mg/dL")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(reading.readingType.displayName)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        // Risk Level Badge
                        HStack {
                            Circle()
                                .fill(reading.riskLevel.color)
                                .frame(width: 12, height: 12)
                            
                            Text(reading.riskLevel.displayName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(reading.riskLevel.color)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(reading.riskLevel.color.opacity(0.1))
                        )
                    }
                    .padding(.top, 20)
                    
                    // Reading Information
                    VStack(spacing: 16) {
                        DetailInfoCard(
                            title: "Date & Time",
                            value: reading.date.formatted(date: .complete, time: .shortened),
                            icon: "calendar"
                        )
                        
                        DetailInfoCard(
                            title: "Reading Type",
                            value: reading.readingType.displayName,
                            subtitle: reading.readingType.description,
                            icon: "drop.circle"
                        )
                        
                        if let notes = reading.notes, !notes.isEmpty {
                            DetailInfoCard(
                                title: "Notes",
                                value: notes,
                                icon: "note.text"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Risk Assessment
                    RiskAssessmentDetailCard(reading: reading)
                        .padding(.horizontal, 20)
                    
                    // Recommendations
                    if reading.riskLevel != .normal {
                        RecommendationsCard(reading: reading)
                            .padding(.horizontal, 20)
                    }
                    
                    // Context & Trends
                    ContextCard(reading: reading, service: service)
                        .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Reading Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Edit Reading") {
                            showingEditForm = true
                        }
                        
                        Button("Share Reading") {
                            shareReading()
                        }
                        
                        Divider()
                        
                        Button("Delete Reading", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Delete Reading", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    service.deleteReading(reading)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this blood sugar reading? This action cannot be undone.")
            }
            .sheet(isPresented: $showingEditForm) {
                BloodSugarEditFormView(reading: reading, service: service)
            }
        }
    }
    
    private func shareReading() {
        let shareText = """
        Blood Sugar Reading
        
        Glucose Level: \(Int(reading.glucoseLevel)) mg/dL
        Type: \(reading.readingType.displayName)
        Risk Level: \(reading.riskLevel.displayName)
        Date: \(reading.date.formatted(date: .complete, time: .shortened))
        
        \(reading.notes ?? "")
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct DetailInfoCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    
    init(title: String, value: String, subtitle: String? = nil, icon: String) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

struct RiskAssessmentDetailCard: View {
    let reading: BloodSugarReading
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Risk Assessment")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "shield.checkered")
                    .foregroundColor(reading.riskLevel.color)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(reading.riskLevel.color)
                        .frame(width: 16, height: 16)
                    
                    Text(reading.riskLevel.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(reading.riskLevel.color)
                    
                    Spacer()
                }
                
                Text(reading.riskDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Reference Ranges
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reference Ranges for \(reading.readingType.displayName)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ReferenceRangeItem(
                            level: "Normal",
                            range: reading.readingType.normalRange,
                            color: .green
                        )
                        
                        ReferenceRangeItem(
                            level: "Prediabetic",
                            range: reading.readingType.prediabeticRange,
                            color: .orange
                        )
                        
                        ReferenceRangeItem(
                            level: "Diabetic",
                            range: reading.readingType.diabeticRange,
                            color: .red
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

struct ReferenceRangeItem: View {
    let level: String
    let range: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(level)
                .font(.caption2)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(range)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct RecommendationsCard: View {
    let reading: BloodSugarReading
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "lightbulb")
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(getRecommendations(), id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text(recommendation)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func getRecommendations() -> [String] {
        switch reading.riskLevel {
        case .low:
            return [
                "Consider eating a balanced snack",
                "Monitor for symptoms of hypoglycemia",
                "Consult your healthcare provider if readings stay low"
            ]
        case .preDiabetic:
            return [
                "Maintain a balanced diet with controlled carbohydrates",
                "Engage in regular physical activity",
                "Consider lifestyle modifications",
                "Schedule regular check-ups with your doctor"
            ]
        case .diabetic:
            return [
                "Follow your prescribed medication regimen",
                "Monitor blood sugar levels regularly",
                "Maintain strict dietary control",
                "Consult your healthcare provider immediately"
            ]
        case .normal:
            return []
        }
    }
}

struct ContextCard: View {
    let reading: BloodSugarReading
    let service: BloodSugarService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Context & Trends")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if let average = service.getAverageGlucose(for: reading.readingType) {
                    ContextItem(
                        title: "Your \(reading.readingType.displayName) Average",
                        value: "\(Int(average)) mg/dL",
                        comparison: getComparison(current: reading.glucoseLevel, average: average)
                    )
                }
                
                let recentReadings = service.getRecentReadings(days: 7)
                if recentReadings.count > 1 {
                    ContextItem(
                        title: "7-Day Trend",
                        value: service.getRiskTrend().displayName,
                        comparison: nil
                    )
                }
                
                ContextItem(
                    title: "Total Readings",
                    value: "\(service.readings.count)",
                    comparison: nil
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
    
    private func getComparison(current: Double, average: Double) -> String {
        let difference = current - average
        let percentage = abs(difference / average * 100)
        
        if abs(difference) < 5 {
            return "Similar to your average"
        } else if difference > 0 {
            return "\(Int(percentage))% higher than average"
        } else {
            return "\(Int(percentage))% lower than average"
        }
    }
}

struct ContextItem: View {
    let title: String
    let value: String
    let comparison: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let comparison = comparison {
                    Text(comparison)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    BloodSugarDetailView(
        reading: BloodSugarReading(
            date: Date(),
            glucoseLevel: 120,
            readingType: .fasting,
            notes: "Feeling good this morning",
            medication: nil,
            symptoms: [],
            mealTiming: nil
        ),
        service: BloodSugarService()
    )
}
