import SwiftUI
import MapKit
import CoreLocation
import HealthKit

struct WalkTrackingView: View {
    @StateObject private var healthKitService = HealthKitService()
    @State private var isTracking = false
    @State private var walkingTime = 0
    @State private var timer: Timer?
    @State private var showingHealthKitPermission = false
    
    // MapKit and Location
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var walkPath: [CLLocationCoordinate2D] = []
    @StateObject private var locationManager = LocationManager()
    
    var formattedTime: String {
        let minutes = walkingTime / 60
        let seconds = walkingTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemBlue).opacity(0.1),
                Color(.systemTeal).opacity(0.08),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    // Navigation back action
                }) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Fitness Tracking")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Track your walking journey")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Activity indicator
                Circle()
                    .fill(isTracking ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .scaleEffect(isTracking ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isTracking)
            }
        }
        .padding(.top, 8)
    }
    
    private var mapPlaceholder: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(.blue.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "location.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.blue.gradient)
                )
            
            VStack(spacing: 4) {
                Text("Ready to Track")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("Tap start to begin your journey")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding()
    }
    
    private var liveIndicator: some View {
        VStack {
            HStack {
                Spacer()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.2)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isTracking)
                    
                    Text("LIVE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black.opacity(0.7), in: Capsule())
            }
            Spacer()
        }
        .padding()
    }
    
    private var mapView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
            
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .none)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                // Custom path overlay
                if walkPath.count > 1 {
                    WalkPathOverlay(coordinates: walkPath, region: region)
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .allowsHitTesting(false)
                }
                
                // Placeholder when not tracking
                if !isTracking && walkPath.isEmpty {
                    mapPlaceholder
                }
                
                // Tracking overlay
                if isTracking {
                    liveIndicator
                }
            }
        }
    }
    
    private var controlButtonGradient: LinearGradient {
        LinearGradient(
            colors: isTracking ? [.red, .pink] : [.blue, .purple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var controlButtonContent: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: isTracking ? "stop.fill" : "play.fill")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isTracking ? "Stop Tracking" : "Start Your Journey")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(isTracking ? "Tap to finish session" : "Begin fitness tracking")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(20)
    }
    
    private var controlButton: some View {
        Button(action: toggleTracking) {
            controlButtonContent
                .background(controlButtonGradient)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: (isTracking ? Color.red : Color.blue).opacity(0.3), radius: 15, x: 0, y: 8)
                .scaleEffect(isTracking ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isTracking)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Modern Header
                        headerView
                
                        // Modern Map View
                        mapView
                
                        // Modern Stats Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
                            ModernStatCard(
                                title: "Steps",
                                value: "\(healthKitService.stepCount)",
                                icon: "figure.walk",
                                gradient: [.blue, .purple]
                            )
                            
                            ModernStatCard(
                                title: "Distance",
                                value: String(format: "%.2f km", healthKitService.distance),
                                icon: "location.fill",
                                gradient: [.green, .mint]
                            )
                            
                            ModernStatCard(
                                title: "Calories",
                                value: "\(healthKitService.activeEnergy)",
                                icon: "flame.fill",
                                gradient: [.orange, .red]
                            )
                            
                            ModernStatCard(
                                title: "Time",
                                value: formattedTime,
                                icon: "clock.fill",
                                gradient: [.purple, .pink]
                            )
                        }
                
                        // Modern Control Button
                        controlButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                setupLocation()
                setupHealthKit()
            }
            .onChange(of: locationManager.lastLocation) { newLocation in
                if let location = newLocation, isTracking {
                    updateWalkPath(with: location)
                }
            }
            .alert("HealthKit Permission Required", isPresented: $showingHealthKitPermission) {
                Button("Allow") {
                    healthKitService.requestAuthorization()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("FitPal needs access to your health data to display steps, distance, and calories burned.")
            }
        }
    }
    
    private func toggleTracking() {
        isTracking.toggle()
        
        if isTracking {
            startTracking()
        } else {
            stopTracking()
        }
    }
    
    private func setupLocation() {
        locationManager.requestLocationPermission()
        if let location = locationManager.lastLocation {
            region.center = location.coordinate
        }
    }
    
    private func setupHealthKit() {
        if !healthKitService.isAuthorized {
            showingHealthKitPermission = true
        } else {
            healthKitService.fetchTodayHealthData()
        }
    }
    
    private func startTracking() {
        walkPath.removeAll()
        walkingTime = 0
        
        locationManager.startLocationUpdates()
        
        // Start HealthKit live updates for real-time data
        healthKitService.startLiveUpdates()
        
        // Start timer for elapsed time
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            walkingTime += 1
        }
    }
    
    private func stopTracking() {
        locationManager.stopLocationUpdates()
        timer?.invalidate()
        timer = nil
        
        // Stop HealthKit live updates
        healthKitService.stopLiveUpdates()
    }
    
    private func updateWalkPath(with location: CLLocation) {
        let coordinate = location.coordinate
        
        if let lastCoordinate = walkPath.last {
            let lastLocation = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)
            let distanceIncrement = location.distance(from: lastLocation) / 1000.0 // Convert to km
            
            if distanceIncrement > 0.001 { // Only add if moved more than 1 meter
                walkPath.append(coordinate)
                
                // Update map region to follow user
                region.center = coordinate
                
                // Refresh HealthKit data for real-time updates
                healthKitService.fetchTodayHealthData()
            }
        } else {
            // First location
            walkPath.append(coordinate)
            region.center = coordinate
        }
    }
}

struct ModernStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                    .shadow(color: gradient[0].opacity(0.4), radius: 8, x: 0, y: 4)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// Custom view to draw the walking path on the map
struct WalkPathOverlay: View {
    let coordinates: [CLLocationCoordinate2D]
    let region: MKCoordinateRegion
    
    var body: some View {
        GeometryReader { geometry in
            if coordinates.count > 1 {
                Path { path in
                    for (index, coordinate) in coordinates.enumerated() {
                        let point = convertCoordinateToPoint(coordinate: coordinate, 
                                                           region: region, 
                                                           geometry: geometry)
                        
                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 3)
            }
        }
    }
    
    private func convertCoordinateToPoint(coordinate: CLLocationCoordinate2D, 
                                        region: MKCoordinateRegion, 
                                        geometry: GeometryProxy) -> CGPoint {
        let deltaLat = region.span.latitudeDelta
        let deltaLon = region.span.longitudeDelta
        
        let x = (coordinate.longitude - (region.center.longitude - deltaLon/2)) / deltaLon * geometry.size.width
        let y = ((region.center.latitude + deltaLat/2) - coordinate.latitude) / deltaLat * geometry.size.height
        
        return CGPoint(x: x, y: y)
    }
}

// Location Manager to handle GPS tracking
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0 // Update every meter
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.lastLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }
}

#Preview {
    WalkTrackingView()
}
