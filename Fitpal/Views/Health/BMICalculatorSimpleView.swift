import SwiftUI

struct BMICalculatorSimpleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var bmi: Double = 0.0
    @State private var bmiCategory: String = ""
    @State private var showResult: Bool = false
    @State private var useMetric: Bool = true
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemOrange).opacity(0.08),
                Color(.systemYellow).opacity(0.05),
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
                    Text("BMI Calculator")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Health Assessment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(.orange.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "figure.walk")
                            .font(.title3)
                            .foregroundStyle(.orange.gradient)
                    )
            }
            
            VStack(spacing: 8) {
                Text("Body Weight Assessment")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Calculate your Body Mass Index (BMI) to assess if you're in a healthy weight range for your height.")
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
                    
                    // Measurement Input Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Circle()
                                .fill(.orange.opacity(0.15))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "ruler.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.orange)
                                )
                            
                            Text("Measurements")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            // Unit Selection
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Units")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Picker("Units", selection: $useMetric) {
                                    Text("Metric (cm, kg)").tag(true)
                                    Text("Imperial (ft, lbs)").tag(false)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            ModernInputField(
                                title: useMetric ? "Height" : "Height",
                                subtitle: useMetric ? "Your height in centimeters" : "Your height in feet (e.g., 5.8 for 5'8\")",
                                placeholder: useMetric ? "e.g., 170" : "e.g., 5.8",
                                text: $height,
                                keyboardType: .decimalPad,
                                required: true
                            )
                            
                            ModernInputField(
                                title: useMetric ? "Weight" : "Weight",
                                subtitle: useMetric ? "Your weight in kilograms" : "Your weight in pounds",
                                placeholder: useMetric ? "e.g., 70" : "e.g., 154",
                                text: $weight,
                                keyboardType: .decimalPad,
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
                    
                    // Calculate Button
                    Button(action: calculateBMI) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "plus.forwardslash.minus")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Calculate BMI")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Get your body mass index")
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
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.orange.opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                    
                    // Results Display
                    if showResult {
                        VStack(spacing: 20) {
                            // Result Header
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(getBMIGradient(bmi))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "heart.text.square")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("BMI Result")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    Text("Body Mass Index")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            // BMI Value Display
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(String(format: "%.1f", bmi))")
                                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                                        .foregroundStyle(getBMIGradient(bmi))
                                    
                                    Text(bmiCategory)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundStyle(getBMIGradient(bmi))
                                }
                                
                                Spacer()
                            }
                            
                            // BMI Categories Reference
                            VStack(alignment: .leading, spacing: 12) {
                                Text("BMI Categories Reference")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                VStack(spacing: 8) {
                                    BMICategoryRow(category: "Underweight", range: "< 18.5", color: .blue, isHighlighted: bmiCategory == "Underweight")
                                    BMICategoryRow(category: "Normal weight", range: "18.5 - 24.9", color: .green, isHighlighted: bmiCategory == "Normal weight")
                                    BMICategoryRow(category: "Overweight", range: "25.0 - 29.9", color: .orange, isHighlighted: bmiCategory == "Overweight")
                                    BMICategoryRow(category: "Obese", range: "≥ 30.0", color: .red, isHighlighted: bmiCategory == "Obese")
                                }
                            }
                        }
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
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
    
    private func getBMIGradient(_ bmi: Double) -> LinearGradient {
        switch bmi {
        case ..<18.5:
            return LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
        case 18.5..<25:
            return LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
        case 25..<30:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
        }
    }
}

struct BMICategoryRow: View {
    let category: String
    let range: String
    let color: Color
    let isHighlighted: Bool
    
    var body: some View {
        HStack {
            Text(category)
                .font(.subheadline)
                .fontWeight(isHighlighted ? .bold : .medium)
            
            Spacer()
            
            Text(range)
                .font(.subheadline)
                .fontWeight(isHighlighted ? .bold : .regular)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isHighlighted ? color.opacity(0.2) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isHighlighted ? color : Color.gray.opacity(0.3), lineWidth: isHighlighted ? 2 : 1)
                )
        )
        .foregroundColor(isHighlighted ? color : .primary)
    }
}

#Preview {
    BMICalculatorSimpleView()
}
