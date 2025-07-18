//
//  ContentView.swift
//  poni
//
//  Created by Cha Lizardking on 7/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @StateObject private var appearanceManager = AppearanceManager.shared
    @StateObject private var dataSourceManager = DataSourceManager.shared
    @State private var showingOnboarding = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Horse Racing View
            HorseRacingView()
                .tabItem {
                    Image(systemName: "figure.equestrian.sports")
                    Text("Racing")
                }
                .tag(0)
            
            // Favorites/Watchlist
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(1)
            
            // Analytics Dashboard
            AnalyticsDashboardView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Analytics")
                }
                .tag(2)
            
            // Race Analysis
            RaceAnalysisView()
                .tabItem {
                    Image(systemName: "stopwatch")
                    Text("Analysis")
                }
                .tag(3)
            
            // Settings
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView()
        }
        .onAppear {
            showingOnboarding = !dataSourceManager.hasCompletedOnboarding
        }
        .modelContainer(for: [Horse.self, Race.self, Jockey.self, Trainer.self, RaceEntry.self])
    }
}

// MARK: - Supporting Views

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var horses: [Horse]
    
    var favoriteHorses: [Horse] {
        // In a real app, you'd have a favorites system
        horses.prefix(10).map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            if favoriteHorses.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No Favorites Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Search for horses and add them to your favorites to track their performance.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(favoriteHorses, id: \.id) { horse in
                    HorseListRow(horse: horse)
                }
            }
        }
        .navigationTitle("Favorites")
    }
}

struct AnalyticsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var horses: [Horse]
    @Query private var jockeys: [Jockey]
    @Query private var trainers: [Trainer]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary cards
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        SummaryCard(title: "Horses Tracked", value: "\(horses.count)", color: .blue)
                        SummaryCard(title: "Jockeys", value: "\(jockeys.count)", color: .green)
                        SummaryCard(title: "Trainers", value: "\(trainers.count)", color: .orange)
                        SummaryCard(title: "Total Wins", value: "\(horses.reduce(0) { $0 + $1.wins })", color: .purple)
                    }
                    
                    // Top performers
                    if !horses.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Performers")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(topHorses, id: \.id) { horse in
                                HorsePerformanceRow(horse: horse)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }
    
    private var topHorses: [Horse] {
        horses.sorted { $0.wins > $1.wins }.prefix(5).map { $0 }
    }
}

// Settings view is now imported from Views/SettingsView.swift

// MARK: - Helper Views

struct HorseListRow: View {
    let horse: Horse
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(horse.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(horse.age) yr • \(horse.trainer)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(horse.wins)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Wins")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct HorsePerformanceRow: View {
    let horse: Horse
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(horse.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(horse.wins)-\(horse.places)-\(horse.shows)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(horse.wins)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Horse.self, Jockey.self, Trainer.self, Race.self, RaceEntry.self], inMemory: true)
}
