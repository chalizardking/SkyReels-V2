//
//  RaceAnalysisView.swift
//  poni
//
//  Created by Assistant on 2024
//
//  Race Analysis View - Displays comprehensive horse racing analytics
//  
//  API Data Sources:
//  - Horse Racing USA API (https://rapidapi.com/ortegalex/apiLizardking@1/horse-racing-usa)
//    * Provides real-time race data, horse information, and race results
//    * Rate limit: 10 requests per minute (Free tier)
//    * Endpoints used: /racecards, /race/{raceId}, /results
//    * Data includes: race details, horse performance, jockey/trainer info
//  
//  Data Processing:
//  - Raw API data is processed through DataMappingService
//  - Stored locally using SwiftData for offline access
//  - Real-time updates when API key is configured
//

import SwiftUI
import SwiftData

struct RaceAnalysisView: View {
    @Query private var horses: [Horse]
    @Query private var races: [Race]
    @State private var selectedHorse: Horse?
    @State private var analysisType: AnalysisType = .classAnalysis
    
    enum AnalysisType: String, CaseIterable {
        case classAnalysis = "Class Analysis"
        case paceAnalysis = "Pace Analysis"
        case agePerformance = "Age Performance"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Analysis Type Picker
                Picker("Analysis Type", selection: $analysisType) {
                    ForEach(AnalysisType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Horse Selection
                if !horses.isEmpty {
                    Picker("Select Horse", selection: $selectedHorse) {
                        Text("Select a Horse").tag(nil as Horse?)
                        ForEach(horses, id: \.id) { horse in
                            Text(horse.name).tag(horse as Horse?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }
                
                // Analysis Content
                ScrollView {
                    if let horse = selectedHorse {
                        switch analysisType {
                        case .classAnalysis:
                            ClassAnalysisSection(horse: horse, races: races)
                        case .paceAnalysis:
                            PaceAnalysisSection(horse: horse, races: races)
                        case .agePerformance:
                            AgePerformanceSection(horse: horse)
                        }
                    } else {
                        ContentUnavailableView(
                            "Select a Horse",
                            systemImage: "horse",
                            description: Text("Choose a horse to view detailed race analysis")
                        )
                    }
                }
            }
            .navigationTitle("Race Analysis")
        }
    }
}

struct ClassAnalysisSection: View {
    let horse: Horse
    let races: [Race]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Class Performance Overview
            GroupBox("Class Performance Overview") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Best Class Level:")
                        Spacer()
                        Text("\(horse.bestClassLevel)/10")
                            .fontWeight(.semibold)
                            .foregroundColor(classLevelColor(horse.bestClassLevel))
                    }
                    
                    HStack {
                        Text("Average Class Level:")
                        Spacer()
                        Text(String(format: "%.1f/10", horse.averageClassLevel))
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Class Movement:")
                        Spacer()
                        Text(horse.classMovementTrend)
                            .fontWeight(.semibold)
                            .foregroundColor(trendColor(horse.classMovementTrend))
                    }
                    
                    HStack {
                        Text("Stakes Wins:")
                        Spacer()
                        Text("\(horse.stakesWins)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Graded Stakes Wins:")
                        Spacer()
                        Text("\(horse.gradedStakesWins)")
                            .fontWeight(.semibold)
                            .foregroundColor(horse.gradedStakesWins > 0 ? .green : .primary)
                    }
                }
            }
            
            // Recent Race Classes
            GroupBox("Recent Race Analysis") {
                if races.isEmpty {
                    ContentUnavailableView(
                        "No Recent Races",
                        systemImage: "calendar",
                        description: Text("Race data will appear here")
                    )
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(races.prefix(5)) { race in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(race.track) R\(race.raceNumber)")
                                        .font(.headline)
                                    Text(race.raceClass)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text(race.surface)
                                        .fontWeight(.semibold)
                                    Text(formattedPurse(race.purse))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            
                            if race.id != races.prefix(5).last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func formattedPurse(_ purse: Double) -> String {
        if purse >= 1_000_000 {
            return String(format: "$%.1fM", purse / 1_000_000)
        } else if purse >= 1_000 {
            return String(format: "$%.0fK", purse / 1_000)
        } else {
            return String(format: "$%.0f", purse)
        }
    }
    
    private func performanceColor(_ percentage: Double) -> Color {
        switch percentage {
        case 70...: return .green
        case 40..<70: return .orange
        default: return .red
        }
    }

    private func trendColor(_ trend: String) -> Color {
        switch trend.lowercased() {
        case "improving": return .green
        case "declining": return .red
        default: return .orange
        }
    }
    
    private func classLevelColor(_ level: Int) -> Color {
        switch level {
        case 8...10: return .green
        case 5...7: return .orange
        case 1...4: return .red
        default: return .gray
        }
    }

    // MARK: - Horse Performance Analysis
    private func analyzeHorsePerformance(_ horse: Horse) -> (trend: String, color: Color) {
        let winRate = Double(horse.wins) / Double(max(1, horse.starts)) * 100
        let trend: String
        let color: Color
        
        switch winRate {
        case 50...:
            trend = "Strong"
            color = .green
        case 30..<50:
            trend = "Good"
            color = .blue
        case 15..<30:
            trend = "Fair"
            color = .orange
        default:
            trend = "Needs Improvement"
            color = .red
        }
        
        return (trend, color)
    }
}

struct PaceAnalysisSection: View {
    let horse: Horse
    let races: [Race]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Pace Preferences
            GroupBox("Pace Profile") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Running Style:")
                        Spacer()
                        Text(horse.pacePreference)
                            .fontWeight(.semibold)
                            .foregroundColor(paceStyleColor(horse.pacePreference))
                    }
                    
                    HStack {
                        Text("Best Pace Scenario:")
                        Spacer()
                        Text(horse.bestPaceScenario)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Pace Versatility:")
                        Spacer()
                        Text(String(format: "%.1f/10", horse.paceVersatility))
                            .fontWeight(.semibold)
                            .foregroundColor(versatilityColor(horse.paceVersatility))
                    }
                }
            }
            
            // Recent Pace Analysis
            GroupBox("Recent Race Pace") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(races.prefix(5), id: \.id) { race in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(race.name)
                                    .font(.headline)
                                Text(race.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(race.paceAnalysis)
                                    .fontWeight(.semibold)
                                    .foregroundColor(paceColor(race.paceAnalysis))
                                Text(race.energyDistribution)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if race.id != races.prefix(5).last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func paceStyleColor(_ style: String) -> Color {
        switch style {
        case "Early Speed": return .red
        case "Stalker": return .orange
        case "Closer": return .blue
        case "Deep Closer": return .purple
        default: return .gray
        }
    }
    
    private func paceColor(_ pace: String) -> Color {
        switch pace {
        case "Fast": return .red
        case "Moderate": return .orange
        case "Slow": return .green
        default: return .gray
        }
    }
    
    private func versatilityColor(_ rating: Double) -> Color {
        switch rating {
        case 8...10: return .green
        case 5...7: return .orange
        default: return .red
        }
    }
}

struct AgePerformanceSection: View {
    let horse: Horse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Current Age Performance
            GroupBox("Current Performance") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Current Age:")
                        Spacer()
                        Text("\(horse.age) years")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Form Trend:")
                        Spacer()
                        Text(horse.currentFormTrend)
                            .fontWeight(.semibold)
                            .foregroundColor(trendColor(horse.currentFormTrend))
                    }
                    
                    if let peakAge = horse.peakAge {
                        HStack {
                            Text("Peak Age:")
                            Spacer()
                            Text("\(peakAge) years")
                                .fontWeight(.semibold)
                                .foregroundColor(horse.age == peakAge ? .green : .orange)
                        }
                    }
                }
            }
            
            // Age Performance History
            if !horse.agePerformanceHistory.isEmpty {
                GroupBox("Performance by Age") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(horse.agePerformanceHistory.sorted(by: { $0.age > $1.age }), id: \.age) { ageData in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Age \(ageData.age)")
                                        .font(.headline)
                                        .foregroundColor(ageData.peakPerformanceIndicator ? .green : .primary)
                                    Text("\(ageData.winsAtAge)/\(ageData.startsAtAge) wins")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text(String(format: "%.1f%%", Double(ageData.winsAtAge) / Double(ageData.startsAtAge) * 100))
                                        .fontWeight(.semibold)
                                        .foregroundColor(performanceColor(Double(ageData.winsAtAge) / Double(ageData.startsAtAge) * 100))
                                    Text("$\(Int(ageData.earningsAtAge))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            
                            if ageData.age != horse.agePerformanceHistory.sorted(by: { $0.age > $1.age }).last?.age {
                                Divider()
                            }
                        }
                    }
                }
            } else {
                GroupBox("Performance History") {
                    Text("No age performance data available")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .padding()
    }
    
    private func trendColor(_ trend: String) -> Color {
        switch trend {
        case "Improving": return .green
        case "Declining": return .red
        case "Peak": return .blue
        default: return .orange
        }
    }
    
    private func performanceColor(_ percentage: Double) -> Color {
        switch percentage {
        case 25...100: return .green
        case 10...24: return .orange
        default: return .red
        }
    }
}

#Preview {
    RaceAnalysisView()
        .modelContainer(for: [Horse.self, Race.self])
}
