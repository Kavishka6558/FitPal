import SwiftUI

struct BMICalculatorSimpleView: View {
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var bmi: Double = 0.0
    @State private var bmiCategory: String = ""
    @State private var showResult: Bool = false
    @State private var useMetric: Bool = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Body Weight Checker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("Calculate your Body Mass Index (BMI) to assess if you're in a healthy weight range.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    
                    // Unit Toggle
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Units")
                            .font(.headline)
                        
                        Picker("Units", selection: $useMetric) {
                            Text("Metric (cm, kg)").tag(true)
                            Text("Imperial (ft/in, lbs)").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.bottom)
                    
                    // Input Fields
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(useMetric ? "Height (cm)" : "Height (ft)")
                                .font(.headline)
                            TextField(useMetric ? "e.g., 170" : "e.g., 5.8", text: $height)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(useMetric ? "Weight (kg)" : "Weight (lbs)")
                                .font(.headline)
                            TextField(useMetric ? "e.g., 70" : "e.g., 154", text: $weight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
                    .padding(.bottom)
                    
                    // Calculate Button
                    Button(action: calculateBMI) {
                        Text("Calculate BMI")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)
                    
                    // Results
                    if showResult {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Results")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack {
                                Text("BMI:")
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "%.1f", bmi))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Text("Category:")
                                    .font(.headline)
                                Spacer()
                                Text(bmiCategory)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(categoryColor(for: bmiCategory))
                            }
                            
                            // BMI Categories Reference
                            VStack(alignment: .leading, spacing: 8) {
                                Text("BMI Categories:")
                                    .font(.headline)
                                    .padding(.top)
                                
                                HStack {
                                    Text("Underweight")
                                    Spacer()
                                    Text("< 18.5")
                                }
                                .foregroundColor(.blue)
                                
                                HStack {
                                    Text("Normal weight")
                                    Spacer()
                                    Text("18.5 - 24.9")
                                }
                                .foregroundColor(.green)
                                
                                HStack {
                                    Text("Overweight")
                                    Spacer()
                                    Text("25.0 - 29.9")
                                }
                                .foregroundColor(.orange)
                                
                                HStack {
                                    Text("Obese")
                                    Spacer()
                                    Text("≥ 30.0")
                                }
                                .foregroundColor(.red)
                            }
                            .font(.subheadline)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("BMI Calculator")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func calculateBMI() {
        guard let heightValue = Double(height),
              let weightValue = Double(weight),
              heightValue > 0, weightValue > 0 else {
            return
        }
        
        var heightInMeters: Double
        var weightInKg: Double
        
        if useMetric {
            heightInMeters = heightValue / 100 // Convert cm to meters
            weightInKg = weightValue
        } else {
            heightInMeters = heightValue * 0.3048 // Convert feet to meters
            weightInKg = weightValue * 0.453592 // Convert lbs to kg
        }
        
        bmi = weightInKg / (heightInMeters * heightInMeters)
        bmiCategory = getBMICategory(bmi: bmi)
        showResult = true
    }
    
    private func getBMICategory(bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal weight"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Underweight":
            return .blue
        case "Normal weight":
            return .green
        case "Overweight":
            return .orange
        case "Obese":
            return .red
        default:
            return .black
        }
    }
}

#Preview {
    BMICalculatorSimpleView()
}
