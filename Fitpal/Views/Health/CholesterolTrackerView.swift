import SwiftUI

struct CholesterolTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var totalCholesterol: String = ""
    @State private var ldl: String = ""
    @State private var hdl: String = ""
    @State private var triglycerides: String = ""
    @State private var age: String = ""
    @State private var gender = "Male"
    @State private var showResults = false
    @State private var cholesterolResult = CholesterolResult(
        status: "Unknown",
        analysis: CholesterolAnalysis(
            totalCholesterol: 0,
            ldlLevel: 0,
            hdlLevel: 0,
            triglyceridesLevel: 0,
            ldlHdlRatio: 0,
            nonHdl: 0
        )
    )
    
    let genderOptions = ["Male", "Female"]
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemRed).opacity(0.08),
                Color(.systemOrange).opacity(0.05),
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
                    Text("Cholesterol Tracker")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Cardiovascular Health")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(.clear)
                    .frame(width: 44, height: 44)
            }
            
            Text("Track and analyze your cholesterol levels to understand your cardiovascular risk.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    // Personal Information Section
                    VStack(spacing: 20) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(.red.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "person.circle")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Personal Information")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("Required for accurate assessment")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gender")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
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
                                placeholder: "e.g., 35",
                                text: $age,
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
                    
                    // Lipid Profile Section
                    VStack(spacing: 20) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(.orange.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "drop.circle")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Lipid Profile")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("Enter your latest lab results")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Total Cholesterol",
                                subtitle: "Complete cholesterol measurement (mg/dL)",
                                placeholder: "e.g., 200",
                                text: $totalCholesterol,
                                keyboardType: .numberPad,
                                required: true
                            )
                            
                            ModernInputField(
                                title: "LDL Cholesterol",
                                subtitle: "Low-density lipoprotein (bad cholesterol) - mg/dL",
                                placeholder: "e.g., 100",
                                text: $ldl,
                                keyboardType: .numberPad,
                                required: true
                            )
                            
                            ModernInputField(
                                title: "HDL Cholesterol",
                                subtitle: "High-density lipoprotein (good cholesterol) - mg/dL",
                                placeholder: "e.g., 50",
                                text: $hdl,
                                keyboardType: .numberPad,
                                required: true
                            )
                            
                            ModernInputField(
                                title: "Triglycerides",
                                subtitle: "Blood fat levels - mg/dL",
                                placeholder: "e.g., 150",
                                text: $triglycerides,
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
                    
                    // Analyze Button
                    Button(action: analyzeResults) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "chart.line.uptrend.xyaxis.circle")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Analyze Results")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Get cholesterol assessment")
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
                                colors: [.red, .orange],
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
                    
                    // Results Display
                    if showResults {
                        VStack(spacing: 20) {
                            // Result Header
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(getStatusGradient(cholesterolResult.status))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "heart.text.square")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Analysis Results")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    Text("Cholesterol Assessment")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            // Overall Status Display
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Overall Status")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                    
                                    Text(cholesterolResult.status)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(getStatusGradient(cholesterolResult.status))
                                }
                                
                                Spacer()
                            }
                            
                            // Detailed Results
                            VStack(spacing: 12) {
                                
                                ModernLipidCard(
                                    title: "Total Cholesterol",
                                    value: cholesterolResult.analysis.totalCholesterol,
                                    unit: "mg/dL",
                                    status: totalCholesterolStatus(cholesterolResult.analysis.totalCholesterol),
                                    icon: "drop.circle",
                                    color: .blue
                                )
                                
                                ModernLipidCard(
                                    title: "LDL (Bad)",
                                    value: cholesterolResult.analysis.ldlLevel,
                                    unit: "mg/dL",
                                    status: ldlStatus(cholesterolResult.analysis.ldlLevel),
                                    icon: "arrow.down.circle",
                                    color: .red
                                )
                                
                                ModernLipidCard(
                                    title: "HDL (Good)",
                                    value: cholesterolResult.analysis.hdlLevel,
                                    unit: "mg/dL",
                                    status: hdlStatus(cholesterolResult.analysis.hdlLevel, gender: gender),
                                    icon: "arrow.up.circle",
                                    color: .green
                                )
                                
                                ModernLipidCard(
                                    title: "Triglycerides",
                                    value: cholesterolResult.analysis.triglyceridesLevel,
                                    unit: "mg/dL",
                                    status: triglyceridesStatus(cholesterolResult.analysis.triglyceridesLevel),
                                    icon: "waveform.circle",
                                    color: .orange
                                )
                                
                                ModernLipidCard(
                                    title: "LDL/HDL Ratio",
                                    value: cholesterolResult.analysis.ldlHdlRatio,
                                    unit: "",
                                    status: ratioStatus(cholesterolResult.analysis.ldlHdlRatio),
                                    icon: "percent",
                                    color: .purple,
                                    isRatio: true
                                )
                                
                                ModernLipidCard(
                                    title: "Non-HDL",
                                    value: cholesterolResult.analysis.nonHdl,
                                    unit: "mg/dL",
                                    status: nonHdlStatus(cholesterolResult.analysis.nonHdl),
                                    icon: "minus.circle",
                                    color: .indigo
                                )
                            }
                            
                            // Recommendations Section
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lightbulb.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.yellow)
                                    
                                    Text("Recommendations")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(getRecommendations(), id: \.self) { recommendation in
                                        HStack(alignment: .top, spacing: 12) {
                                            Circle()
                                                .fill(.blue.opacity(0.2))
                                                .frame(width: 24, height: 24)
                                                .overlay(
                                                    Image(systemName: "checkmark")
                                                        .font(.caption)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.blue)
                                                )
                                                .padding(.top, 2)
                                            
                                            Text(recommendation)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                    }
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
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func getStatusGradient(_ status: String) -> LinearGradient {
        switch status {
        case "Optimal":
            return LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
        case "Borderline":
            return LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
        case "High Risk":
            return LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.gray, .secondary], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private func analyzeResults() {
        guard let totalValue = Double(totalCholesterol),
              let ldlValue = Double(ldl),
              let hdlValue = Double(hdl),
              let triglyceridesValue = Double(triglycerides) else {
            return
        }
        
        let ratio = ldlValue / hdlValue
        let nonHdl = totalValue - hdlValue
        
        let analysis = CholesterolAnalysis(
            totalCholesterol: totalValue,
            ldlLevel: ldlValue,
            hdlLevel: hdlValue,
            triglyceridesLevel: triglyceridesValue,
            ldlHdlRatio: ratio,
            nonHdl: nonHdl
        )
        
        // Determine overall status
        var status = "Optimal"
        
        if ldlValue >= 160 || totalValue >= 240 || triglyceridesValue >= 200 || hdlValue < 40 {
            status = "High Risk"
        } else if ldlValue >= 130 || totalValue >= 200 || triglyceridesValue >= 150 || hdlValue < 50 {
            status = "Borderline"
        }
        
        cholesterolResult = CholesterolResult(
            status: status,
            analysis: analysis
        )
        
        showResults = true
    }
    
    private func lipidResultRow(label: String, value: Double, unit: String, status: (String, Color)) -> some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(Int(value))\(unit)")
                    .fontWeight(.semibold)
                Text(status.0)
                    .font(.caption)
                    .foregroundColor(status.1)
            }
        }
        .padding(.vertical, 5)
    }
    
    private func totalCholesterolStatus(_ value: Double) -> (String, Color) {
        if value < 200 { return ("Desirable", .green) }
        else if value < 240 { return ("Borderline", .orange) }
        else { return ("High", .red) }
    }
    
    private func ldlStatus(_ value: Double) -> (String, Color) {
        if value < 100 { return ("Optimal", .green) }
        else if value < 130 { return ("Near Optimal", .blue) }
        else if value < 160 { return ("Borderline", .orange) }
        else if value < 190 { return ("High", .red) }
        else { return ("Very High", .red) }
    }
    
    private func hdlStatus(_ value: Double, gender: String) -> (String, Color) {
        if gender == "Male" {
            if value >= 60 { return ("High (Good)", .green) }
            else if value >= 40 { return ("Good", .blue) }
            else { return ("Low (Risk)", .red) }
        } else {
            if value >= 60 { return ("High (Good)", .green) }
            else if value >= 50 { return ("Good", .blue) }
            else { return ("Low (Risk)", .red) }
        }
    }
    
    private func triglyceridesStatus(_ value: Double) -> (String, Color) {
        if value < 150 { return ("Normal", .green) }
        else if value < 200 { return ("Borderline", .orange) }
        else if value < 500 { return ("High", .red) }
        else { return ("Very High", .red) }
    }
    
    private func ratioStatus(_ value: Double) -> (String, Color) {
        if value < 2.5 { return ("Ideal", .green) }
        else if value < 3.5 { return ("Good", .blue) }
        else if value < 5 { return ("Average", .orange) }
        else { return ("High Risk", .red) }
    }
    
    private func nonHdlStatus(_ value: Double) -> (String, Color) {
        if value < 130 { return ("Optimal", .green) }
        else if value < 160 { return ("Above Optimal", .blue) }
        else if value < 190 { return ("Borderline", .orange) }
        else if value < 220 { return ("High", .red) }
        else { return ("Very High", .red) }
    }
    
    private func statusColor(status: String) -> Color {
        switch status {
        case "Optimal":
            return .green
        case "Borderline":
            return .orange
        case "High Risk":
            return .red
        default:
            return .gray
        }
    }
    
    private func getRecommendations() -> [String] {
        var recommendations = [String]()
        
        let analysis = cholesterolResult.analysis
        
        if analysis.ldlLevel >= 130 || analysis.totalCholesterol >= 200 {
            recommendations.append("Limit saturated fats and trans fats in your diet")
            recommendations.append("Increase consumption of foods rich in soluble fiber")
            recommendations.append("Consider adding plant sterols/stanols to your diet")
        }
        
        if analysis.hdlLevel < 50 {
            recommendations.append("Increase physical activity - aim for 30 minutes most days")
            recommendations.append("Include healthy fats like omega-3s in your diet")
            recommendations.append("Consider limiting refined carbohydrates")
        }
        
        if analysis.triglyceridesLevel >= 150 {
            recommendations.append("Limit added sugars and refined carbohydrates")
            recommendations.append("Reduce alcohol consumption")
            recommendations.append("Include omega-3 fatty acids in your diet")
        }
        
        if cholesterolResult.status == "High Risk" {
            recommendations.append("Schedule a follow-up with your healthcare provider")
            recommendations.append("Discuss potential medical interventions if lifestyle changes aren't sufficient")
        }
        
        if recommendations.isEmpty {
            recommendations.append("Maintain your current healthy lifestyle")
            recommendations.append("Continue regular cholesterol screenings as recommended by your doctor")
        }
        
        return recommendations
    }
}

struct ModernLipidCard: View {
    let title: String
    let value: Double
    let unit: String
    let status: (String, Color)
    let icon: String
    let color: Color
    let isRatio: Bool
    
    init(title: String, value: Double, unit: String, status: (String, Color), icon: String, color: Color, isRatio: Bool = false) {
        self.title = title
        self.value = value
        self.unit = unit
        self.status = status
        self.icon = icon
        self.color = color
        self.isRatio = isRatio
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(status.0)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(status.1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(isRatio ? String(format: "%.2f", value) : "\(Int(value))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(status.1.opacity(0.3), lineWidth: 1)
                )
        )
    }
}



struct CholesterolResult {
    let status: String
    let analysis: CholesterolAnalysis
}

struct CholesterolAnalysis {
    let totalCholesterol: Double
    let ldlLevel: Double
    let hdlLevel: Double
    let triglyceridesLevel: Double
    let ldlHdlRatio: Double
    let nonHdl: Double
}

#Preview {
    CholesterolTrackerView()
}
