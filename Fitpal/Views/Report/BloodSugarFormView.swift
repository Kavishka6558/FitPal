import SwiftUI

struct BloodSugarFormView: View {
    @ObservedObject var service: BloodSugarService
    @Environment(\.dismiss) private var dismiss
    
    @State private var glucoseLevel: String = ""
    @State private var selectedReadingType: BloodSugarType = .fasting
    @State private var selectedDate = Date()
    @State private var notes: String = ""
    @State private var showingDatePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    private var isValidGlucose: Bool {
        guard let level = Double(glucoseLevel),
              level >= 20 && level <= 600 else {
            return false
        }
        return true
    }
    
    private var calculatedRisk: RiskLevel {
        guard let level = Double(glucoseLevel) else { return .normal }
        let tempReading = BloodSugarReading(
            date: Date(),
            glucoseLevel: level,
            readingType: selectedReadingType,
            notes: nil,
            medication: nil,
            symptoms: [],
            mealTiming: nil
        )
        return tempReading.riskLevel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Add Blood Sugar Reading")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Track your glucose levels to monitor your health")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 20) {
                        // Glucose Level Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Glucose Level")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                TextField("Enter glucose level", text: $glucoseLevel)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .onChange(of: glucoseLevel) { _ in
                                        // Remove non-numeric characters except decimal point
                                        glucoseLevel = glucoseLevel.filter { $0.isNumber || $0 == "." }
                                    }
                                
                                Text("mg/dL")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                            }
                            
                            if !glucoseLevel.isEmpty && !isValidGlucose {
                                Text("Please enter a valid glucose level (20-600 mg/dL)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Reading Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reading Type")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 8) {
                                ForEach(BloodSugarType.allCases, id: \.self) { type in
                                    ReadingTypeCard(
                                        type: type,
                                        isSelected: selectedReadingType == type
                                    ) {
                                        selectedReadingType = type
                                    }
                                }
                            }
                        }
                        
                        // Date and Time Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Date & Time")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Button(action: {
                                showingDatePicker.toggle()
                            }) {
                                HStack {
                                    Text(selectedDate.formatted(date: .abbreviated, time: .shortened))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.systemGray6))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Risk Assessment Preview
                        if isValidGlucose {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Risk Assessment")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                RiskAssessmentCard(
                                    riskLevel: calculatedRisk,
                                    glucoseLevel: Double(glucoseLevel) ?? 0,
                                    readingType: selectedReadingType
                                )
                            }
                        }
                        
                        // Notes Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes (Optional)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("Add any relevant notes...", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Add Reading")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReading()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValidGlucose || isLoading)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(selectedDate: $selectedDate)
            }
            .alert("Validation Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .overlay {
                if isLoading {
                    LoadingOverlay(message: "Saving Reading...")
                }
            }
        }
    }
    
    private func saveReading() {
        guard isValidGlucose else {
            alertMessage = "Please enter a valid glucose level"
            showingAlert = true
            return
        }
        
        guard let level = Double(glucoseLevel) else {
            alertMessage = "Invalid glucose level format"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        // Simulate network delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let reading = BloodSugarReading(
                date: selectedDate,
                glucoseLevel: level,
                readingType: selectedReadingType,
                notes: notes.isEmpty ? nil : notes,
                medication: nil,
                symptoms: [],
                mealTiming: nil
            )
            
            service.addReading(reading)
            isLoading = false
            dismiss()
        }
    }
}

struct ReadingTypeCard: View {
    let type: BloodSugarType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.05) : Color(UIColor.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RiskAssessmentCard: View {
    let riskLevel: RiskLevel
    let glucoseLevel: Double
    let readingType: BloodSugarType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(riskLevel.color)
                    .frame(width: 16, height: 16)
                
                Text(riskLevel.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(riskLevel.color)
                
                Spacer()
                
                Text("\(Int(glucoseLevel)) mg/dL")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Text(getRiskDescription())
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if riskLevel == .preDiabetic || riskLevel == .diabetic {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    
                    Text("Consider consulting with your healthcare provider")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(riskLevel.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(riskLevel.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func getRiskDescription() -> String {
        switch (riskLevel, readingType) {
        case (.low, .fasting):
            return "Your fasting glucose is below normal range. Consider eating soon."
        case (.normal, .fasting):
            return "Your fasting glucose level is in the normal range."
        case (.preDiabetic, .fasting):
            return "Your fasting glucose indicates prediabetes. Lifestyle changes may help."
        case (.diabetic, .fasting):
            return "Your fasting glucose indicates diabetes. Medical consultation recommended."
        case (.low, .postMeal):
            return "Your post-meal glucose is unusually low."
        case (.normal, .postMeal):
            return "Your post-meal glucose level is normal."
        case (.preDiabetic, .postMeal):
            return "Your post-meal glucose is elevated. Monitor your diet."
        case (.diabetic, .postMeal):
            return "Your post-meal glucose is very high. Consider medical advice."
        default:
            return "Glucose level recorded for \(readingType.displayName.lowercased()) reading."
        }
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date and Time",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date & Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
            )
    }
}

#Preview {
    BloodSugarFormView(service: BloodSugarService())
}
