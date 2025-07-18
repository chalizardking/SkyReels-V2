import SwiftUI
import SwiftData

struct RaceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let race: Race
    @State private var selectedEntry: RaceEntry?
    
    var sortedEntries: [RaceEntry] {
        race.entries.sorted { $0.postPosition < $1.postPosition }
    }
    
    var body: some View {
        List {
            // Race Info Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(race.track)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Race \(race.raceNumber)")
                            .font(.headline)
                        Text("•")
                        Text(race.date, format: .dateTime.hour().minute())
                            .font(.headline)
                    }
                    .foregroundColor(.secondary)
                    
                    Text("\(race.distance) • \(race.surface)")
                        .font(.subheadline)
                    
                    Text(race.conditions)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    
                    Text("Purse: $\(Int(race.purse))")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.top, 4)
                }
                .padding(.vertical, 8)
            }
            
            // Entries Section
            Section("Entries") {
                ForEach(sortedEntries) { entry in
                    RaceEntryRow(entry: entry)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedEntry = entry
                        }
                }
            }
        }
        .navigationTitle("Race Details")
        .sheet(item: $selectedEntry) { entry in
            NavigationStack {
                if let horse = entry.horse {
    HorseDetailView(horse: horse)
} else {
    Text("Horse data unavailable")
}
            }
        }
    }
}

struct RaceEntryRow: View {
    let entry: RaceEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("#\(entry.postPosition)")
                    .font(.caption)
                    .padding(6)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(entry.horse?.name ?? "Unknown Horse")
                        .font(.headline)
                    
                    HStack {
                        Text("J: \(entry.jockey?.name ?? "Unknown Jockey")")
                        Text("T: \(entry.trainer?.name ?? "Unknown Trainer")")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let finalOdds = entry.finalOdds {
                    Text(String(format: "%.1f-1", finalOdds))
                        .font(.title3)
                        .fontWeight(.semibold)
                } else {
                    Text(String(format: "%.1f-1", entry.morningLineOdds))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if let finishPosition = entry.finishPosition {
                HStack {
                    Text("Finished: \(finishPosition.ordinal)")
                        .font(.caption)
                    if let beatenLengths = entry.beatenLengths, beatenLengths > 0 {
                        Text("(\(String(format: "%.1f", beatenLengths)) lengths)")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}



#Preview {
    RaceDetailView(
        race: Race(
            track: "Sample Track",
            date: Date(),
            raceNumber: 1,
            distance: "6f",
            surface: "Dirt",
            purse: 50000,
            raceClass: "Maiden Special Weight",
            conditions: "For three year olds and upward"
        )
    )
    .modelContainer(for: [Race.self, Horse.self, Jockey.self, Trainer.self, RaceEntry.self], inMemory: true)
}
