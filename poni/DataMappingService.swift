//
//  DataMappingService.swift
//  poni
//
//  Created by Assistant on 2024
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Data Mapping Service Protocol
protocol DataMappingServiceProtocol {
    func mapAPIHorseDataToHorse(_ apiHorse: APIHorseData, with results: [APIRaceResult]) -> Horse
    func mapAPIJockeyStatsToJockey(_ apiStats: APIJockeyStats) -> Jockey
    func mapAPITrainerStatsToTrainer(_ apiStats: APITrainerStats) -> Trainer
    func mapAPIRacecardToRace(_ apiRacecard: APIRacecard) -> Race
    func mapAPIRaceResultToRaceEntry(_ result: APIRaceResult, horse: Horse, jockey: Jockey, trainer: Trainer) -> RaceEntry?
}

// MARK: - Data Mapping Service Implementation
class DataMappingService: DataMappingServiceProtocol {
    static let shared = DataMappingService()
    
    private init() {}
    
    // MARK: - Map API Horse Data to App Horse
    func mapAPIHorseDataToHorse(_ apiHorse: APIHorseData, with results: [APIRaceResult] = []) -> Horse {
        let horse = Horse(
            name: apiHorse.horse,
            age: apiHorse.age ?? 0,
            trainer: apiHorse.trainer ?? "Unknown",
            starts: results.count,
            wins: countWins(from: results),
            places: countPlaces(from: results),
            shows: countShows(from: results),
            earnings: calculateEarnings(from: results)
        )
        
        // Set optional properties
        horse.id = apiHorse.horse_id
        horse.sire = apiHorse.sire
        horse.dam = apiHorse.dam
        horse.owner = apiHorse.owner
        horse.sex = mapSex(apiHorse.sex)
        horse.lastRaced = getLastRaceDate(from: results)
        
        return horse
    }
    
    // MARK: - Map API Jockey Stats to Jockey
    func mapAPIJockeyStatsToJockey(_ apiStats: APIJockeyStats) -> Jockey {
        let jockey = Jockey(
            id: apiStats.jockey_id,
            name: apiStats.jockey,
            wins: apiStats.wins,
            places: 0, // Not provided in API
            shows: 0,  // Not provided in API
            totalMounts: apiStats.runs
        )
        
        // Calculate win percentage
        jockey.winPercentage = apiStats.win_percentage
        jockey.roi30Days = apiStats.roi
        jockey.roi90Days = 0 // Not provided in API
        jockey.roi1Year = 0  // Not provided in API
        
        return jockey
    }
    
    // MARK: - Map API Trainer Stats to Trainer
    func mapAPITrainerStatsToTrainer(_ apiStats: APITrainerStats) -> Trainer {
        let trainer = Trainer(
            id: apiStats.trainer_id,
            name: apiStats.trainer,
            wins: apiStats.wins,
            places: 0, // Not provided in API
            shows: 0,  // Not provided in API
            totalStarts: apiStats.runs
        )
        
        // Calculate win percentage
        trainer.winPercentage = apiStats.win_percentage
        trainer.roi30Days = apiStats.roi
        trainer.roi90Days = 0 // Not provided in API
        trainer.roi1Year = 0  // Not provided in API
        
        return trainer
    }
    
    // MARK: - Map API Racecard to App Race
    func mapAPIRacecardToRace(_ apiRacecard: APIRacecard) -> Race {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let raceDate = dateFormatter.date(from: apiRacecard.date) ?? Date()
        
        let race = Race(
            track: apiRacecard.course,
            date: raceDate,
            raceNumber: 1, // Not provided in API
            distance: apiRacecard.distance,
            surface: mapSurface(from: apiRacecard.going),
            purse: 0, // Not provided in API
            raceClass: apiRacecard.race_class ?? "Unknown",
            conditions: apiRacecard.race_name
        )
        
        race.name = apiRacecard.race_name
        
        return race
    }
    
    // MARK: - Map API Race Result to Race Entry
    func mapAPIRaceResultToRaceEntry(_ result: APIRaceResult, horse: Horse, jockey: Jockey, trainer: Trainer) -> RaceEntry? {
        guard let position = Int(result.position) else { return nil }
        
        let entry = RaceEntry(
            horse: horse,
            jockey: jockey,
            trainer: trainer,
            postPosition: 0, // Not provided in API
            morningLineOdds: parseOdds(result.odds)
        )
        
        entry.finishPosition = position
        entry.finalOdds = parseOdds(result.odds)
        entry.finalTime = parseTime(result.time)
        
        return entry
    }
    
    // MARK: - Helper Functions
    private func countWins(from results: [APIRaceResult]) -> Int {
        results.filter { $0.position == "1" }.count
    }
    
    private func countPlaces(from results: [APIRaceResult]) -> Int {
        results.filter { $0.position == "2" }.count
    }
    
    private func countShows(from results: [APIRaceResult]) -> Int {
        results.filter { $0.position == "3" }.count
    }
    
    private func calculateEarnings(from results: [APIRaceResult]) -> Double {
        results.compactMap { result in
            guard let prize = result.prize else { return 0.0 }
            // Remove currency symbols and commas, then convert to Double
            let numericString = prize.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
            return Double(numericString) ?? 0.0
        }.reduce(0.0, +)
    }
    
    private func getLastRaceDate(from results: [APIRaceResult]) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dates = results.compactMap { dateFormatter.date(from: $0.date) }
        return dates.max()
    }
    
    private func mapSex(_ sex: String?) -> String {
        guard let sex = sex?.lowercased() else { return "Unknown" }
        
        switch sex {
        case "c": return "Colt"
        case "f": return "Filly"
        case "g": return "Gelding"
        case "m": return "Mare"
        case "r": return "Rig"
        case "h": return "Horse"
        default: return "Unknown"
        }
    }
    
    private func mapSurface(from going: String?) -> String {
        guard let going = going?.lowercased() else { return "Dirt" }
        
        if going.contains("turf") || going.contains("yielding") || going.contains("soft") || going.contains("firm") {
            return "Turf"
        } else if going.contains("all weather") || going.contains("synthetic") {
            return "Synthetic"
        } else {
            return "Dirt"
        }
    }
    
    private func parseOdds(_ oddsString: String?) -> Double {
        guard let oddsString = oddsString, !oddsString.isEmpty else { return 0.0 }
        
        // Handle fractional odds (e.g., "5/2")
        if oddsString.contains("/") {
            let components = oddsString.components(separatedBy: "/")
            if components.count == 2, 
               let numerator = Double(components[0]),
               let denominator = Double(components[1]),
               denominator != 0 {
                return numerator / denominator + 1.0
            }
        }
        
        // Handle decimal odds (e.g., "3.50")
        if let decimalOdds = Double(oddsString) {
            return decimalOdds
        }
        
        return 0.0
    }
    
    private func parseTime(_ timeString: String?) -> TimeInterval? {
        guard let timeString = timeString, !timeString.isEmpty else { return nil }
        
        // Handle time in format "1:23.45"
        let components = timeString.components(separatedBy: ":")
        if components.count == 2,
           let minutes = Double(components[0]),
           let seconds = Double(components[1]) {
            return minutes * 60 + seconds
        }
        
        // Handle time in seconds "83.45"
        if let seconds = Double(timeString) {
            return seconds
        }
        
        return nil
    }
    
    // MARK: - ROI Mapping Methods
    func mapAPIJockeyStatsToROI(_ apiStats: APIJockeyStats) -> JockeyROIData {
        return JockeyROIData(
            name: apiStats.jockey,
            roi30Days: apiStats.roi,
            roi90Days: 0.0, // Not provided in API
            roi1Year: 0.0,  // Not provided in API
            winPercentage: apiStats.win_percentage
        )
    }
    
    func mapAPITrainerStatsToROI(_ apiStats: APITrainerStats) -> TrainerROIData {
        return TrainerROIData(
            name: apiStats.trainer,
            roi30Days: apiStats.roi,
            roi90Days: 0.0, // Not provided in API
            roi1Year: 0.0,  // Not provided in API
            winPercentage: apiStats.win_percentage
        )
    }
    
    // MARK: - Alternative Method Names
    func mapAPIHorseToHorse(_ apiHorse: APIHorseData, with results: [APIRaceResult] = []) -> Horse {
        return mapAPIHorseDataToHorse(apiHorse, with: results)
    }
    
    func mapAPIRaceToRace(_ apiRacecard: APIRacecard) -> Race {
        return mapAPIRacecardToRace(apiRacecard)
    }
}
