import SwiftUI
import LocalAuthentication

struct DebugFaceIDView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("FaceID Debug Info")
                .font(.title)
            
            let context = LAContext()
            let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            
            Text("Can evaluate biometrics: \(canEvaluate ? "YES" : "NO")")
            
            if canEvaluate {
                switch context.biometryType {
                case .faceID:
                    Text("Type: Face ID")
                case .touchID:
                    Text("Type: Touch ID")
                case .opticID:
                    Text("Type: Optic ID")
                default:
                    Text("Type: None")
                }
            } else {
                Text("Biometrics not available")
            }
        }
        .padding()
    }
}
