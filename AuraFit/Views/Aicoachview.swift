//
//  Aicoachview.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/24/25.
//
import SwiftUI

struct AICoachView: View {
    @StateObject private var viewModel = AICoachViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, .gray.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                if let profile = viewModel.profile {
                    AICoachDashboardView(viewModel: viewModel, profile: profile)
                } else {
                    AICoachSetupView(viewModel: viewModel)
                }
            }
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
}


//

struct AICoachSetupView: View {
    @ObservedObject var viewModel: AICoachViewModel
    @State private var goal = "Build Muscle"
    @State private var bodyType = "Athletic"
    @State private var weight = ""
    @State private var height = ""
    @State private var showConfirmation = false
    
    var body: some View {
        ZStack {
            // MARK: - Animated Gradient Background
            LinearGradient(colors: [.black, .purple.opacity(0.8)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .overlay(
                    RadialGradient(gradient: Gradient(colors: [.clear, .purple.opacity(0.3)]),
                                   center: .bottomTrailing,
                                   startRadius: 50,
                                   endRadius: 500)
                        .blur(radius: 100)
                )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 35) {
                    
                    // MARK: - Title
                    VStack(spacing: 8) {
                        Text("Your AI Coach Awaits")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .purple.opacity(0.5), radius: 10, y: 5)
                        
                        Text("Let’s customize your ultimate fitness path 🚀")
                            .font(.headline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                    .padding(.horizontal)
                    
                    // MARK: - Setup Card
                    VStack(spacing: 25) {
                        
                        // GOAL Picker
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Select Goal", systemImage: "target")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                            Picker("", selection: $goal) {
                                Text("Build Muscle").tag("Build Muscle")
                                Text("Lose Fat").tag("Lose Fat")
                                Text("Get Stronger").tag("Get Stronger")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // BODY TYPE Picker
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Body Type", systemImage: "figure.strengthtraining.traditional")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                            Picker("", selection: $bodyType) {
                                Text("Athletic").tag("Athletic")
                                Text("Bulky").tag("Bulky")
                                Text("Slim").tag("Slim")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // WEIGHT & HEIGHT Input
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Body Metrics", systemImage: "ruler")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                            
                            HStack {
                                TextField("Weight (kg)", text: $weight)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                
                                TextField("Height (cm)", text: $height)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                    .shadow(color: .purple.opacity(0.3), radius: 15, y: 10)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                            .blur(radius: 1)
                    )
                    
                    // MARK: - Generate Plan Button
                    Button {
                        if let w = Double(weight), let h = Double(height) {
                            withAnimation(.spring()) {
                                viewModel.saveProfile(goal: goal, bodyType: bodyType, weight: w, height: h)
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Generate My AI Plan")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.title3.bold())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(20)
                        .shadow(color: .purple.opacity(0.5), radius: 10, y: 5)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                    
                    // MARK: - Reset Plan Button
                    Button(role: .destructive) {
                        showConfirmation = true
                    } label: {
                        Label("Reset My Plan", systemImage: "arrow.counterclockwise.circle.fill")
                            .font(.subheadline.bold())
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 60)
                    .alert("Reset AI Coach?", isPresented: $showConfirmation) {
                        Button("Reset", role: .destructive) {
                            viewModel.resetProfile()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("This will delete your current fitness data and start over.")
                    }
                }
            }
        }
    }
}


//

struct AICoachDashboardView: View {
    @ObservedObject var viewModel: AICoachViewModel
    var profile: AIProfile
    
    @Namespace private var animation
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                if let plan = viewModel.todayPlan {
                    
                    // MARK: - Muscle Focus Card
                    VStack(spacing: 8) {
                        Text("🏋️‍♂️ Today's Focus")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text(plan.muscleFocus ?? "—")
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    
                    
                    // MARK: - Workout Plan
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💪 Workout Plan")
                            .font(.title3.bold())
                        
                        Text(plan.workoutPlan ?? "No workout available")
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 6)
                    .padding(.horizontal)
                    
                    
                    // MARK: - Diet Plan (Bubbles)
                    if let dietText = plan.dietPlan {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("🥗 Today's Meals")
                                .font(.title3.bold())
                                .padding(.bottom, 5)
                            
                            ForEach(parseDietSections(from: dietText), id: \.title) { section in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(section.icon)
                                            .font(.title3)
                                        Text(section.title)
                                            .font(.headline)
                                    }
                                    
                                    Text(section.details)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    LinearGradient(colors: [.orange.opacity(0.25), .pink.opacity(0.25)],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .cornerRadius(16)
                                .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    // MARK: - Motivation Cinematic Banner
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.black, .gray.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 10) {
                            Text("🔥 Motivation 🔥")
                                .font(.title3.smallCaps())
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(plan.motivation ?? "")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .minimumScaleFactor(0.8)
                                .transition(.opacity.combined(with: .scale))
                                .id(plan.motivation)
                                .animation(.easeInOut(duration: 0.6), value: plan.motivation)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .shadow(radius: 12)
                    .overlay(
                        LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                            .blur(radius: 50)
                    )
                }
                
                // MARK: - Generate Button
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.generateTodayPlan()
                    }
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Generate Today's Plan")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .font(.title3.bold())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(20)
                    .shadow(color: .purple.opacity(0.5), radius: 10, y: 5)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.resetProfile()
                    }
                } label: {
                    Label("Reset Plan", systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                        .cornerRadius(14)
                        .shadow(radius: 8)
                }
                .padding(.horizontal)
            }
            .padding(.top, 25)
        }
        .navigationTitle(" AI Coach ")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    // MARK: - Helper for Parsing Diet Text into Sections
    private func parseDietSections(from dietText: String) -> [(title: String, icon: String, details: String)] {
        let lines = dietText.split(separator: "\n").map { String($0) }
        var sections: [(String, String, String)] = []
        
        var currentTitle = ""
        var details = ""
        var icon = ""
        
        for line in lines {
            if line.contains("Breakfast") {
                if !currentTitle.isEmpty { sections.append((currentTitle, icon, details.trimmingCharacters(in: .whitespaces))) }
                currentTitle = "Breakfast"
                icon = "🍳"
                details = line.replacingOccurrences(of: "🍳 Breakfast:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.contains("Lunch") {
                if !currentTitle.isEmpty { sections.append((currentTitle, icon, details.trimmingCharacters(in: .whitespaces))) }
                currentTitle = "Lunch"
                icon = "🍚"
                details = line.replacingOccurrences(of: "🍚 Lunch:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.contains("Dinner") {
                if !currentTitle.isEmpty { sections.append((currentTitle, icon, details.trimmingCharacters(in: .whitespaces))) }
                currentTitle = "Dinner"
                icon = "🌙"
                details = line.replacingOccurrences(of: "🌙 Dinner:", with: "").trimmingCharacters(in: .whitespaces)
            } else {
                details += " \(line)"
            }
        }
        if !currentTitle.isEmpty {
            sections.append((currentTitle, icon, details.trimmingCharacters(in: .whitespaces)))
        }
        return sections
    }
}



#Preview {
AICoachView()
}
