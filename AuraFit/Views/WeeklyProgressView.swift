//
//  WeeklyProgressView.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/29/25.
//

import SwiftUI
import Charts

struct WeeklyProgressView: View {
    @State private var logs: [(date: Date, total: Int, maintenance: Int)] = []
    @EnvironmentObject var viewModel: NutritionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Calorie Progress")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            if logs.isEmpty {
                ProgressView("Loading weekly data...")
                    .tint(.green)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(logs, id: \.date) { log in
                        LineMark(
                            x: .value("Date", log.date, unit: .day),
                            y: .value("Calories", log.total)
                        )
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        
                        LineMark(
                            x: .value("Date", log.date, unit: .day),
                            y: .value("Maintenance", log.maintenance)
                        )
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    }
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [.black.opacity(0.7), .gray.opacity(0.3)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
        .task {
            logs = await viewModel.fetchWeeklyLogs()
        }
    }
}
