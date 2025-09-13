import SwiftUI
import AVFoundation
import Vision
import PhotosUI
import CoreML

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

// MARK: - Workout Analysis Models
struct WorkoutAnalysisResult: Equatable {
    let workoutType: WorkoutType
    let overallScore: Double
    let feedback: [WorkoutFeedback]
    let timestamp: Date
    let videoURL: URL?
    
    static func == (lhs: WorkoutAnalysisResult, rhs: WorkoutAnalysisResult) -> Bool {
        return lhs.workoutType == rhs.workoutType &&
               lhs.overallScore == rhs.overallScore &&
               lhs.feedback == rhs.feedback &&
               lhs.timestamp == rhs.timestamp &&
               lhs.videoURL == rhs.videoURL
    }
}

struct WorkoutFeedback: Equatable {
    let category: FeedbackCategory
    let severity: FeedbackSeverity
    let message: String
    let suggestion: String
}

enum WorkoutType: String, CaseIterable, Equatable {
    case pushUps = "Push-ups"
    case squats = "Squats"
    case benchPress = "Bench Press"
    
    var instructions: [String] {
        switch self {
        case .pushUps:
            return [
                "Keep your body in a straight line",
                "Lower until chest nearly touches ground",
                "Push up with control",
                "Keep core engaged"
            ]
        case .squats:
            return [
                "Feet shoulder-width apart",
                "Keep chest up and back straight",
                "Lower until thighs parallel to floor",
                "Drive through heels to stand"
            ]
        case .benchPress:
            return [
                "Lie flat with feet on ground",
                "Grip bar slightly wider than shoulders",
                "Lower bar to chest with control",
                "Press up powerfully"
            ]
        }
    }
}

enum FeedbackCategory: String, Equatable {
    case posture = "Posture"
    case form = "Form"
    case range = "Range of Motion"
    case alignment = "Body Alignment"
    case tempo = "Tempo"
}

enum FeedbackSeverity: String, Equatable {
    case good = "Good"
    case moderate = "Needs Improvement"
    case severe = "Critical Issue"
    
    var color: Color {
        switch self {
        case .good: return .green
        case .moderate: return .orange
        case .severe: return .red
        }
    }
}

// MARK: - Workout Analysis ViewModel
class WorkoutAnalysisViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisResult: WorkoutAnalysisResult?
    @Published var selectedVideo: PhotosPickerItem?
    @Published var errorMessage: String?
    @Published var selectedWorkoutType: WorkoutType = .pushUps
    
    func analyzeWorkoutVideo(video: PhotosPickerItem, workoutType: WorkoutType) async {
        DispatchQueue.main.async {
            self.isAnalyzing = true
            self.errorMessage = nil
        }
        
        do {
            // Convert PhotosPickerItem to video URL
            guard let videoData = try await video.loadTransferable(type: Data.self) else {
                throw WorkoutAnalysisError.invalidVideo
            }
            
            // Create temporary URL for video
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            try videoData.write(to: tempURL)
            
            // Perform Vision analysis
            let result = try await performVisionAnalysis(videoURL: tempURL, workoutType: workoutType)
            
            DispatchQueue.main.async {
                self.analysisResult = result
                self.isAnalyzing = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isAnalyzing = false
            }
        }
    }
    
    private func performVisionAnalysis(videoURL: URL, workoutType: WorkoutType) async throws -> WorkoutAnalysisResult {
        let asset = AVAsset(url: videoURL)
        let duration = try await asset.load(.duration)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        
        var feedback: [WorkoutFeedback] = []
        var frameCount = 0
        let totalFramesToAnalyze = 30 // Analyze 30 frames throughout the video
        
        // Analyze frames throughout the video
        for i in 0..<totalFramesToAnalyze {
            let timeValue = CMTime(seconds: Double(i) * duration.seconds / Double(totalFramesToAnalyze), preferredTimescale: 600)
            
            do {
                let cgImage = try await generator.image(at: timeValue).image
                let poseObservations = try await analyzePoseInFrame(cgImage: cgImage)
                
                let frameFeedback = generateFeedbackForFrame(
                    poseObservations: poseObservations,
                    workoutType: workoutType,
                    frameIndex: i
                )
                feedback.append(contentsOf: frameFeedback)
                frameCount += 1
            } catch {
                continue // Skip failed frames
            }
        }
        
        // Calculate overall score based on feedback
        let overallScore = calculateOverallScore(feedback: feedback)
        
        // Consolidate similar feedback
        let consolidatedFeedback = consolidateFeedback(feedback)
        
        return WorkoutAnalysisResult(
            workoutType: workoutType,
            overallScore: overallScore,
            feedback: consolidatedFeedback,
            timestamp: Date(),
            videoURL: videoURL
        )
    }
    
    private func analyzePoseInFrame(cgImage: CGImage) async throws -> [VNHumanBodyPoseObservation] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanBodyPoseRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let observations = request.results as? [VNHumanBodyPoseObservation] ?? []
                continuation.resume(returning: observations)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func generateFeedbackForFrame(
        poseObservations: [VNHumanBodyPoseObservation],
        workoutType: WorkoutType,
        frameIndex: Int
    ) -> [WorkoutFeedback] {
        guard let pose = poseObservations.first else { return [] }
        
        var feedback: [WorkoutFeedback] = []
        
        switch workoutType {
        case .pushUps:
            feedback.append(contentsOf: analyzePushUpForm(pose: pose, frameIndex: frameIndex))
        case .squats:
            feedback.append(contentsOf: analyzeSquatForm(pose: pose, frameIndex: frameIndex))
        case .benchPress:
            feedback.append(contentsOf: analyzeBenchPressForm(pose: pose, frameIndex: frameIndex))
        }
        
        return feedback
    }
    
    private func analyzePushUpForm(pose: VNHumanBodyPoseObservation, frameIndex: Int) -> [WorkoutFeedback] {
        var feedback: [WorkoutFeedback] = []
        
        do {
            // Get key body points
            let leftShoulder = try pose.recognizedPoint(.leftShoulder)
            let rightShoulder = try pose.recognizedPoint(.rightShoulder)
            let leftHip = try pose.recognizedPoint(.leftHip)
            let rightHip = try pose.recognizedPoint(.rightHip)
            let leftElbow = try pose.recognizedPoint(.leftElbow)
            let rightElbow = try pose.recognizedPoint(.rightElbow)
            
            // Check body alignment (straight line from head to feet)
            if leftShoulder.confidence > 0.5 && rightShoulder.confidence > 0.5 &&
               leftHip.confidence > 0.5 && rightHip.confidence > 0.5 {
                
                let shoulderY = (leftShoulder.location.y + rightShoulder.location.y) / 2
                let hipY = (leftHip.location.y + rightHip.location.y) / 2
                let bodyAlignment = abs(shoulderY - hipY)
                
                if bodyAlignment > 0.1 {
                    feedback.append(WorkoutFeedback(
                        category: .alignment,
                        severity: .moderate,
                        message: "Body not in straight line",
                        suggestion: "Keep your body straight from head to feet. Engage your core to maintain proper alignment."
                    ))
                }
            }
            
            // Check elbow position
            if leftElbow.confidence > 0.5 && rightElbow.confidence > 0.5 {
                let elbowY = (leftElbow.location.y + rightElbow.location.y) / 2
                let shoulderY = (leftShoulder.location.y + rightShoulder.location.y) / 2
                
                if elbowY > shoulderY + 0.05 {
                    feedback.append(WorkoutFeedback(
                        category: .form,
                        severity: .moderate,
                        message: "Elbows flaring too wide",
                        suggestion: "Keep your elbows at about 45 degrees from your body, not directly out to the sides."
                    ))
                }
            }
            
        } catch {
            // Continue without this frame if pose detection fails
        }
        
        return feedback
    }
    
    private func analyzeSquatForm(pose: VNHumanBodyPoseObservation, frameIndex: Int) -> [WorkoutFeedback] {
        var feedback: [WorkoutFeedback] = []
        
        do {
            let leftHip = try pose.recognizedPoint(.leftHip)
            let rightHip = try pose.recognizedPoint(.rightHip)
            let leftKnee = try pose.recognizedPoint(.leftKnee)
            let rightKnee = try pose.recognizedPoint(.rightKnee)
            let leftAnkle = try pose.recognizedPoint(.leftAnkle)
            let rightAnkle = try pose.recognizedPoint(.rightAnkle)
            
            // Check squat depth
            if leftHip.confidence > 0.5 && rightHip.confidence > 0.5 &&
               leftKnee.confidence > 0.5 && rightKnee.confidence > 0.5 {
                
                let hipY = (leftHip.location.y + rightHip.location.y) / 2
                let kneeY = (leftKnee.location.y + rightKnee.location.y) / 2
                
                // If hips are significantly higher than knees, squat may be too shallow
                if hipY > kneeY + 0.15 {
                    feedback.append(WorkoutFeedback(
                        category: .range,
                        severity: .moderate,
                        message: "Squat depth insufficient",
                        suggestion: "Lower until your thighs are parallel to the ground for optimal muscle engagement."
                    ))
                }
            }
            
            // Check knee alignment
            if leftKnee.confidence > 0.5 && rightKnee.confidence > 0.5 &&
               leftAnkle.confidence > 0.5 && rightAnkle.confidence > 0.5 {
                
                let leftKneeX = leftKnee.location.x
                let leftAnkleX = leftAnkle.location.x
                let rightKneeX = rightKnee.location.x
                let rightAnkleX = rightAnkle.location.x
                
                // Check if knees are caving inward
                if abs(leftKneeX - leftAnkleX) < 0.02 || abs(rightKneeX - rightAnkleX) < 0.02 {
                    feedback.append(WorkoutFeedback(
                        category: .alignment,
                        severity: .severe,
                        message: "Knees caving inward",
                        suggestion: "Keep your knees in line with your toes. Focus on pushing your knees out during the squat."
                    ))
                }
            }
            
        } catch {
            // Continue without this frame
        }
        
        return feedback
    }
    
    private func analyzeBenchPressForm(pose: VNHumanBodyPoseObservation, frameIndex: Int) -> [WorkoutFeedback] {
        var feedback: [WorkoutFeedback] = []
        
        do {
            let leftShoulder = try pose.recognizedPoint(.leftShoulder)
            let rightShoulder = try pose.recognizedPoint(.rightShoulder)
            let leftElbow = try pose.recognizedPoint(.leftElbow)
            let rightElbow = try pose.recognizedPoint(.rightElbow)
            let leftWrist = try pose.recognizedPoint(.leftWrist)
            let rightWrist = try pose.recognizedPoint(.rightWrist)
            
            // Check arm position
            if leftElbow.confidence > 0.5 && rightElbow.confidence > 0.5 &&
               leftShoulder.confidence > 0.5 && rightShoulder.confidence > 0.5 {
                
                let leftElbowY = leftElbow.location.y
                let leftShoulderY = leftShoulder.location.y
                let rightElbowY = rightElbow.location.y
                let rightShoulderY = rightShoulder.location.y
                
                // Check if elbows are too high (unsafe position)
                if leftElbowY > leftShoulderY + 0.1 || rightElbowY > rightShoulderY + 0.1 {
                    feedback.append(WorkoutFeedback(
                        category: .posture,
                        severity: .severe,
                        message: "Elbows too high - risk of shoulder injury",
                        suggestion: "Keep your elbows slightly below shoulder level to protect your shoulders."
                    ))
                }
            }
            
            // Check wrist alignment
            if leftWrist.confidence > 0.5 && rightWrist.confidence > 0.5 &&
               leftElbow.confidence > 0.5 && rightElbow.confidence > 0.5 {
                
                let leftWristX = leftWrist.location.x
                let leftElbowX = leftElbow.location.x
                let rightWristX = rightWrist.location.x
                let rightElbowX = rightElbow.location.x
                
                // Check wrist alignment with elbows
                if abs(leftWristX - leftElbowX) > 0.1 || abs(rightWristX - rightElbowX) > 0.1 {
                    feedback.append(WorkoutFeedback(
                        category: .alignment,
                        severity: .moderate,
                        message: "Wrists not aligned with elbows",
                        suggestion: "Keep your wrists straight and in line with your elbows for better force transfer."
                    ))
                }
            }
            
        } catch {
            // Continue without this frame
        }
        
        return feedback
    }
    
    private func calculateOverallScore(feedback: [WorkoutFeedback]) -> Double {
        if feedback.isEmpty { return 85.0 } // Default good score if no issues detected
        
        let severityWeights: [FeedbackSeverity: Double] = [
            .good: 0,
            .moderate: -5,
            .severe: -15
        ]
        
        let totalDeduction = feedback.reduce(0) { result, feedback in
            result + (severityWeights[feedback.severity] ?? 0)
        }
        
        return max(0, min(100, 100 + totalDeduction))
    }
    
    private func consolidateFeedback(_ feedback: [WorkoutFeedback]) -> [WorkoutFeedback] {
        // Group feedback by category and message
        let grouped = Dictionary(grouping: feedback) { "\($0.category.rawValue)-\($0.message)" }
        
        return grouped.compactMap { (key, feedbacks) in
            guard let first = feedbacks.first else { return nil }
            
            // Use the most severe feedback for each category
            let mostSevere = feedbacks.max { a, b in
                severityLevel(a.severity) < severityLevel(b.severity)
            }
            
            return mostSevere
        }
    }
    
    private func severityLevel(_ severity: FeedbackSeverity) -> Int {
        switch severity {
        case .good: return 0
        case .moderate: return 1
        case .severe: return 2
        }
    }
}

enum WorkoutAnalysisError: Error, LocalizedError {
    case invalidVideo
    case analysisTimeout
    case visionFrameworkError
    
    var errorDescription: String? {
        switch self {
        case .invalidVideo:
            return "Could not process the selected video"
        case .analysisTimeout:
            return "Analysis took too long to complete"
        case .visionFrameworkError:
            return "Error analyzing workout form"
        }
    }
}

struct WorkoutExerciseView: View {
    let exerciseName: String
    let totalSets: Int
    let totalReps: Int
    @StateObject private var timerVM = TimerViewModel()
    @StateObject private var analysisVM = WorkoutAnalysisViewModel()
    @State private var showingVideoAnalysis = false
    @State private var showingAnalysisResult = false
    
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
                    
                    // Enhanced Form Analysis with Video Upload
                    WorkoutAnalysisCard(
                        exerciseName: exerciseName,
                        analysisVM: analysisVM,
                        showingVideoAnalysis: $showingVideoAnalysis,
                        showingAnalysisResult: $showingAnalysisResult
                    )
                    
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
        .sheet(isPresented: $showingVideoAnalysis) {
            WorkoutVideoAnalysisView(
                analysisVM: analysisVM,
                exerciseName: exerciseName
            )
        }
        .sheet(isPresented: $showingAnalysisResult) {
            if let result = analysisVM.analysisResult {
                WorkoutAnalysisResultView(result: result)
            }
        }
        .onChange(of: analysisVM.analysisResult) { result in
            if result != nil {
                showingAnalysisResult = true
            }
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

struct WorkoutAnalysisCard: View {
    let exerciseName: String
    @ObservedObject var analysisVM: WorkoutAnalysisViewModel
    @Binding var showingVideoAnalysis: Bool
    @Binding var showingAnalysisResult: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Form Analysis")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Upload your workout video for detailed form analysis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Analysis status indicator
                if analysisVM.isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if analysisVM.analysisResult != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
            }
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    showingVideoAnalysis = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "video.badge.plus")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Upload Workout Video")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(analysisVM.isAnalyzing)
                
                if analysisVM.analysisResult != nil {
                    Button(action: {
                        showingAnalysisResult = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("View Analysis Report")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                                .background(Color.blue.opacity(0.05))
                        )
                        .cornerRadius(12)
                    }
                }
            }
            
            // Workout type selector
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Workout Type:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    ForEach(WorkoutType.allCases, id: \.self) { workout in
                        Button(action: {
                            analysisVM.selectedWorkoutType = workout
                        }) {
                            Text(workout.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(
                                    analysisVM.selectedWorkoutType == workout ? .white : .blue
                                )
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            analysisVM.selectedWorkoutType == workout
                                                ? Color.blue
                                                : Color.blue.opacity(0.1)
                                        )
                                )
                        }
                    }
                }
            }
        }
        .padding(.all, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Material.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

struct WorkoutVideoAnalysisView: View {
    @ObservedObject var analysisVM: WorkoutAnalysisViewModel
    let exerciseName: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedVideo: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header with instructions
                VStack(spacing: 16) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 8) {
                        Text("Workout Form Analysis")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Upload a video of your \(exerciseName.lowercased()) for AI-powered form analysis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Workout instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key Points for \(analysisVM.selectedWorkoutType.rawValue):")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        ForEach(analysisVM.selectedWorkoutType.instructions, id: \.self) { instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)
                                
                                Text(instruction)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.all, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.05))
                )
                
                Spacer()
                
                // Video picker
                PhotosPicker(
                    selection: $selectedVideo,
                    matching: .videos
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "video.badge.plus")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text(selectedVideo == nil ? "Select Workout Video" : "Video Selected")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: selectedVideo == nil ? 
                                [Color.blue, Color.blue.opacity(0.8)] :
                                [Color.green, Color.green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                
                // Analyze button
                if selectedVideo != nil {
                    Button(action: {
                        Task {
                            await analysisVM.analyzeWorkoutVideo(
                                video: selectedVideo!,
                                workoutType: analysisVM.selectedWorkoutType
                            )
                            if analysisVM.analysisResult != nil {
                                dismiss()
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            if analysisVM.isAnalyzing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "brain")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            Text(analysisVM.isAnalyzing ? "Analyzing..." : "Analyze Form")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .disabled(analysisVM.isAnalyzing)
                }
                
                // Error message
                if let errorMessage = analysisVM.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.all, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
                        )
                }
                
                Spacer()
            }
            .padding(.all, 20)
            .navigationTitle("Form Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WorkoutAnalysisResultView: View {
    let result: WorkoutAnalysisResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with score
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: result.overallScore / 100)
                                .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1), value: result.overallScore)
                            
                            VStack(spacing: 4) {
                                Text("\(Int(result.overallScore))")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Score")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text("Form Analysis Complete")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(result.workoutType.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Feedback sections
                    if result.feedback.isEmpty {
                        // Excellent form message
                        VStack(spacing: 12) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            
                            Text("Excellent Form!")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.green)
                            
                            Text("No major form issues detected. Keep up the great work!")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.all, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green.opacity(0.1))
                        )
                    } else {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Form Feedback")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(result.feedback.count) issues found")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            ForEach(Array(result.feedback.enumerated()), id: \.offset) { index, feedback in
                                FeedbackCard(feedback: feedback, index: index + 1)
                            }
                        }
                    }
                    
                    // Analysis timestamp
                    HStack {
                        Text("Analysis completed:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(result.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.top, 12)
                }
                .padding(.all, 20)
            }
            .navigationTitle("Analysis Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var scoreColor: Color {
        if result.overallScore >= 80 { return .green }
        else if result.overallScore >= 60 { return .orange }
        else { return .red }
    }
}

struct FeedbackCard: View {
    let feedback: WorkoutFeedback
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(index).")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(feedback.category.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(feedback.severity.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(feedback.severity.color)
                    )
            }
            
            Text(feedback.message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                    .padding(.top, 2)
                
                Text(feedback.suggestion)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.all, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.1))
            )
        }
        .padding(.all, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Material.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(feedback.severity.color.opacity(0.3), lineWidth: 1)
                )
        )
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

#Preview {
    NavigationView {
        WorkoutExerciseView(exerciseName: "Bench Press", totalSets: 3, totalReps: 10)
    }
}
