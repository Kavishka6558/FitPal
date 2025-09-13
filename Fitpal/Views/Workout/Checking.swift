import SwiftUI
import AVFoundation

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int = 90 // 90 seconds rest time
    @Published var isTimerRunning = false
    @Published var currentSet = 1
    private var timer: Timer?
    
    func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                AudioServicesPlaySystemSound(1007) // Play system sound
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        timeRemaining = 90 // Reset to 90 seconds
    }
    
    func skipRest() {
        stopTimer()
        if currentSet < 3 {
            currentSet += 1
        }
    }
}

struct WorkoutExerciseView: View {
    let exerciseName: String
    let totalSets: Int
    let totalReps: Int
    @StateObject private var timerVM = TimerViewModel()
    @State private var showingCamera = false
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.05),
                    Color.white,
                    Color.teal.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Modern Exercise Header
                    VStack(spacing: 8) {
                        Text(exerciseName)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .black],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                        
                        Text("Workout Session")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Modern Sets and Reps counter with glass-morphism
                    HStack(spacing: 24) {
                        ModernStatsCard(
                            value: "\(timerVM.currentSet)",
                            label: "SETS",
                            subtitle: "OF \(totalSets) SETS",
                            gradient: [.blue, .purple],
                            icon: "checkmark.circle.fill"
                        )
                        
                        ModernStatsCard(
                            value: "\(totalReps)",
                            label: "REPS",
                            subtitle: "OF \(totalReps) REPS",
                            gradient: [.green, .mint],
                            icon: "repeat.circle.fill"
                        )
                    }
                    .padding(.horizontal, 4)
                    
                    // Enhanced Timer View with modern design
                    ModernTimerCard(
                        timerVM: timerVM,
                        formatTime: formatTime
                    )
                    
                    // Modern Action Buttons
                    HStack(spacing: 16) {
                        WorkoutActionButton(
                            title: "Steps",
                            icon: "list.number",
                            gradient: [Color.orange, Color.red],
                            action: {}
                        )
                        
                        WorkoutActionButton(
                            title: "Safety Tips",
                            icon: "shield.checkered",
                            gradient: [Color.pink, Color.purple],
                            action: {}
                        )
                    }
                    
                    // Enhanced Camera View with modern design
                    ModernCameraCard(showingCamera: $showingCamera)
                    
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Workout")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Set \(timerVM.currentSet) of \(totalSets)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView()
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Modern Components

struct ModernStatsCard: View {
    let value: String
    let label: String
    let subtitle: String
    let gradient: [Color]
    let icon: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.1) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                VStack(spacing: 4) {
                    Text(label)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Material.ultraThinMaterial)
                
                // Subtle gradient overlay
                LinearGradient(
                    colors: [.white.opacity(0.1), .clear, gradient.first?.opacity(0.02) ?? .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        .shadow(color: .black.opacity(0.04), radius: 24, x: 0, y: 12)
    }
}

struct ModernTimerCard: View {
    @ObservedObject var timerVM: TimerViewModel
    let formatTime: (Int) -> String
    
    var body: some View {
        VStack(spacing: 24) {
            // Timer Status
            VStack(spacing: 8) {
                Text(timerVM.isTimerRunning ? "Rest Time" : "Ready for Next Set")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.black],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(timerVM.isTimerRunning ? "Take a break and recover" : "Prepare for your next set")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Enhanced Timer Circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 140, height: 140)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: CGFloat(timerVM.timeRemaining) / 90.0)
                    .stroke(
                        LinearGradient(
                            colors: [.teal, .green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: timerVM.timeRemaining)
                
                // Timer Text
                VStack(spacing: 4) {
                    Text(formatTime(timerVM.timeRemaining))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .teal],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("remaining")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        if timerVM.isTimerRunning {
                            timerVM.stopTimer()
                        } else {
                            timerVM.startTimer()
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: timerVM.isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text(timerVM.isTimerRunning ? "Pause" : "Start")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        timerVM.skipRest()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "forward.end.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Skip Rest")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.teal, .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .teal.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(32)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Material.ultraThinMaterial)
                
                // Gradient overlay
                LinearGradient(
                    colors: [.white.opacity(0.1), .clear, .teal.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
        .shadow(color: .black.opacity(0.04), radius: 32, x: 0, y: 16)
    }
}

struct WorkoutActionButton: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.1) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Material.ultraThinMaterial)
                    
                    LinearGradient(
                        colors: [.white.opacity(0.1), .clear, gradient.first?.opacity(0.02) ?? .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.03), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernCameraCard: View {
    @Binding var showingCamera: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showingCamera = true
            }
        }) {
            VStack(spacing: 24) {
                // Camera icon with modern styling
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "video.circle.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.gray, .secondary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("Form Check Camera")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Position yourself in frame to track your form")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Material.ultraThinMaterial)
                    
                    // Subtle gradient overlay
                    LinearGradient(
                        colors: [.white.opacity(0.05), .clear, .gray.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
            .shadow(color: .black.opacity(0.03), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(red: 0, green: 0.32, blue: 0.66))
                .cornerRadius(10)
        }
    }
}

struct CameraView: View {
    var body: some View {
        Text("Camera View")
            .onAppear {
                // Request camera permission here
                AVCaptureDevice.requestAccess(for: .video) { _ in }
            }
    }
}

#Preview {
    NavigationView {
        WorkoutExerciseView(exerciseName: "Bench Press", totalSets: 3, totalReps: 10)
    }
}
