import SwiftUI

struct HealthReportsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weekly Summary Card
                ReportCard(title: "Weekly Summary", value: "85%", description: "Overall Progress")
                
                // Activity Stats
                ReportCard(title: "Activity Stats", value: "7,500", description: "Daily Steps Average")
                
                // Sleep Analysis
                ReportCard(title: "Sleep Analysis", value: "7.2hrs", description: "Average Sleep Time")
                
                // Workout Progress
                ReportCard(title: "Workout Progress", value: "12", description: "Workouts This Month")
            }
            .padding()
        }
        .navigationTitle("Health Reports")
    }
}

struct ReportCard: View {
    let title: String
    let value: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            HStack {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                Spacer()
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}
