import SwiftUI
import Foundation

// Simple test version of HeartRiskView
struct HeartRiskViewTest: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Heart Risk Assessment")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Test View - Building Successfully")
                    .padding()
                
                Spacer()
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
        }
    }
}

#Preview {
    HeartRiskViewTest()
}
