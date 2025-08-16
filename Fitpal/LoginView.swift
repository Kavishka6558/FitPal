import SwiftUI

// Login View
struct LoginView: View {
    @Binding var authState: AuthState
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: handleLogin) {
                Text("Login")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: { authState = .signup }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
    
    private func handleLogin() {
        // Add your login logic here
        isAuthenticated = true
        authState = .authenticated
    }
}
