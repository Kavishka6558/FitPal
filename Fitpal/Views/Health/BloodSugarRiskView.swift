import SwiftUI

struct BloodSugarRiskView: View {
    @State private var fastingGlucose: String = ""
    @State private var randomGlucose: String = ""
    @State private var a1c: String = ""
    @State private var age: String = ""
    @State private var hasHighBP = false
    @State private var hasHighCholesterol = false
    @State private var familyHistory = false
    @State private var physicallyActive = false
    @State private var overweight = false
    @State private var showResults = false
    @State private var diabetesRisk = DiabetesRisk(level: "Unknown", score: 0, explanation: "", recommendations: [])
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Blood Sugar Risk Assessment")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("This tool helps identify your risk for pre-diabetes or type 2 diabetes based on blood glucose levels and risk factors.")
                    .foregroundColor(.secondary)
                
                GroupBox(label: Text("Blood Glucose Values")
                    .font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Fasting Blood Glucose")
                            TextField("mg/dL", text: $fastingGlucose)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            Text("Measured after at least 8 hours of fasting")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Random Blood Glucose (Optional)")
                            TextField("mg/dL", text: $randomGlucose)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            Text("Measured at any time of day")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("HbA1c (Optional)")
                            TextField("%", text: $a1c)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            Text("Hemoglobin A1c percentage")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 5)
                }
                
                GroupBox(label: Text("Risk Factors")
                    .font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Age")
                            TextField("Years", text: $age)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        Toggle("High Blood Pressure", isOn: $hasHighBP)
                            .padding(.vertical, 5)
                        
                        Toggle("High Cholesterol", isOn: $hasHighCholesterol)
                            .padding(.vertical, 5)
                        
                        Toggle("Family History of Diabetes", isOn: $familyHistory)
                            .padding(.vertical, 5)
                        
                        Toggle("Physically Active (30+ min daily)", isOn: $physicallyActive)
                            .padding(.vertical, 5)
                        
                        Toggle("Overweight or Obese", isOn: $overweight)
                            .padding(.vertical, 5)
                    }
                    .padding(.horizontal, 5)
                }
                
                Button(action: calculateRisk) {
                    Text("Check Risk")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.vertical)
                
                if showResults {
                    GroupBox(label: Text("Your Results")
                        .font(.headline)) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Risk Level:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(diabetesRisk.level)
                                    .fontWeight(.bold)
                                    .foregroundColor(riskColor(level: diabetesRisk.level))
                            }
                            .padding(.vertical, 5)
                            
                            Text(diabetesRisk.explanation)
                                .padding(.vertical, 5)
                            
                            Text("Recommendations:")
                                .fontWeight(.medium)
                                .padding(.top, 10)
                            
                            ForEach(diabetesRisk.recommendations, id: \.self) { recommendation in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .padding(.top, 2)
                                    Text(recommendation)
                                }
                                .padding(.vertical, 3)
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Blood Sugar Risk")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func calculateRisk() {
        guard let fastingValue = Double(fastingGlucose),
              let ageValue = Int(age) else {
            return
        }
        
        var riskLevel = ""
        var riskScore = 0
        var explanation = ""
        var recommendations = [String]()
        
        // Assess glucose levels
        if fastingValue < 100 {
            riskLevel = "Low"
            explanation = "Your fasting glucose is within the normal range."
            riskScore += 0
        } else if fastingValue >= 100 && fastingValue <= 125 {
            riskLevel = "Moderate"
            explanation = "Your fasting glucose is in the pre-diabetes range."
            riskScore += 5
        } else {
            riskLevel = "High"
            explanation = "Your fasting glucose is in the diabetes range."
            riskScore += 10
        }
        
        // Check A1c if provided
        if let a1cValue = Double(a1c) {
            if a1cValue < 5.7 {
                explanation += " Your HbA1c is normal."
            } else if a1cValue >= 5.7 && a1cValue < 6.5 {
                explanation += " Your HbA1c indicates pre-diabetes."
                riskScore += 5
                if riskLevel == "Low" { riskLevel = "Moderate" }
            } else {
                explanation += " Your HbA1c is in the diabetes range."
                riskScore += 10
                riskLevel = "High"
            }
        }
        
        // Assess risk factors
        var riskFactors = 0
        
        if ageValue > 45 { riskFactors += 1 }
        if hasHighBP { riskFactors += 1 }
        if hasHighCholesterol { riskFactors += 1 }
        if familyHistory { riskFactors += 1 }
        if !physicallyActive { riskFactors += 1 }
        if overweight { riskFactors += 1 }
        
        // Adjust risk based on risk factors
        if riskFactors >= 3 && riskLevel == "Low" {
            riskLevel = "Moderate"
            explanation += " You have multiple risk factors for developing diabetes."
        } else if riskFactors >= 4 && riskLevel == "Moderate" {
            riskLevel = "High"
            explanation += " You have significant risk factors for developing diabetes."
        }
        
        // Generate recommendations
        recommendations.append("Monitor your blood glucose regularly")
        
        if hasHighBP || hasHighCholesterol {
            recommendations.append("Work with your healthcare provider to control blood pressure and cholesterol")
        }
        
        if !physicallyActive {
            recommendations.append("Aim for at least 30 minutes of moderate physical activity daily")
        }
        
        if overweight {
            recommendations.append("Focus on achieving and maintaining a healthy weight")
        }
        
        if riskLevel == "Moderate" || riskLevel == "High" {
            recommendations.append("Schedule a follow-up appointment with your healthcare provider")
            recommendations.append("Consider consulting with a registered dietitian")
        }
        
        if riskLevel == "High" {
            recommendations.append("Discuss diabetes screening and prevention strategies with your doctor")
        }
        
        // Set result
        diabetesRisk = DiabetesRisk(
            level: riskLevel,
            score: riskScore,
            explanation: explanation,
            recommendations: recommendations
        )
        
        showResults = true
    }
    
    private func riskColor(level: String) -> Color {
        switch level {
        case "Low":
            return .green
        case "Moderate":
            return .orange
        case "High":
            return .red
        default:
            return .gray
        }
    }
}

struct DiabetesRisk {
    let level: String
    let score: Int
    let explanation: String
    let recommendations: [String]
}

#Preview {
    BloodSugarRiskView()
}
