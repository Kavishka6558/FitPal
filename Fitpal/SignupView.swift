

import SwiftUI

// Signup View
struct SignupView: View {
    @Binding var authState: AuthState
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: handleSignup) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: { authState = .login }) {
                Text("Already have an account? Login")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
    
    private func handleSignup() {
        // Add your signup logic here
        isAuthenticated = true
        authState = .authenticated
    }
}
