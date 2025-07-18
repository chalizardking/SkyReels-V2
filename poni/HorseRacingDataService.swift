//
//  HorseRacingDataService.swift
//  poni
//
//  Created by Cha Lizardking on 7/7/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class HorseRacingDataService {
    static let shared = HorseRacingDataService()
    
    private let baseURL = "https://api.horseracing.com/v1"
    private let apiKey = "YOUR_API_KEY_HERE" // Replace with actual API key
    
    private init() {}
    
    // MARK: - Horse Data Fetching
    
    func fetchHorseDetails(horseName: String) async throws -> Horse? {
        let url = URL(string: "\(baseURL)/horses/\(horseName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        guard let url = url else { throw HorseRacingError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let horseData = try JSONDecoder().decode(HorseAPIResponse.self, from: data)
        
        return createHorseFromAPI(horseData)
    }
    
    func fetchRaceHistory(horseName: String) async throws -> [RaceHistoryEntry] {
        let url = URL(string: "\(baseURL)/horses/\(horseName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")/races")
        guard let url = url else { throw HorseRacingError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let raceData = try JSONDecoder().decode([RaceHistoryEntry].self, from: data)
        
        return raceData
    }
    
    // MARK: - Jockey Data Fetching
    
    func fetchJockeyROI(jockeyName: String) async throws -> JockeyROIData {
        let url = URL(string: "\(baseURL)/jockeys/\(jockeyName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")/roi")
        guard let url = url else { throw HorseRacingError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let roiData = try JSONDecoder().decode(JockeyROIData.self, from: data)
        
        return roiData
    }
    
    func fetchJockeyStats(jockeyName: String) async throws -> Jockey? {
        let url = URL(string: "\(baseURL)/jockeys/\(jockeyName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        guard let url = url else { throw HorseRacingError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let jockeyData = try JSONDecoder().decode(JockeyAPIResponse.self, from: data)
        
        return createJockeyFromAPI(jockeyData)
    }
    
    // MARK: - Trainer Data Fetching
    
    func fetchTrainerROI(trainerName: String) async throws -> TrainerROIData {
        let url = URL(string: "\(baseURL)/trainers/\(trainerName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")/roi")
        guard let url = url else { throw HorseRacingError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let roiData = try JSONDecoder().decode(TrainerROIData.self, from: data)
        
        return roiData
    }
    
    func fetchTrainerStats(trainerName: String) async throws -> Trainer? {
        let url = URL(string: "\(baseURL)/trainers/\(trainerName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        guard let url = url else { throw HorseRacingError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let trainerData = try JSONDecoder().decode(TrainerAPIResponse.self, from: data)
        
        return createTrainerFromAPI(trainerData)
    }
    
    // MARK: - Breeding Information
    // Note: BreedingInfo and PedigreeAnalysis types need to be defined
    
    /*
    func fetchBreedingInfo(horseName: String) async throws -> BreedingInfo {
        let url = URL(string: "\(baseURL)/horses/\(horseName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")/breeding")
        guard let url = url else { throw HorseRacingError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let breedingData = try JSONDecoder().decode(BreedingInfo.self, from: data)
        
        return breedingData
    }
    
    func fetchPedigreeAnalysis(horseName: String) async throws -> PedigreeAnalysis {
        let url = URL(string: "\(baseURL)/horses/\(horseName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")/pedigree")
        guard let url = url else { throw HorseRacingError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let pedigreeData = try JSONDecoder().decode(PedigreeAnalysis.self, from: data)
        
        return pedigreeData
    }
    */
    
    // MARK: - Race Data
    
    func fetchUpcomingRaces() async throws -> [Race] {
        let url = URL(string: "\(baseURL)/races/upcoming")
        guard let url = url else { throw HorseRacingError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let raceData = try JSONDecoder().decode([RaceAPIResponse].self, from: data)
        
        return raceData.map { createRaceFromAPI($0) }
    }
    
    // MARK: - Helper Methods
    
    private func createHorseFromAPI(_ apiResponse: HorseAPIResponse) -> Horse {
        let horse = Horse(
            name: apiResponse.name,
            age: apiResponse.age,
            trainer: apiResponse.trainer,
            starts: apiResponse.starts,
            wins: apiResponse.wins,
            places: apiResponse.places,
            shows: apiResponse.shows,
            earnings: apiResponse.earnings
        )
        
        // Set additional properties
        horse.sire = apiResponse.sire
        horse.dam = apiResponse.dam
        horse.owner = apiResponse.owner
        horse.color = apiResponse.color
        horse.sex = apiResponse.sex
        horse.foalingDate = apiResponse.foalingDate
        horse.pedigreeRating = apiResponse.pedigreeRating
        horse.breedingValue = apiResponse.breedingValue
        
        return horse
    }
    
    private func createJockeyFromAPI(_ apiResponse: JockeyAPIResponse) -> Jockey {
        let jockey = Jockey(
            name: apiResponse.name,
            wins: apiResponse.wins,
            totalMounts: apiResponse.starts
        )
        
        jockey.winPercentage = apiResponse.winPercentage
        
        return jockey
    }
    
    private func createTrainerFromAPI(_ apiResponse: TrainerAPIResponse) -> Trainer {
        let trainer = Trainer(
            name: apiResponse.name,
            wins: apiResponse.wins,
            totalStarts: apiResponse.starts
        )
        
        trainer.winPercentage = apiResponse.winPercentage
        
        return trainer
    }
    
    private func createRaceFromAPI(_ apiResponse: RaceAPIResponse) -> Race {
        let race = Race(
            track: apiResponse.track,
            date: apiResponse.date,
            raceNumber: 1, // Default race number
            distance: apiResponse.distance,
            surface: apiResponse.surface,
            purse: apiResponse.purse,
            raceClass: apiResponse.raceClass,
            conditions: apiResponse.conditions
        )
        
        return race
    }
}

// MARK: - API Response Models

struct HorseAPIResponse: Codable {
    let name: String
    let age: Int
    let sire: String
    let dam: String
    let trainer: String
    let owner: String
    let color: String
    let sex: String
    let foalingDate: Date
    let earnings: Double
    let starts: Int
    let wins: Int
    let places: Int
    let shows: Int
    // Beyer Speed data not available from current API
    let pedigreeRating: String
    let breedingValue: Double
}

struct JockeyAPIResponse: Codable {
    let name: String
    let weight: Double
    let experience: Int
    let wins: Int
    let starts: Int
    let winPercentage: Double
    let roi: Double
    let earnings: Double
    let currentMounts: Int
}

struct TrainerAPIResponse: Codable {
    let name: String
    let stableSize: Int
    let yearsActive: Int
    let wins: Int
    let starts: Int
    let winPercentage: Double
    let roi: Double
    let earnings: Double
    let specialties: [String]
}

struct RaceAPIResponse: Codable {
    let name: String
    let date: Date
    let track: String
    let distance: String
    let surface: String
    let raceClass: String
    let purse: Double
    let conditions: String
    let weather: String
    let trackCondition: String
}

// Note: Data structures are now in DataStructures.swift

// MARK: - Error Handling

enum HorseRacingError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}