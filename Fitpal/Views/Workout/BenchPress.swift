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
        VStack(spacing: 20) {
            // Navigation bar is handled by NavigationView
            
            // Sets and Reps counter
            HStack(spacing: 40) {
                VStack {
                    Text("\(timerVM.currentSet)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                    Text("SETS")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Text("OF \(totalSets) SETS")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack {
                    Text("\(totalReps)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                    Text("REPS")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Text("OF \(totalReps) REPS")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 0, green: 0.32, blue: 0.66))
            .cornerRadius(15)
            
            // Timer View
            VStack {
                Text(timerVM.isTimerRunning ? "Time's up!" : "Next set start soon")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(timerVM.timeRemaining) / 90.0)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    Text(formatTime(timerVM.timeRemaining))
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Button(action: timerVM.skipRest) {
                    Text("Skip Rest")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 0, green: 0.78, blue: 0.71))
            .cornerRadius(15)
            
            // Action Buttons
            HStack(spacing: 20) {
                ActionButton(title: "Steps", action: {})
                ActionButton(title: "Safety tips", action: {})
            }
            
            // Camera View
            VStack {
                Image(systemName: "video.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                
                Text("Position your self in frame")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .onTapGesture {
                showingCamera = true
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(exerciseName)
        .navigationBarTitleDisplayMode(.inline)
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
