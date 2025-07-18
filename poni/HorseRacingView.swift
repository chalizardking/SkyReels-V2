//
//  HorseRacingView.swift
//  poni
//
//  Created by Cha Lizardking on 7/7/25.
//

import SwiftUI
import SwiftData

struct HorseRacingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Race.date) private var races: [Race]
    @StateObject private var dataSource = DataSourceManager.shared
    @State private var selectedRace: Race?
    @State private var isLoading = false
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            List {
                if races.isEmpty {
                    ContentUnavailableView(
                        "No Races Available",
                        systemImage: "sportscourt",
                        description: Text("Check back later for today's races")
                    )
                } else {
                    ForEach(races) { race in
                        RaceRow(race: race)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRace = race
                            }
                    }
                }
            }
            .navigationTitle("Horse Racing")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshRaces) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .sheet(item: $selectedRace) { race in
                NavigationStack {
                    RaceDetailView(race: race)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                if let error = dataSource.errorMessage {
                    Text(error)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
            .task {
                await loadRaces()
            }
        }
    }
    
    private func refreshRaces() {
        Task {
            await loadRaces()
        }
    }
    
    private func loadRaces() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        if let error = dataSource.errorMessage {
            showError = true
            return
        }
        
        let fetchedRaces = await dataSource.fetchTodaysRaces()
        if fetchedRaces.isEmpty {
            showError = true
        }
    }
}

struct RaceRow: View {
    let race: Race
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(race.track) - Race \(race.raceNumber)")
                .font(.headline)
            
            HStack {
                Text(race.date, format: .dateTime.hour().minute())
                Text("•")
                Text("\(race.distance) • \(race.surface)")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Text("\(race.raceClass)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HorseRacingView()
        .modelContainer(for: [Race.self, Horse.self, Jockey.self, Trainer.self, RaceEntry.self], inMemory: true)
}
