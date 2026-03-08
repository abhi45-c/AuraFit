//
//  HomeView.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/18/25.
//

import SwiftUI
import Charts

struct HomeView: View {
    
    // MARK: - Environment Objects
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @EnvironmentObject var historyVM: WorkoutHistoryViewModel

    // MARK: - State Objects
    @StateObject var healthManager = HealthManager()
    @StateObject var muscleVM = MuscleProgressViewModel()
    
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    
                    headerSection
                    ringSection
                    currentProgramSection
                    weeklyProgressSection
                    strengthProgressSection
                    multipleMuscleChartsSection
                    ctaButtonsSection
                    
                }
                .padding(.top)
            }
            .background(appGradient)
            .ignoresSafeArea()
        }
    }
}

// MARK: -------------------------------------------------------
// MARK: HEADER
// MARK: -------------------------------------------------------
extension HomeView {
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello Athlete 👋")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("3 active programs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "bell.fill")
                .foregroundStyle(.green)
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
        }
        .padding(.horizontal)
    }
}

// MARK: -------------------------------------------------------
// MARK: RING PROGRESS
// MARK: -------------------------------------------------------
extension HomeView {

    private var ringSection: some View {
        HStack(spacing: 25) {
            StatRingView(
                progress: Double(healthManager.workoutsCompleted) / 30,
                label: "Workouts",
                value: "\(healthManager.workoutsCompleted)"
            )
            
            StatRingView(
                progress: healthManager.caloriesBurned / 25000,
                label: "Calories",
                value: "\(Int(healthManager.caloriesBurned))"
            )
            
            StatRingView(
                progress: healthManager.minutesTrained / 1500,
                label: "Minutes",
                value: "\(Int(healthManager.minutesTrained))"
            )
        }
        .padding(.horizontal)
    }
}

// MARK: -------------------------------------------------------
// MARK: CURRENT PROGRAM CARD
// MARK: -------------------------------------------------------
extension HomeView {
    
    private var currentProgramSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Program")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(colors: [.green.opacity(0.8), .blue.opacity(0.7)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .frame(height: 150)
                .overlay(currentProgramOverlay)
        }
        .padding(.horizontal)
    }
    
    private var currentProgramOverlay: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Strong arms and a powerful body")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Text("Plan for 1 month · 8.2 rating")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                
                Button(action: {}) {
                    Label("View details", systemImage: "chevron.right")
                        .font(.subheadline)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer()
            
            Image("fitness-model")
                .resizable()
                .scaledToFit()
                .frame(width: 90)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }
}

// MARK: -------------------------------------------------------
// MARK: WEEKLY PROGRESS (CALORIES)
// MARK: -------------------------------------------------------
extension HomeView {
    
    private var weeklyProgressSection: some View {
        WeeklyProgressView()
            .environmentObject(nutritionVM)
            .padding(.horizontal)
    }
}

// MARK: -------------------------------------------------------
// MARK: STRENGTH PROGRESS CHART
// MARK: -------------------------------------------------------
extension HomeView {
    
    private var strengthProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Progress")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            WorkoutProgressCard()
                .environmentObject(historyVM)
                .frame(height: 250)
                .background(.ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 20))
        }
        .padding(.horizontal)
    }
}

// MARK: -------------------------------------------------------
// MARK: MULTIPLE MUSCLE GROUPS CHART
// MARK: -------------------------------------------------------
extension HomeView {
    
    private var multipleMuscleChartsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Muscle Progress")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                // ➕ Add Entry Button
                NavigationLink {
                    AddMuscleEntryView(vm: muscleVM)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            Chart {
                ForEach(muscleVM.entries) { entry in
                    LineMark(
                        x: .value("Date", entry.date ?? Date()),
                        y: .value("Weight", entry.weight),
                        series: .value("Muscle", entry.muscleGroup ?? "Unknown")
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(by: .value("Muscle", entry.muscleGroup ?? "Unknown"))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Date", entry.date ?? Date()),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(by: .value("Muscle", entry.muscleGroup ?? "Unknown"))
                }
            }
            .chartLegend(.visible)
            .frame(height: 200)
        }
        .padding(.horizontal)
    }
}

// MARK: -------------------------------------------------------
// MARK: CTA BUTTONS
// MARK: -------------------------------------------------------
extension HomeView {
    
    private var ctaButtonsSection: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                Label("Pause Program", systemImage: "pause.fill")
                    .padding()
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 14))
            }
            
            Button(action: {}) {
                Label("Change Program", systemImage: "arrow.triangle.2.circlepath")
                    .padding()
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(colors: [.green.opacity(0.1),
                                                .blue.opacity(0.3)],
                                       startPoint: .leading,
                                       endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 50)
    }
}

// MARK: -------------------------------------------------------
// MARK: GLOBAL APP GRADIENT
// MARK: -------------------------------------------------------
extension HomeView {
    private var appGradient: LinearGradient {
        LinearGradient(
            colors: [.black, .green.opacity(0.4), .black],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}


// MARK: - Stat Ring Component
struct StatRingView: View {
    var progress: Double
    var label: String
    var value: String

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.green, .blue]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)
                
                Text(value)
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct WorkoutProgressCard: View {
    @EnvironmentObject var historyVM: WorkoutHistoryViewModel
    @State private var selectedScope = "Month"

    var filteredData: [WorkoutSet] {
        switch selectedScope {
        case "Month":
            return historyVM.workoutSets.filter {
                Calendar.current.isDate($0.date!, equalTo: Date(), toGranularity: .month)
            }
        case "Year":
            return historyVM.workoutSets.filter {
                Calendar.current.isDate($0.date!, equalTo: Date(), toGranularity: .year)
            }
        default:
            return historyVM.workoutSets
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Title + Navigation
            HStack {
                Text("Strength Progress")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                NavigationLink(destination: WorkoutProgressView()) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }

            // Chart
            Chart(filteredData) { set in
                LineMark(
                    x: .value("Date", set.date!),
                    y: .value("Weight", set.weight)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.green)
            }
            .chartXAxis(.automatic)
            .chartYAxis(.automatic)
        }
        .padding()
    }
}
