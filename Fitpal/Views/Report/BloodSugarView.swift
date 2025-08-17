import SwiftUI

struct BloodSugarView: View {
    @StateObject private var bloodSugarService = BloodSugarService()
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddForm = false
    @State private var selectedReading: BloodSugarReading?
    @State private var showingDetail = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with Quick Add Button
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Blood Sugar Tracker")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Monitor your glucose levels")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingAddForm = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // Latest Reading Summary
                        if let latestReading = bloodSugarService.getLatestReading() {
                            LatestReadingCard(reading: latestReading)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Quick Stats
                    QuickStatsView(service: bloodSugarService)
                        .padding(.horizontal, 20)
                    
                    // Recent Readings
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Readings")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("View All") {
                                // Navigate to full history
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        if bloodSugarService.readings.isEmpty {
                            EmptyStateView {
                                showingAddForm = true
                            }
                            .padding(.horizontal, 20)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(bloodSugarService.readings.prefix(5)) { reading in
                                    BloodSugarReadingCard(reading: reading) {
                                        selectedReading = reading
                                        showingDetail = true
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Blood Sugar")
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Export Data", action: exportData)
                        Button("View Trends", action: viewTrends)
                        Button("Settings", action: openSettings)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddForm) {
                BloodSugarFormView(service: bloodSugarService)
            }
            .sheet(isPresented: $showingDetail) {
                if let reading = selectedReading {
                    BloodSugarDetailView(reading: reading, service: bloodSugarService)
                }
            }
        }
    }
    
    private func exportData() {
        let data = bloodSugarService.exportData()
        // Implement export functionality (share sheet, etc.)
    }
    
    private func viewTrends() {
        // Navigate to trends view
    }
    
    private func openSettings() {
        // Navigate to settings
    }
}

struct LatestReadingCard: View {
    let reading: BloodSugarReading
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latest Reading")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(reading.glucoseLevel))")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(reading.riskLevel.color)
                        
                        Text("mg/dL")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(reading.readingType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(reading.riskLevel.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(reading.riskLevel.color)
                    
                    Text(reading.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !reading.riskDescription.isEmpty {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(reading.riskLevel.color)
                    
                    Text(reading.riskDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct QuickStatsView: View {
    let service: BloodSugarService
    
    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Avg Fasting",
                value: formatAverage(service.getAverageGlucose(for: .fasting)),
                unit: "mg/dL",
                color: .blue
            )
            
            StatCard(
                title: "30-Day Trend",
                value: service.getRiskTrend().displayName,
                unit: "",
                color: service.getRiskTrend().color
            )
            
            StatCard(
                title: "Total Readings",
                value: "\(service.readings.count)",
                unit: "entries",
                color: .green
            )
        }
    }
    
    private func formatAverage(_ average: Double?) -> String {
        guard let average = average else { return "--" }
        return "\(Int(average))"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.tertiarySystemGroupedBackground))
        )
    }
}

struct BloodSugarReadingCard: View {
    let reading: BloodSugarReading
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Risk indicator
                Circle()
                    .fill(reading.riskLevel.color)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(Int(reading.glucoseLevel)) mg/dL")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(reading.readingType.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                            )
                            .foregroundColor(.blue)
                    }
                    
                    Text(reading.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let notes = reading.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    let onAddTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "drop.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Readings Yet")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Start tracking your blood sugar levels to monitor your health")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add First Reading") {
                onAddTapped()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}

#Preview {
    BloodSugarView()
}
