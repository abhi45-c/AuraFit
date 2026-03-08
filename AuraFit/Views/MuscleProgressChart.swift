//
//  MuscleProgressChart.swift
//  AuraFit
//
//  Created by Abhirup Pal on 11/25/25.
//


import SwiftUI
import Charts

struct MuscleProgressChart: View {
    @ObservedObject var vm: MuscleProgressViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Muscle Weight Trend")
                .font(.title3.bold())
                .foregroundColor(.white)
            
            Chart {
                // Loop through each muscle group based on Core Data attribute "muscleGroup"
                ForEach(vm.groupedByMuscle.keys.sorted(), id: \.self) { muscle in
                    
                    if let dataset = vm.groupedByMuscle[muscle] {
                        
                        // Plot all entries of this muscle group
                        ForEach(dataset) { entry in
                            
                            LineMark(
                                x: .value("Date", entry.date ?? Date()),
                                y: .value("Weight", entry.weight),
                                series: .value("Muscle", muscle)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(by: .value("Muscle", muscle))
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                            
                            PointMark(
                                x: .value("Date", entry.date ?? Date()),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(by: .value("Muscle", muscle))
                        }
                    }
                }
            }
            .chartLegend(.visible)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 250)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}
