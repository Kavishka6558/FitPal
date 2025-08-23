import SwiftUI

struct CholesterolTrackerView: View {
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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Cholesterol Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Track and analyze your cholesterol levels to understand your cardiovascular risk.")
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
                    }
                    .padding(.horizontal, 5)
                }
                
                GroupBox(label: Text("Lipid Profile")
                    .font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Total Cholesterol")
                            TextField("mg/dL", text: $totalCholesterol)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("LDL Cholesterol (Bad)")
                            TextField("mg/dL", text: $ldl)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("HDL Cholesterol (Good)")
                            TextField("mg/dL", text: $hdl)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Triglycerides")
                            TextField("mg/dL", text: $triglycerides)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 5)
                }
                
                Button(action: analyzeResults) {
                    Text("Analyze Results")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.vertical)
                
                if showResults {
                    GroupBox(label: Text("Analysis Results")
                        .font(.headline)) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Overall Status:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(cholesterolResult.status)
                                    .fontWeight(.bold)
                                    .foregroundColor(statusColor(status: cholesterolResult.status))
                            }
                            .padding(.vertical, 5)
                            
                            Divider()
                            
                            Group {
                                lipidResultRow(
                                    label: "Total Cholesterol:",
                                    value: cholesterolResult.analysis.totalCholesterol,
                                    unit: "mg/dL",
                                    status: totalCholesterolStatus(cholesterolResult.analysis.totalCholesterol)
                                )
                                
                                lipidResultRow(
                                    label: "LDL (Bad):",
                                    value: cholesterolResult.analysis.ldlLevel,
                                    unit: "mg/dL",
                                    status: ldlStatus(cholesterolResult.analysis.ldlLevel)
                                )
                                
                                lipidResultRow(
                                    label: "HDL (Good):",
                                    value: cholesterolResult.analysis.hdlLevel,
                                    unit: "mg/dL",
                                    status: hdlStatus(cholesterolResult.analysis.hdlLevel, gender: gender)
                                )
                                
                                lipidResultRow(
                                    label: "Triglycerides:",
                                    value: cholesterolResult.analysis.triglyceridesLevel,
                                    unit: "mg/dL",
                                    status: triglyceridesStatus(cholesterolResult.analysis.triglyceridesLevel)
                                )
                                
                                lipidResultRow(
                                    label: "LDL/HDL Ratio:",
                                    value: cholesterolResult.analysis.ldlHdlRatio,
                                    unit: "",
                                    status: ratioStatus(cholesterolResult.analysis.ldlHdlRatio)
                                )
                                
                                lipidResultRow(
                                    label: "Non-HDL:",
                                    value: cholesterolResult.analysis.nonHdl,
                                    unit: "mg/dL",
                                    status: nonHdlStatus(cholesterolResult.analysis.nonHdl)
                                )
                            }
                            
                            Divider()
                            
                            Text("Recommendations")
                                .font(.headline)
                                .padding(.top, 5)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(getRecommendations(), id: \.self) { recommendation in
                                    HStack(alignment: .top) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                            .padding(.top, 2)
                                        Text(recommendation)
                                    }
                                }
                            }
                            .padding(.top, 5)
                        }
                        .padding(.horizontal, 5)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Cholesterol Tracker")
        .navigationBarTitleDisplayMode(.inline)
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
