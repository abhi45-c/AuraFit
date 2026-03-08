//
//  TabView.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/18/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    init() {
        // Makes tab bar translucent with custom appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeView() }
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)
            
            NavigationStack { WorkoutsView() }
                .tabItem {
                    Label("Workouts", systemImage: selectedTab == 1 ? "figure.strengthtraining.traditional" : "figure.walk")
                }
                .tag(1)
            
            NavigationStack { AICoachView() }
                .tabItem {
                    Label("AI Coach", systemImage: selectedTab == 2 ? "brain.head.profile.fill" : "brain.head.profile")
                }
                .tag(2)
            
            NavigationStack { NutritionView() }
                .tabItem {
                    Label("Nutrition", systemImage: selectedTab == 3 ? "fork.knife.circle.fill" : "fork.knife")
                }
                .tag(3)
            
            NavigationStack { WorkoutProgressView() }
                .tabItem {
                    Label("Progress", systemImage: selectedTab == 4 ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.bar.xaxis")
                }
                .tag(4)
            
            NavigationStack { ProfileView() }
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 5 ? "person.crop.circle.fill" : "person.circle")
                }
                .tag(5)
        }
        .tint(.green)
        .background(Color.black.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

#Preview {
    MainTabView()
        .environmentObject(NutritionViewModel())
}
