import SwiftUI

struct HeartRiskResultsView: View {
    let riskAssessment: String
    let bloodPressure: String
    let age: String
    let hasDiabetes: Bool
    let smokingStatus: String
    let cholesterolLevel: String
    let familyHistory: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    private var riskColor: Color {
        switch riskAssessment {
        case "Low Risk":
            return .green
        case "Moderate Risk":
            return .orange
        case "High Risk":
            return .red
        default:
            return .gray
        }
    }
    
    private var riskIcon: String {
        switch riskAssessment {
        case "Low Risk":
            return "checkmark.shield.fill"
        case "Moderate Risk":
            return "exclamationmark.shield.fill"
        case "High Risk":
            return "xmark.shield.fill"
        default:
            return "shield.fill"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Risk Level Display
                    VStack(spacing: 16) {
                        Image(systemName: riskIcon)
                            .font(.system(size: 60))
                            .foregroundColor(riskColor)
                        
                        Text(riskAssessment)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(riskColor)
                        
                        Text("Based on your assessment")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Risk Factors Summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Risk Factors")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            RiskFactorRow(
                                title: "Age",
                                value: "\(age) years",
                                riskLevel: getRiskLevel(for: "age")
                            )
                            
                            RiskFactorRow(
                                title: "Blood Pressure",
                                value: "\(bloodPressure) mmHg",
                                riskLevel: getRiskLevel(for: "bloodPressure")
                            )
                            
                            RiskFactorRow(
                                title: "Diabetes",
                                value: hasDiabetes ? "Yes" : "No",
                                riskLevel: hasDiabetes ? .high : .low
                            )
                            
                            RiskFactorRow(
                                title: "Smoking Status",
                                value: smokingStatus,
                                riskLevel: getRiskLevel(for: "smoking")
                            )
                            
                            RiskFactorRow(
                                title: "Cholesterol",
                                value: "\(cholesterolLevel) mg/dL",
                                riskLevel: getRiskLevel(for: "cholesterol")
                            )
                            
                            RiskFactorRow(
                                title: "Family History",
                                value: familyHistory ? "Yes" : "No",
                                riskLevel: familyHistory ? .moderate : .low
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Recommendations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommendations")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(getRecommendations(), id: \.self) { recommendation in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                        .padding(.top, 2)
                                    
                                    Text(recommendation)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Important Note
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Important Note")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Text("This assessment is for informational purposes only and should not replace professional medical advice. Please consult with your healthcare provider for personalized guidance and treatment recommendations.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            shareResults()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Results")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Done")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Risk Assessment Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getRiskLevel(for factor: String) -> RiskFactorLevel {
        switch factor {
        case "age":
            if let ageValue = Int(age) {
                if ageValue > 65 { return .high }
                else if ageValue > 45 { return .moderate }
                else { return .low }
            }
            return .low
            
        case "bloodPressure":
            if bloodPressure.contains("/") {
                let components = bloodPressure.split(separator: "/")
                if components.count == 2,
                   let systolic = Int(components[0]),
                   let diastolic = Int(components[1]) {
                    if systolic >= 140 || diastolic >= 90 { return .high }
                    else if systolic >= 130 || diastolic >= 80 { return .moderate }
                    else if systolic >= 120 { return .low }
                }
            }
            return .low
            
        case "smoking":
            if smokingStatus == "Current smoker" { return .high }
            else if smokingStatus == "Former smoker" { return .moderate }
            else { return .low }
            
        case "cholesterol":
            if let cholesterol = Int(cholesterolLevel) {
                if cholesterol >= 240 { return .high }
                else if cholesterol >= 200 { return .moderate }
                else { return .low }
            }
            return .low
            
        default:
            return .low
        }
    }
    
    private func getRecommendations() -> [String] {
        var recommendations: [String] = []
        
        // Universal recommendations
        recommendations.append("Maintain a heart-healthy diet rich in fruits, vegetables, and whole grains")
        recommendations.append("Engage in regular physical activity (150 minutes per week)")
        
        // Risk-specific recommendations
        switch riskAssessment {
        case "High Risk":
            recommendations.append("Schedule an immediate consultation with a cardiologist")
            recommendations.append("Consider medication management for blood pressure and cholesterol")
            recommendations.append("Monitor blood pressure and cholesterol levels regularly")
            
        case "Moderate Risk":
            recommendations.append("Schedule a check-up with your healthcare provider")
            recommendations.append("Monitor your blood pressure and cholesterol levels")
            recommendations.append("Consider lifestyle modifications to reduce risk factors")
            
        case "Low Risk":
            recommendations.append("Continue maintaining your current healthy lifestyle")
            recommendations.append("Schedule regular health screenings")
            
        default:
            recommendations.append("Consult with your healthcare provider for personalized recommendations")
        }
        
        // Factor-specific recommendations
        if hasDiabetes {
            recommendations.append("Maintain optimal blood sugar control")
        }
        
        if smokingStatus == "Current smoker" {
            recommendations.append("Quit smoking - consider nicotine replacement therapy or counseling")
        }
        
        if let cholesterol = Int(cholesterolLevel), cholesterol >= 200 {
            recommendations.append("Work on reducing cholesterol through diet and exercise")
        }
        
        return recommendations
    }
    
    private func shareResults() {
        let shareText = """
        Heart Risk Assessment Results
        
        Risk Level: \(riskAssessment)
        
        Risk Factors:
        • Age: \(age) years
        • Blood Pressure: \(bloodPressure) mmHg
        • Diabetes: \(hasDiabetes ? "Yes" : "No")
        • Smoking: \(smokingStatus)
        • Cholesterol: \(cholesterolLevel) mg/dL
        • Family History: \(familyHistory ? "Yes" : "No")
        
        Generated by FitPal Health App
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

struct RiskFactorRow: View {
    let title: String
    let value: String
    let riskLevel: RiskFactorLevel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Circle()
                    .fill(riskLevel.color)
                    .frame(width: 8, height: 8)
                
                Text(riskLevel.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(riskLevel.color)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

enum RiskFactorLevel {
    case low, moderate, high
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .moderate:
            return .orange
        case .high:
            return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .moderate:
            return "Moderate"
        case .high:
            return "High"
        }
    }
}

#Preview {
    HeartRiskResultsView(
        riskAssessment: "Moderate Risk",
        bloodPressure: "130/85",
        age: "45",
        hasDiabetes: false,
        smokingStatus: "Former smoker",
        cholesterolLevel: "210",
        familyHistory: true
    )
}
