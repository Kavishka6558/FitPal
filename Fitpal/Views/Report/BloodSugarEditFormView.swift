import SwiftUI

struct BloodSugarEditFormView: View {
    let reading: BloodSugarReading
    @ObservedObject var service: BloodSugarService
    @Environment(\.dismiss) private var dismiss
    
    @State private var glucoseLevel: String
    @State private var selectedReadingType: BloodSugarType
    @State private var selectedDate: Date
    @State private var notes: String
    @State private var showingDatePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    init(reading: BloodSugarReading, service: BloodSugarService) {
        self.reading = reading
        self.service = service
        
        // Initialize state from existing reading
        _glucoseLevel = State(initialValue: "\(Int(reading.glucoseLevel))")
        _selectedReadingType = State(initialValue: reading.readingType)
        _selectedDate = State(initialValue: reading.date)
        _notes = State(initialValue: reading.notes ?? "")
    }
    
    private var isValidGlucose: Bool {
        guard let level = Double(glucoseLevel),
              level >= 20 && level <= 600 else {
            return false
        }
        return true
    }
    
    private var hasChanges: Bool {
        guard let level = Double(glucoseLevel) else { return false }
        
        return level != reading.glucoseLevel ||
               selectedReadingType != reading.readingType ||
               !Calendar.current.isDate(selectedDate, equalTo: reading.date, toGranularity: .minute) ||
               notes != (reading.notes ?? "")
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
                        Text("Edit Blood Sugar Reading")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Update your glucose level reading")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
                                Text("Updated Risk Assessment")
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
                        
                        // Changes Summary
                        if hasChanges {
                            ChangesSummaryCard(
                                originalReading: reading,
                                newGlucose: Double(glucoseLevel) ?? reading.glucoseLevel,
                                newType: selectedReadingType,
                                newDate: selectedDate,
                                newNotes: notes
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Edit Reading")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValidGlucose || !hasChanges || isLoading)
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
                    LoadingOverlay(message: "Updating Reading...")
                }
            }
        }
    }
    
    private func saveChanges() {
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
        
        guard hasChanges else {
            dismiss()
            return
        }
        
        isLoading = true
        
        // Simulate network delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let updatedReading = BloodSugarReading(
                id: reading.id,
                date: selectedDate,
                glucoseLevel: level,
                readingType: selectedReadingType,
                notes: notes.isEmpty ? nil : notes,
                medication: reading.medication,
                symptoms: reading.symptoms,
                mealTiming: reading.mealTiming
            )
            
            service.updateReading(updatedReading)
            isLoading = false
            dismiss()
        }
    }
}

struct ChangesSummaryCard: View {
    let originalReading: BloodSugarReading
    let newGlucose: Double
    let newType: BloodSugarType
    let newDate: Date
    let newNotes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Changes Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Glucose Level Change
                if newGlucose != originalReading.glucoseLevel {
                    ChangeItem(
                        title: "Glucose Level",
                        oldValue: "\(Int(originalReading.glucoseLevel)) mg/dL",
                        newValue: "\(Int(newGlucose)) mg/dL"
                    )
                }
                
                // Reading Type Change
                if newType != originalReading.readingType {
                    ChangeItem(
                        title: "Reading Type",
                        oldValue: originalReading.readingType.displayName,
                        newValue: newType.displayName
                    )
                }
                
                // Date Change
                if !Calendar.current.isDate(newDate, equalTo: originalReading.date, toGranularity: .minute) {
                    ChangeItem(
                        title: "Date & Time",
                        oldValue: originalReading.date.formatted(date: .abbreviated, time: .shortened),
                        newValue: newDate.formatted(date: .abbreviated, time: .shortened)
                    )
                }
                
                // Notes Change
                if newNotes != (originalReading.notes ?? "") {
                    ChangeItem(
                        title: "Notes",
                        oldValue: originalReading.notes?.isEmpty == false ? originalReading.notes! : "No notes",
                        newValue: newNotes.isEmpty ? "No notes" : newNotes
                    )
                }
            }
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
    }
}

struct ChangeItem: View {
    let title: String
    let oldValue: String
    let newValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                // Old value
                Text(oldValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .strikethrough()
                
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.blue)
                
                // New value
                Text(newValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct LoadingOverlay: View {
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
            )
        }
    }
}

#Preview {
    BloodSugarEditFormView(
        reading: BloodSugarReading(
            date: Date(),
            glucoseLevel: 120,
            readingType: .fasting,
            notes: "Morning reading",
            medication: nil,
            symptoms: [],
            mealTiming: nil
        ),
        service: BloodSugarService()
    )
}
