import SwiftUI

struct HeartRiskCheckerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var age = ""
    @State private var systolicBP = ""
    @State private var diastolicBP = ""
    @State private var cholesterol = ""
    @State private var hdl = ""
    @State private var smoker = false
    @State private var diabetic = false
    @State private var takingBPMeds = false
    @State private var gender = "Male"
    @State private var riskScore: Double = 0
    @State private var showResults = false
    
    let genderOptions = ["Male", "Female"]
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemRed).opacity(0.08),
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
                    Text("Heart Risk Checker")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Health Assessment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.title3)
                            .foregroundStyle(.red.gradient)
                    )
            }
            
            VStack(spacing: 8) {
                Text("Cardiovascular Risk Assessment")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Calculate your 10-year risk of heart disease using the Framingham Risk Score methodology.")
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
                
                    // Personal Information Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Circle()
                                .fill(.purple.opacity(0.15))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.purple)
                                )
                            
                            Text("Personal Information")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            // Gender Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gender")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Picker("Gender", selection: $gender) {
                                    ForEach(genderOptions, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
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
                                    title: "Smoker",
                                    subtitle: "Current or recent tobacco use",
                                    icon: "smoke.fill",
                                    iconColor: .gray,
                                    isOn: $smoker
                                )
                                
                                ModernToggleCard(
                                    title: "Diabetic",
                                    subtitle: "Diagnosed with diabetes",
                                    icon: "cross.fill",
                                    iconColor: .red,
                                    isOn: $diabetic
                                )
                                
                                ModernToggleCard(
                                    title: "Taking BP Medication",
                                    subtitle: "Currently on blood pressure medication",
                                    icon: "pills.fill",
                                    iconColor: .blue,
                                    isOn: $takingBPMeds
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
                
                    // Blood Pressure Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Circle()
                                .fill(.red.opacity(0.15))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "heart.text.square.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.red)
                                )
                            
                            Text("Blood Pressure")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Systolic Blood Pressure",
                                subtitle: "Top number in blood pressure reading",
                                placeholder: "mmHg",
                                text: $systolicBP,
                                keyboardType: .numberPad,
                                required: true
                            )
                            
                            ModernInputField(
                                title: "Diastolic Blood Pressure",
                                subtitle: "Bottom number in blood pressure reading",
                                placeholder: "mmHg",
                                text: $diastolicBP,
                                keyboardType: .numberPad,
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
                
                    // Cholesterol Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Circle()
                                .fill(.green.opacity(0.15))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "drop.triangle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.green)
                                )
                            
                            Text("Cholesterol Levels")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Total Cholesterol",
                                subtitle: "Overall cholesterol level in blood",
                                placeholder: "mg/dL",
                                text: $cholesterol,
                                keyboardType: .numberPad,
                                required: true
                            )
                            
                            ModernInputField(
                                title: "HDL Cholesterol",
                                subtitle: "High-density lipoprotein (good cholesterol)",
                                placeholder: "mg/dL",
                                text: $hdl,
                                keyboardType: .numberPad,
                                required: true
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
                
                    // Assessment Button
                    Button(action: calculateRisk) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "heart.text.square")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Calculate Heart Risk")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Get your Framingham Risk Score")
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
                                colors: [.red, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.red.opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                
                    if showResults {
                        // Results Section
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Circle()
                                    .fill(riskColor(score: riskScore).opacity(0.15))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "chart.bar.doc.horizontal.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(riskColor(score: riskScore))
                                    )
                                
                                Text("Risk Assessment Results")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            // Risk Score Display
                            VStack(spacing: 20) {
                                VStack(spacing: 12) {
                                    Text("10-Year Cardiovascular Risk")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Circle()
                                            .fill(riskColor(score: riskScore).opacity(0.2))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                VStack(spacing: 4) {
                                                    Text("\(Int(riskScore))")
                                                        .font(.system(size: 36, weight: .bold))
                                                        .foregroundColor(riskColor(score: riskScore))
                                                    Text("%")
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(riskColor(score: riskScore))
                                                }
                                            )
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 8) {
                                            Text(riskLevel(score: riskScore))
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(riskColor(score: riskScore))
                                            
                                            Image(systemName: riskIcon(score: riskScore))
                                                .font(.title)
                                                .foregroundColor(riskColor(score: riskScore))
                                        }
                                    }
                                }
                                .padding(20)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(riskColor(score: riskScore).opacity(0.3), lineWidth: 1)
                                )
                                
                                // Risk Interpretation
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Risk Interpretation")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(riskInterpretation(score: riskScore))
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .lineSpacing(4)
                                }
                                .padding(20)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                                
                                // Recommendations
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recommendations")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(recommendationText(score: riskScore))
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .lineSpacing(4)
                                }
                                .padding(20)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
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
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func calculateRisk() {
        guard let ageValue = Int(age),
              let systolicValue = Int(systolicBP),
              let cholesterolValue = Int(cholesterol),
              let hdlValue = Int(hdl) else {
            return
        }
        
        // Simplified version of Framingham Risk Score calculation
        var score = 0.0
        
        // Age factor
        if gender == "Male" {
            if ageValue >= 20 && ageValue <= 34 { score += 0 }
            else if ageValue >= 35 && ageValue <= 39 { score += 2 }
            else if ageValue >= 40 && ageValue <= 44 { score += 5 }
            else if ageValue >= 45 && ageValue <= 49 { score += 7 }
            else if ageValue >= 50 && ageValue <= 54 { score += 8 }
            else if ageValue >= 55 && ageValue <= 59 { score += 10 }
            else if ageValue >= 60 && ageValue <= 64 { score += 11 }
            else if ageValue >= 65 && ageValue <= 69 { score += 12 }
            else if ageValue >= 70 && ageValue <= 74 { score += 14 }
            else if ageValue >= 75 { score += 15 }
        } else {
            if ageValue >= 20 && ageValue <= 34 { score += 0 }
            else if ageValue >= 35 && ageValue <= 39 { score += 2 }
            else if ageValue >= 40 && ageValue <= 44 { score += 4 }
            else if ageValue >= 45 && ageValue <= 49 { score += 5 }
            else if ageValue >= 50 && ageValue <= 54 { score += 7 }
            else if ageValue >= 55 && ageValue <= 59 { score += 8 }
            else if ageValue >= 60 && ageValue <= 64 { score += 9 }
            else if ageValue >= 65 && ageValue <= 69 { score += 10 }
            else if ageValue >= 70 && ageValue <= 74 { score += 11 }
            else if ageValue >= 75 { score += 12 }
        }
        
        // Blood pressure factor
        if takingBPMeds {
            score += 2
        }
        
        if systolicValue < 120 { score += 0 }
        else if systolicValue >= 120 && systolicValue <= 129 { score += 1 }
        else if systolicValue >= 130 && systolicValue <= 139 { score += 2 }
        else if systolicValue >= 140 && systolicValue <= 159 { score += 3 }
        else if systolicValue >= 160 { score += 4 }
        
        // Cholesterol factor
        if cholesterolValue < 160 { score += 0 }
        else if cholesterolValue >= 160 && cholesterolValue <= 199 { score += 1 }
        else if cholesterolValue >= 200 && cholesterolValue <= 239 { score += 2 }
        else if cholesterolValue >= 240 && cholesterolValue <= 279 { score += 3 }
        else if cholesterolValue >= 280 { score += 4 }
        
        // HDL factor
        if hdlValue >= 60 { score -= 1 }
        else if hdlValue >= 50 && hdlValue < 60 { score += 0 }
        else if hdlValue >= 40 && hdlValue < 50 { score += 1 }
        else if hdlValue < 40 { score += 2 }
        
        // Smoking factor
        if smoker { score += 3 }
        
        // Diabetes factor
        if diabetic { score += 4 }
        
        // Convert score to percentage risk
        riskScore = min(max(score, 1), 30) // Limit between 1% and 30%
        showResults = true
    }
    
    private func riskColor(score: Double) -> Color {
        if score < 10 { return .green }
        else if score < 20 { return .orange }
        else { return .red }
    }
    
    private func riskLevel(score: Double) -> String {
        if score < 10 { return "Low Risk" }
        else if score < 20 { return "Moderate Risk" }
        else { return "High Risk" }
    }
    
    private func riskIcon(score: Double) -> String {
        if score < 10 { return "checkmark.shield.fill" }
        else if score < 20 { return "exclamationmark.triangle.fill" }
        else { return "xmark.octagon.fill" }
    }
    
    private func riskInterpretation(score: Double) -> String {
        if score < 10 {
            return "Low Risk: You have a low risk of developing cardiovascular disease in the next 10 years."
        } else if score < 20 {
            return "Moderate Risk: You have a moderate risk of developing cardiovascular disease in the next 10 years."
        } else {
            return "High Risk: You have a high risk of developing cardiovascular disease in the next 10 years."
        }
    }
    
    private func recommendationText(score: Double) -> String {
        if score < 10 {
            return "Maintain a healthy lifestyle with regular exercise and a balanced diet. Continue monitoring your blood pressure and cholesterol levels annually."
        } else if score < 20 {
            return "Consider lifestyle changes like increased physical activity, improved diet, and smoking cessation if applicable. Discuss with your doctor about regular monitoring."
        } else {
            return "Consult with your healthcare provider as soon as possible to discuss risk management strategies, which may include lifestyle changes and/or medication."
        }
    }
}

#Preview {
    HeartRiskCheckerView()
}
