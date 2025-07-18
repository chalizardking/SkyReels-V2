//
//  HorseDetailView.swift
//  poni
//
//  Created by Cha Lizardking on 7/7/25.
//

import SwiftUI
import Charts

struct HorseDetailView: View {
    let horse: Horse
    @Environment(\.dismiss) private var dismiss
    
    @State private var raceHistory: [RaceHistoryEntry] = []
    @State private var jockeyROIData: JockeyROIData?
    @State private var trainerROIData: TrainerROIData?
    @State private var breedingInfo: BreedingInfo?
    @State private var pedigreeAnalysis: PedigreeAnalysis?
    @State private var isLoading = false
    @State private var selectedTab = 0
    @State private var errorMessage: String?
    
    @StateObject private var dataSourceManager = DataSourceManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Error message if any
                    if let errorMessage = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Header with horse info
                    horseHeaderView
                    
                    // Tab selector
                    tabSelector
                    
                    // Content based on selected tab
                    Group {
                        switch selectedTab {
                        case 0:
                            performanceView
                        case 1:
                            connectionsView
                        case 2:
                            breedingView
                        case 3:
                            analyticsView
                        default:
                            performanceView
                        }
                    }
                    .animation(.easeInOut, value: selectedTab)
                }
                .padding()
            }
            .navigationTitle(horse.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadDetailedData()
            }
        }
    }
    
    private var horseHeaderView: some View {
        VStack(spacing: 16) {
            // Horse name and basic info
            VStack(spacing: 8) {
                Text(horse.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(horse.age) year old \(horse.sex) • \(horse.color)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Foaled: \(horse.foalingDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Key stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(title: "Earnings", value: "$\(formatEarnings(horse.earnings))", color: .orange)
                StatCard(title: "Starts", value: "\(horse.starts)", color: .purple)
                StatCard(title: "Wins", value: "\(horse.wins)", color: .red)
                StatCard(title: "Win %", value: String(format: "%.1f%%", horse.starts > 0 ? Double(horse.wins) / Double(horse.starts) * 100 : 0), color: .indigo)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Performance", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabButton(title: "Connections", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            TabButton(title: "Breeding", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            TabButton(title: "Analytics", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var performanceView: some View {
        VStack(spacing: 20) {
            Text("Performance data will be displayed here")
                .foregroundColor(.secondary)
        }
    }
    
    private var connectionsView: some View {
        VStack(spacing: 20) {
            Text("Connections data will be displayed here")
                .foregroundColor(.secondary)
        }
    }
    
    private var breedingView: some View {
        VStack(spacing: 20) {
            Text("Breeding data will be displayed here")
                .foregroundColor(.secondary)
        }
    }
    
    private var analyticsView: some View {
        VStack(spacing: 20) {
            Text("Analytics data will be displayed here")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadDetailedData() async {
        isLoading = true
        errorMessage = nil
        
        // For now, just simulate loading without actual API calls
        // since the methods don't exist in DataSourceManager yet
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            // Simulate some data
            raceHistory = []
            jockeyROIData = nil
            trainerROIData = nil
            breedingInfo = nil
            pedigreeAnalysis = nil
            
        } catch {
            errorMessage = "Failed to load some data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func formatEarnings(_ earnings: Double) -> String {
        if earnings >= 1_000_000 {
            return String(format: "%.1fM", earnings / 1_000_000)
        } else if earnings >= 1_000 {
            return String(format: "%.0fK", earnings / 1_000)
        } else {
            return String(format: "%.0f", earnings)
        }
    }
    
    private func analyzePedigree(_ breeding: BreedingInfo) -> PedigreeAnalysis {
        // Placeholder implementation
        return PedigreeAnalysis()
    }
    
    // MARK: - Supporting Views
    struct TabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(isSelected ? Color.blue : Color.clear)
                    .cornerRadius(8)
            }
        }
    }
    
    struct StatCard: View {
        let title: String
        let value: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Extensions

extension Int {
    var ordinal: String {
        let suffix: String
        switch self {
        case 1: suffix = "st"
        case 2: suffix = "nd"
        case 3: suffix = "rd"
        default: suffix = "th"
        }
        return "\(self)\(suffix)"
    }
}

#Preview {
    let sampleHorse = Horse(
        name: "Thunder Bolt",
        age: 5,
        trainer: "John Smith",
        starts: 12,
        wins: 4,
        places: 3,
        shows: 2,
        earnings: 250_000
    )
    
    sampleHorse.sire = "Storm King"
    sampleHorse.dam = "Lightning Queen"
    sampleHorse.owner = "Racing Stables Inc"
    sampleHorse.sex = "Colt"
    sampleHorse.color = "Bay"
    sampleHorse.jockey = "Mike Smith"
    sampleHorse.lastRaced = Date()
    
    return NavigationStack {
        HorseDetailView(horse: sampleHorse)
    }
}
