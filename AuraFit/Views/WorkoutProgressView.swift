//
//  WorkoutProgressView.swift
//  AuraFit
//
//  Created by Abhirup Pal on 11/24/25.
//


import SwiftUI
import Charts

struct WorkoutProgressView: View {
    @EnvironmentObject var historyVM: WorkoutHistoryViewModel
    @State private var selectedScope: String = "Month"

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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Workout Progress")
                    .font(.largeTitle.bold())
                    .padding(.top)
                    .foregroundColor(.white)

                Picker("Scope", selection: $selectedScope) {
                    Text("Month").tag("Month")
                    Text("Year").tag("Year")
                    Text("All").tag("All")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Chart(filteredData) { set in
                    LineMark(
                        x: .value("Date", set.date!),
                        y: .value("Weight", set.weight)
                    )
                    .interpolationMethod(.catmullRom)
                    .symbol(Circle())
                }
                .frame(height: 250)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                
                Text("History")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                ForEach(historyVM.workoutSets) { set in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(set.exerciseName ?? "")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(formatDate(set.date!))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("\(set.reps) reps")
                        Text("\(set.weight) kg")
                            .foregroundColor(.blue)
                            .bold()
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }

    func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy, HH:mm"
        return df.string(from: date)
    }
}

#Preview {
    WorkoutProgressView()
        .environmentObject(WorkoutHistoryViewModel())
}
