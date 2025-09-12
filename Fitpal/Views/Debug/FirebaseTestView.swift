import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct FirebaseTestView: View {
    var body: some View {
        VStack {
            Text("Firebase Integration Test")
                .font(.title)
                .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("✅ FirebaseCore imported successfully")
                Text("✅ FirebaseAuth imported successfully")
                Text("✅ FirebaseFirestore imported successfully")
                Text("✅ FirebaseStorage imported successfully")
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    FirebaseTestView()
}
