//
//  APIUsageExamples.swift
//  poni
//
//  Created by Assistant on 2024
//

import Foundation
import SwiftUI

// MARK: - API Usage Examples
// This file demonstrates how to use the implemented API methods
// in various scenarios within the horse racing app

@MainActor
class APIUsageExamples {
    private let dataSourceManager = DataSourceManager.shared
    private let realDataService = RealDataService.shared
    private let mappingService = DataMappingService.shared
    
    // MARK: - Basic Setup Examples
    
    /// Example: Configure API key and validate connection
    func setupAPIExample() async {
        // 1. Configure API key
        let apiKey = "your-rapidapi-key-here"
        let isConfigured = dataSourceManager.configureAPIKey(apiKey)
        
        if isConfigured {
            print("✅ API key configured successfully")
            
            // 2. Test connection
            let isConnected = realDataService.isConnected
            if isConnected {
                print("✅ Connected to Horse Racing USA API")
            } else {
                print("❌ Failed to connect to API")
            }
        } else {
            print("❌ Invalid API key format")
        }
    }
    
    // MARK: - Race Data Examples
    
    /// Example: Fetch and display today's races
    func fetchTodaysRacesExample() async {
        do {
            let races = try await realDataService.fetchTodaysRaces()
            print("📅 Found \(races.count) races today:")
            
            for race in races.prefix(3) { // Show first 3 races
                print("🏇 \(race.race_name) at \(race.course)")
                print("   Time: \(race.race_time)")
                print("   Runners: \(race.runners.count)")
                
                // Show top 3 runners
                for runner in race.runners.prefix(3) {
                    print("   - \(runner.horse) (\(runner.jockey ?? "Unknown jockey"))")
                }
                print("")
            }
        } catch {
            print("❌ Error fetching today's races: \(error.localizedDescription)")
        }
    }
    
    /// Example: Fetch race results and analyze performance
    func fetchRaceResultsExample() async {
        do {
            let racecards = try await realDataService.fetchRaceResults()
            print("📊 Found \(racecards.count) race cards")
            
            // Analyze race information
            let totalRunners = racecards.reduce(0) { $0 + $1.runners.count }
            print("🏇 Total runners across all races: \(totalRunners)")
            
            // Group by course
            let courseRaces = Dictionary(grouping: racecards) { $0.course }
            let topCourses = courseRaces.sorted { $0.value.count > $1.value.count }.prefix(5)
            
            print("🏁 Top Courses by Race Count:")
            for (course, races) in topCourses {
                print("   \(course): \(races.count) races")
            }
        } catch {
            print("❌ Error fetching race results: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Horse Data Examples
    
    /// Example: Search for horses and get detailed information
    func searchHorsesExample() async {
        do {
            // Search for horses (empty query returns recent horses)
            let horses = try await realDataService.searchHorses(query: "")
            print("🐎 Found \(horses.count) horses")
            
            guard let firstHorse = horses.first else {
                print("No horses found")
                return
            }
            
            print("\n📋 Horse Details for: \(firstHorse.horse)")
            
            // Get detailed horse information
            let horseDetails = try await realDataService.fetchHorseDetails(horseId: firstHorse.horse_id)
            print("   Age: \(horseDetails.age ?? 0)")
            print("   Sex: \(horseDetails.sex ?? "Unknown")")
            print("   Trainer: \(horseDetails.trainer ?? "Unknown")")
            
            // Get horse's race history
            let horseResults = try await realDataService.fetchHorseResults(horseId: firstHorse.horse_id)
            print("   Race History: \(horseResults.count) races")
            
            // Map to app model
            let mappedHorse = mappingService.mapAPIHorseDataToHorse(horseDetails, with: horseResults)
            print("   Mapped Stats - Starts: \(mappedHorse.starts), Wins: \(mappedHorse.wins)")
            
        } catch {
            print("❌ Error in horse search: \(error.localizedDescription)")
        }
    }
    
    /// Example: Analyze horse performance trends
    func analyzeHorsePerformanceExample() async {
        do {
            let horses = try await realDataService.searchHorses(query: "")
            
            for horse in horses.prefix(3) {
                let results = try await realDataService.fetchHorseResults(horseId: horse.horse_id)
                
                // Calculate recent form (last 5 races)
                    let recentRaces = results.prefix(5)
                    let recentWins = recentRaces.filter { $0.position == "1" }.count
                    let recentPlaces = recentRaces.filter { Int($0.position) ?? 99 <= 3 }.count
                
                print("🐎 \(horse.horse) Recent Form:")
                print("   Last 5 races: \(recentWins) wins, \(recentPlaces) places")
                print("   Win rate: \(String(format: "%.1f", Double(recentWins) / Double(recentRaces.count) * 100))%")
                print("")
                
                // Add delay for rate limiting
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        } catch {
            print("❌ Error analyzing horse performance: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Jockey & Trainer Examples
    
    /// Example: Fetch and analyze jockey statistics
    func analyzeJockeyStatsExample() async {
        do {
            // Get jockeys from today's races
            let races = try await realDataService.fetchTodaysRaces()
            let jockeys = Set(races.flatMap { $0.runners.compactMap { $0.jockey } })
            
            print("👤 Analyzing \(jockeys.count) jockeys:")
            
            var jockeyStats: [(String, APIJockeyStats)] = []
            
            for jockey in jockeys.prefix(5) { // Limit to 5 for demo
                let stats = try await realDataService.fetchJockeyStats(jockeyId: jockey)
                jockeyStats.append((jockey, stats))
                
                print("   \(jockey): \(stats.wins)/\(stats.runs) (\(String(format: "%.1f", stats.win_percentage))%)")
                
                // Map to ROI data
                let roiData = mappingService.mapAPIJockeyStatsToROI(stats)
                print("     ROI 30d: \(String(format: "%.2f", roiData.roi30Days))")
                
                // Rate limiting
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
            
            // Find best performing jockey
            let bestJockey = jockeyStats.max { $0.1.win_percentage < $1.1.win_percentage }
            if let best = bestJockey {
                print("\n🏆 Best Jockey: \(best.0) (\(String(format: "%.1f", best.1.win_percentage))% win rate)")
            }
            
        } catch {
            print("❌ Error analyzing jockey stats: \(error.localizedDescription)")
        }
    }
    
    /// Example: Compare trainer performance
    func compareTrainerPerformanceExample() async {
        do {
            let races = try await realDataService.fetchTodaysRaces()
            let trainers = Set(races.flatMap { $0.runners.compactMap { $0.trainer } })
            
            print("🎯 Comparing \(trainers.count) trainers:")
            
            var trainerComparison: [(String, Double, Double)] = [] // (name, winRate, roi)
            
            for trainer in trainers.prefix(5) {
                let stats = try await realDataService.fetchTrainerStats(trainerId: trainer)
                let roiData = mappingService.mapAPITrainerStatsToROI(stats)
                
                trainerComparison.append((trainer, stats.win_percentage, roiData.roi30Days))
                
                print("   \(trainer):")
                print("     Win Rate: \(String(format: "%.1f", stats.win_percentage))%")
                print("     ROI 30d: \(String(format: "%.2f", roiData.roi30Days))")
                
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
            
            // Sort by ROI
            let sortedByROI = trainerComparison.sorted { $0.2 > $1.2 }
            print("\n💰 Best ROI Trainers:")
            for (trainer, _, roi) in sortedByROI.prefix(3) {
                print("   \(trainer): \(String(format: "%.2f", roi))")
            }
            
        } catch {
            print("❌ Error comparing trainers: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Advanced Analysis Examples
    
    /// Example: Comprehensive race analysis
    func comprehensiveRaceAnalysisExample() async {
        do {
            let races = try await realDataService.fetchTodaysRaces()
            
            guard let targetRace = races.first else {
                print("No races available for analysis")
                return
            }
            
            print("🔍 Comprehensive Analysis: \(targetRace.race_name)")
            print("📍 Track: \(targetRace.course)")
            print("⏰ Time: \(targetRace.race_time)")
            print("🏇 Runners: \(targetRace.runners.count)")
            print("")
            
            // Analyze each runner
            for (index, runner) in targetRace.runners.enumerated() {
                print("\(index + 1). \(runner.horse)")
                
                // Get horse details and history
                let horseId = runner.horse_id
                let horseDetails = try await realDataService.fetchHorseDetails(horseId: horseId)
                let horseResults = try await realDataService.fetchHorseResults(horseId: horseId)
                
                // Calculate form
                let recentRaces = horseResults.prefix(5)
                let wins = recentRaces.filter { $0.position == "1" }.count
                let places = recentRaces.filter { Int($0.position) ?? 99 <= 3 }.count
                
                print("   Age: \(horseDetails.age ?? 0), Recent: \(wins)W-\(places)P from \(recentRaces.count)")
                
                // Get jockey stats
                if let jockey = runner.jockey {
                    let jockeyStats = try await realDataService.fetchJockeyStats(jockeyId: jockey)
                    print("   Jockey: \(jockey) (\(String(format: "%.1f", jockeyStats.win_percentage))%)")
                }
                
                // Get trainer stats
                if let trainer = runner.trainer {
                    let trainerStats = try await realDataService.fetchTrainerStats(trainerId: trainer)
                    print("   Trainer: \(trainer) (\(String(format: "%.1f", trainerStats.win_percentage))%)")
                }
                
                print("")
                
                // Rate limiting - important!
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            }
            
        } catch {
            print("❌ Error in comprehensive analysis: \(error.localizedDescription)")
        }
    }
    
    /// Example: Track performance analysis
    func trackPerformanceAnalysisExample() async {
        do {
            let races = try await realDataService.fetchTodaysRaces()
            let tracks = Set(races.map { $0.course })
            
            print("🏁 Track Performance Analysis")
            print("Analyzing \(tracks.count) tracks today:")
            
            for track in tracks {
                let trackRaces = races.filter { $0.course == track }
                let totalRunners = trackRaces.reduce(0) { $0 + $1.runners.count }
                
                print("\n📍 \(track):")
                print("   Races: \(trackRaces.count)")
                print("   Total Runners: \(totalRunners)")
                print("   Avg Field Size: \(String(format: "%.1f", Double(totalRunners) / Double(trackRaces.count)))")
                
                // Analyze race times
                let raceTimes = trackRaces.map { $0.race_time }
                print("   Race Times: \(raceTimes.joined(separator: ", "))")
            }
            
        } catch {
            print("❌ Error in track analysis: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Error Handling Examples
    
    /// Example: Proper error handling patterns
    func errorHandlingExample() async {
        // Example 1: Handle API key errors
        do {
            let races = try await realDataService.fetchTodaysRaces()
            print("✅ Successfully fetched \(races.count) races")
        } catch APIError.unauthorized {
            print("❌ Invalid API key - please check your RapidAPI key")
        } catch APIError.rateLimitExceeded {
            print("⏳ Rate limit exceeded - please wait before making more requests")
        } catch APIError.networkError(let message) {
            print("🌐 Network error: \(message)")
        } catch APIError.noData {
            print("📭 No data available")
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
        }
        
        // Example 2: Handle data source manager errors
        do {
            let horses = try await realDataService.searchHorses(query: "test")
            print("✅ Successfully searched horses: \(horses.count) results")
        } catch {
            print("DataSourceManager error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Performance Optimization Examples
    
    /// Example: Batch operations with rate limiting
    func batchOperationsExample() async {
        do {
            let horses = try await realDataService.searchHorses(query: "")
            print("🔄 Processing \(horses.count) horses in batches...")
            
            // Process in batches of 5 to respect rate limits
            let batchSize = 5
            let batches = horses.chunked(into: batchSize)
            
            for (batchIndex, batch) in batches.enumerated() {
                print("\nProcessing batch \(batchIndex + 1)/\(batches.count)...")
                
                // Process batch concurrently but with delays
                for horse in batch {
                    let results = try await realDataService.fetchHorseResults(horseId: horse.horse_id)
                    print("  \(horse.horse): \(results.count) results")
                    
                    // Rate limiting delay
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                }
                
                // Longer delay between batches
                if batchIndex < batches.count - 1 {
                    try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                }
            }
            
        } catch {
            print("❌ Error in batch operations: \(error.localizedDescription)")
        }
    }
    
    /// Example: Caching and data persistence
    func cachingExample() async {
        // This would typically involve Core Data or UserDefaults
        // For demonstration, we'll show the concept
        
        let cacheKey = "todaysRaces_\(DateFormatter.yyyyMMdd.string(from: Date()))"
        
        // Check cache first (pseudo-code)
        if let cachedData = UserDefaults.standard.data(forKey: cacheKey),
           let cachedRaces = try? JSONDecoder().decode([APIRacecard].self, from: cachedData) {
            print("📦 Using cached data: \(cachedRaces.count) races")
            return
        }
        
        // Fetch fresh data
        do {
            let races = try await realDataService.fetchTodaysRaces()
            print("🔄 Fetched fresh data: \(races.count) races")
            
            // Cache the data (pseudo-code)
            if let encodedData = try? JSONEncoder().encode(races) {
                UserDefaults.standard.set(encodedData, forKey: cacheKey)
                print("💾 Data cached for future use")
            }
        } catch {
            print("❌ Error fetching fresh data: \(error.localizedDescription)")
        }
    }
}

// MARK: - Helper Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// MARK: - Usage in SwiftUI Views

struct APIExampleView: View {
    @State private var isLoading = false
    @State private var results = ""
    
    private let examples = APIUsageExamples()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text(results)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                }
                
                Button("Run Example") {
                    Task {
                        isLoading = true
                        await examples.fetchTodaysRacesExample()
                        isLoading = false
                    }
                }
                .disabled(isLoading)
            }
            .navigationTitle("API Examples")
        }
    }
}