//
//  DataStructures.swift
//  poni
//
//  Created by Assistant on 2024
//

import Foundation

// MARK: - Shared Data Structures

// MARK: - Race History (replaces BeyerSpeedEntry since Beyer data not available)
struct RaceHistoryEntry: Codable {
    let date: Date
    let track: String
    let distance: String
    let raceClass: String
    let finishPosition: Int
    let prize: String
}

struct PaceAnalysis: Codable {
    let earlyPace: String // "Fast", "Moderate", "Slow"
    let midPace: String
    let latePace: String
    let overallPaceRating: Double // 1-10 scale
    let fractionalTimes: [String]
    let paceVariance: Double
    let energyDistribution: String // "Front-loaded", "Even", "Back-loaded"
}

struct RaceClassAnalysis: Codable {
    let className: String
    let classLevel: Int // 1-10 scale, 10 being highest
    let purseRange: String
    let competitionLevel: String // "Maiden", "Claiming", "Allowance", "Stakes", "Graded Stakes"
    let fieldQuality: Double // Average rating of competitors
    let classMovement: String // "Step Up", "Same Level", "Step Down"
}

struct JockeyROIData: Codable {
    let name: String
    let roi30Days: Double
    let roi90Days: Double
    let roi1Year: Double
    let winPercentage: Double
    // Removed placePercentage, showPercentage, averageOdds - not available from current API
}

struct TrainerROIData: Codable {
    let name: String
    let roi30Days: Double
    let roi90Days: Double
    let roi1Year: Double
    let winPercentage: Double
    // Removed placePercentage, showPercentage, averageOdds, specialtyStats - not available from current API
}

struct BreedingInfo: Codable {
    let horseName: String
    let sire: String
    let dam: String
    // Removed advanced breeding fields - not available from current API
    // Would need specialized breeding database integration for:
    // damsire, broodmareSire, family, inbreeding, dosageProfile,
    // chefDeRaceIndex, aptitudeIndex, speedIndex, staminaIndex
}

struct PedigreeAnalysis: Codable {
    let horseName: String
    let pedigreeRating: String
    let strengthAreas: [String]
    let weaknessAreas: [String]
    let optimalDistance: String
    let surfacePreference: String
    let classLevel: String
    let breedingValue: Double
    let geneticPotential: String
    
    init(horseName: String = "Unknown",
         pedigreeRating: String = "Not Available",
         strengthAreas: [String] = [],
         weaknessAreas: [String] = [],
         optimalDistance: String = "Unknown",
         surfacePreference: String = "Unknown",
         classLevel: String = "Unknown",
         breedingValue: Double = 0.0,
         geneticPotential: String = "Unknown") {
        self.horseName = horseName
        self.pedigreeRating = pedigreeRating
        self.strengthAreas = strengthAreas
        self.weaknessAreas = weaknessAreas
        self.optimalDistance = optimalDistance
        self.surfacePreference = surfacePreference
        self.classLevel = classLevel
        self.breedingValue = breedingValue
        self.geneticPotential = geneticPotential
    }
}