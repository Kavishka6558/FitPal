import SwiftUI
import Foundation

struct HeartRiskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bloodPressure = ""
    @State private var hasDiabetes: Bool? = nil
    @State private var smokingStatus = ""
    @State private var age = ""
    @State private var cholesterolLevel = ""
    @State private var familyHistory: Bool? = nil
    @State private var isLoading = false
    @State private var showingResults = false
    @State private var riskAssessment = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Heart Risk Assessment")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Complete the questionnaire to assess your cardiovascular risk")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 20) {
                        // Blood Pressure Level
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What is your blood pressure level")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("Enter systolic/diastolic (e.g., 120/80)", text: $bloodPressure)
                                .textFieldStyle(HeartRiskTextFieldStyle())
                                .keyboardType(.numbersAndPunctuation)
                        }
                        
                        // Age
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What is your age")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("Enter your age", text: $age)
                                .textFieldStyle(HeartRiskTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        // Diabetes Question
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Do you have Diabetes")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    hasDiabetes = true
                                }) {
                                    Text("Yes")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(hasDiabetes == true ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(hasDiabetes == true ? Color.blue : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(hasDiabetes == true ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    hasDiabetes = false
                                }) {
                                    Text("No")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(hasDiabetes == false ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(hasDiabetes == false ? Color.blue : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(hasDiabetes == false ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Smoking Status
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What is your smoking status")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 8) {
                                ForEach(["Never smoked", "Former smoker", "Current smoker"], id: \.self) { option in
                                    Button(action: {
                                        smokingStatus = option
                                    }) {
                                        HStack {
                                            Text(option)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            if smokingStatus == option {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.title3)
                                            } else {
                                                Circle()
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                                    .frame(width: 20, height: 20)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(smokingStatus == option ? Color.blue.opacity(0.05) : Color(UIColor.systemGray6))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(smokingStatus == option ? Color.blue : Color.clear, lineWidth: 1)
                                                )
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // Cholesterol Level
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What is your cholesterol level")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("Enter total cholesterol (mg/dL)", text: $cholesterolLevel)
                                .textFieldStyle(HeartRiskTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        // Family History
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Family history of heart disease")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    familyHistory = true
                                }) {
                                    Text("Yes")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(familyHistory == true ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(familyHistory == true ? Color.blue : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(familyHistory == true ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    familyHistory = false
                                }) {
                                    Text("No")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(familyHistory == false ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(familyHistory == false ? Color.blue : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(familyHistory == false ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Submit Button
                    Button(action: {
                        calculateRisk()
                    }) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Calculating...")
                                    .fontWeight(.semibold)
                            }
                        } else {
                            Text("Submit")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isFormValid ? Color.blue : Color.gray.opacity(0.3))
                    )
                    .foregroundColor(.white)
                    .disabled(!isFormValid || isLoading)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Heart Risk Checker")
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
            }
            .sheet(isPresented: $showingResults) {
                HeartRiskResultsView(
                    riskAssessment: riskAssessment,
                    bloodPressure: bloodPressure,
                    age: age,
                    hasDiabetes: hasDiabetes ?? false,
                    smokingStatus: smokingStatus,
                    cholesterolLevel: cholesterolLevel,
                    familyHistory: familyHistory ?? false
                )
            }
        }
    }
    
    private var isFormValid: Bool {
        !bloodPressure.isEmpty &&
        !age.isEmpty &&
        hasDiabetes != nil &&
        !smokingStatus.isEmpty &&
        !cholesterolLevel.isEmpty &&
        familyHistory != nil
    }
    
    private func calculateRisk() {
        isLoading = true
        
        // Simulate API call or calculation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let risk = assessHeartRisk()
            riskAssessment = risk
            isLoading = false
            showingResults = true
        }
    }
    
    private func assessHeartRisk() -> String {
        var riskScore = 0
        
        // Age factor
        if let ageValue = Int(age) {
            if ageValue > 65 { riskScore += 3 }
            else if ageValue > 45 { riskScore += 2 }
            else if ageValue > 35 { riskScore += 1 }
        }
        
        // Blood pressure factor
        if bloodPressure.contains("/") {
            let components = bloodPressure.split(separator: "/")
            if components.count == 2,
               let systolic = Int(components[0]),
               let diastolic = Int(components[1]) {
                if systolic >= 140 || diastolic >= 90 { riskScore += 3 }
                else if systolic >= 130 || diastolic >= 80 { riskScore += 2 }
                else if systolic >= 120 { riskScore += 1 }
            }
        }
        
        // Diabetes factor
        if hasDiabetes == true { riskScore += 3 }
        
        // Smoking factor
        if smokingStatus == "Current smoker" { riskScore += 3 }
        else if smokingStatus == "Former smoker" { riskScore += 1 }
        
        // Cholesterol factor
        if let cholesterol = Int(cholesterolLevel) {
            if cholesterol >= 240 { riskScore += 3 }
            else if cholesterol >= 200 { riskScore += 2 }
        }
        
        // Family history factor
        if familyHistory == true { riskScore += 2 }
        
        // Determine risk level
        if riskScore <= 3 {
            return "Low Risk"
        } else if riskScore <= 7 {
            return "Moderate Risk"
        } else {
            return "High Risk"
        }
    }
}

struct HeartRiskTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.systemGray6))
            )
    }
}

#Preview {
    HeartRiskView()
}
