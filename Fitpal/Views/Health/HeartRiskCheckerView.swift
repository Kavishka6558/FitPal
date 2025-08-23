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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Heart Risk Assessment")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("This tool estimates your 10-year risk of heart disease based on the Framingham Risk Score.")
                    .foregroundColor(.secondary)
                
                GroupBox(label: Text("Personal Information")
                    .font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Gender", selection: $gender) {
                            ForEach(genderOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 5)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Age")
                            TextField("Years", text: $age)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        Toggle("Smoker", isOn: $smoker)
                            .padding(.vertical, 5)
                        
                        Toggle("Diabetic", isOn: $diabetic)
                            .padding(.vertical, 5)
                        
                        Toggle("Taking BP Medication", isOn: $takingBPMeds)
                            .padding(.vertical, 5)
                    }
                    .padding(.horizontal, 5)
                }
                
                GroupBox(label: Text("Blood Pressure")
                    .font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Systolic Blood Pressure")
                            TextField("mmHg", text: $systolicBP)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Diastolic Blood Pressure")
                            TextField("mmHg", text: $diastolicBP)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 5)
                }
                
                GroupBox(label: Text("Cholesterol")
                    .font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Total Cholesterol")
                            TextField("mg/dL", text: $cholesterol)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("HDL Cholesterol")
                            TextField("mg/dL", text: $hdl)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 5)
                }
                
                Button(action: calculateRisk) {
                    Text("Calculate Risk")
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
                            Text("Your 10-year cardiovascular risk:")
                                .fontWeight(.medium)
                            
                            Text("\(Int(riskScore))%")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(riskColor(score: riskScore))
                                .frame(maxWidth: .infinity)
                                .padding()
                            
                            Text(riskInterpretation(score: riskScore))
                                .font(.body)
                                .lineSpacing(4)
                                .padding(.vertical)
                            
                            Text("Next Steps")
                                .font(.headline)
                                .padding(.top)
                            
                            Text(recommendationText(score: riskScore))
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 5)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Heart Risk Checker")
        .navigationBarTitleDisplayMode(.inline)
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
