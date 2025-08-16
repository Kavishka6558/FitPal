import SwiftUI

struct HealthNewsView: View {
    var body: some View {
        List {
            ForEach(1...10, id: \.self) { _ in
                NewsRow()
            }
        }
        .navigationTitle("Health News")
    }
}

struct NewsRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .cornerRadius(10)
            
            Text("Latest Health Updates")
                .font(.headline)
            Text("Learn about the newest developments in health and fitness")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}
