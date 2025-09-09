import SwiftUI

struct BloodSugarRiskView: View {
    @Environment(\.dismiss) private var dismiss
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
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemBlue).opacity(0.08),
                Color(.systemPink).opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("Blood Sugar Risk")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Health Assessment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "drop.fill")
                            .font(.title3)
                            .foregroundStyle(.blue.gradient)
                    )
            }
            
            VStack(spacing: 8) {
                Text("Diabetes Risk Assessment")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Evaluate your risk for pre-diabetes or type 2 diabetes based on glucose levels and lifestyle factors.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    headerView
                
                    // Blood Glucose Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Circle()
                                .fill(.blue.opacity(0.15))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                )
                            
                            Text("Blood Glucose Values")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Fasting Blood Glucose",
                                subtitle: "Measured after at least 8 hours of fasting",
                                placeholder: "mg/dL",
                                text: $fastingGlucose,
                                keyboardType: .numberPad,
                                required: true
                            )
                            
                            ModernInputField(
                                title: "Random Blood Glucose",
                                subtitle: "Measured at any time of day (optional)",
                                placeholder: "mg/dL",
                                text: $randomGlucose,
                                keyboardType: .numberPad,
                                required: false
                            )
                            
                            ModernInputField(
                                title: "HbA1c",
                                subtitle: "Hemoglobin A1c percentage (optional)",
                                placeholder: "%",
                                text: $a1c,
                                keyboardType: .decimalPad,
                                required: false
                            )
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                    // Risk Factors Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Circle()
                                .fill(.orange.opacity(0.15))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.orange)
                                )
                            
                            Text("Risk Factors")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Age",
                                subtitle: "Your current age in years",
                                placeholder: "Years",
                                text: $age,
                                keyboardType: .numberPad,
                                required: true
                            )
                            
                            VStack(spacing: 12) {
                                ModernToggleCard(
                                    title: "High Blood Pressure",
                                    subtitle: "Diagnosed with hypertension",
                                    icon: "heart.fill",
                                    iconColor: .red,
                                    isOn: $hasHighBP
                                )
                                
                                ModernToggleCard(
                                    title: "High Cholesterol",
                                    subtitle: "Elevated cholesterol levels",
                                    icon: "pills.fill",
                                    iconColor: .orange,
                                    isOn: $hasHighCholesterol
                                )
                                
                                ModernToggleCard(
                                    title: "Family History of Diabetes",
                                    subtitle: "Parent or sibling with diabetes",
                                    icon: "person.2.fill",
                                    iconColor: .purple,
                                    isOn: $familyHistory
                                )
                                
                                ModernToggleCard(
                                    title: "Physically Active",
                                    subtitle: "30+ minutes daily exercise",
                                    icon: "figure.walk",
                                    iconColor: .green,
                                    isOn: $physicallyActive
                                )
                                
                                ModernToggleCard(
                                    title: "Overweight or Obese",
                                    subtitle: "BMI over 25",
                                    icon: "scalemass.fill",
                                    iconColor: .blue,
                                    isOn: $overweight
                                )
                            }
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                    // Assessment Button
                    Button(action: calculateRisk) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Assess Risk Level")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Get personalized recommendations")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                
                    if showResults {
                        // Results Section
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Circle()
                                    .fill(riskColor(level: diabetesRisk.level).opacity(0.15))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "chart.bar.doc.horizontal.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(riskColor(level: diabetesRisk.level))
                                    )
                                
                                Text("Assessment Results")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            // Risk Level Card
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Risk Level")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text(diabetesRisk.level)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(riskColor(level: diabetesRisk.level))
                                    }
                                    
                                    Spacer()
                                    
                                    Circle()
                                        .fill(riskColor(level: diabetesRisk.level).opacity(0.2))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: riskIcon(level: diabetesRisk.level))
                                                .font(.title2)
                                                .foregroundColor(riskColor(level: diabetesRisk.level))
                                        )
                                }
                                
                                Text(diabetesRisk.explanation)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(riskColor(level: diabetesRisk.level).opacity(0.3), lineWidth: 1)
                            )
                            
                            // Recommendations
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recommendations")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                ForEach(diabetesRisk.recommendations, id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 12) {
                                        Circle()
                                            .fill(.green.opacity(0.2))
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.green)
                                            )
                                        
                                        Text(recommendation)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
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
    
    private func riskIcon(level: String) -> String {
        switch level {
        case "Low":
            return "checkmark.shield.fill"
        case "Moderate":
            return "exclamationmark.triangle.fill"
        case "High":
            return "xmark.octagon.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
}

struct DiabetesRisk {
    let level: String
    let score: Int
    let explanation: String
    let recommendations: [String]
}

struct ModernInputField: View {
    let title: String
    let subtitle: String
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let required: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if required {
                    Text("*")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ModernToggleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isOn ? iconColor.opacity(0.3) : .white.opacity(0.2), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isOn)
    }
}

#Preview {
    BloodSugarRiskView()
}
