import SwiftUI
import MapKit
import CoreLocation

struct WalkTrackingView: View {
    @State private var stepCount = 0
    @State private var distance = 0.0
    @State private var calories = 0
    @State private var isTracking = false
    @State private var walkingTime = 0
    @State private var timer: Timer?
    
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Text("Fitness Tracking")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Track your walking route")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Map View
                VStack {
                    ZStack {
                        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .none)
                            .frame(height: 200)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Custom path overlay
                        if walkPath.count > 1 {
                            WalkPathOverlay(coordinates: walkPath, region: region)
                                .frame(height: 200)
                                .cornerRadius(12)
                                .allowsHitTesting(false)
                        }
                        
                        if !isTracking && walkPath.isEmpty {
                            VStack {
                                Image(systemName: "location")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                Text("Start tracking to see your route")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Stats Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    StatCard(
                        title: "Steps",
                        value: "\(stepCount)",
                        icon: "figure.walk",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Distance",
                        value: String(format: "%.2f km", distance),
                        icon: "location",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Calories",
                        value: "\(calories)",
                        icon: "flame",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Time",
                        value: formattedTime,
                        icon: "clock",
                        color: .purple
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Start/Stop Button
                Button(action: toggleTracking) {
                    HStack {
                        Image(systemName: isTracking ? "stop.fill" : "play.fill")
                            .font(.title2)
                        Text(isTracking ? "Stop Tracking" : "Start Tracking")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isTracking ? Color.red : Color.blue)
                    .cornerRadius(25)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            .onAppear {
                setupLocation()
            }
            .onChange(of: locationManager.lastLocation) { newLocation in
                if let location = newLocation, isTracking {
                    updateWalkPath(with: location)
                }
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
    
    private func startTracking() {
        walkPath.removeAll()
        stepCount = 0
        distance = 0.0
        calories = 0
        walkingTime = 0
        
        locationManager.startLocationUpdates()
        
        // Start timer for elapsed time
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            walkingTime += 1
        }
    }
    
    private func stopTracking() {
        locationManager.stopLocationUpdates()
        timer?.invalidate()
        timer = nil
    }
    
    private func updateWalkPath(with location: CLLocation) {
        let coordinate = location.coordinate
        
        if let lastCoordinate = walkPath.last {
            let lastLocation = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)
            let distanceIncrement = location.distance(from: lastLocation) / 1000.0 // Convert to km
            
            if distanceIncrement > 0.001 { // Only add if moved more than 1 meter
                walkPath.append(coordinate)
                distance += distanceIncrement
                
                // Update step count (rough approximation: 1 step per 0.8 meters)
                stepCount += Int(distanceIncrement * 1000 / 0.8)
                
                // Update calories (rough approximation: 0.04 calories per step)
                calories = Int(Double(stepCount) * 0.04)
                
                // Update map region to follow user
                region.center = coordinate
            }
        } else {
            // First location
            walkPath.append(coordinate)
            region.center = coordinate
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
