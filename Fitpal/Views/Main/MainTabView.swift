import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            ReportView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Report")
                }
                .tag(1)
            
            WorkoutView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Workout")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(3)
        }
    }
}
