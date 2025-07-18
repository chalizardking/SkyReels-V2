import SwiftUI
import SwiftData

struct AgePerformanceData: Codable {
    let age: Int
    let startsAtAge: Int
    let winsAtAge: Int
    let earningsAtAge: Double
    let peakPerformanceIndicator: Bool
}

@Model
class Horse {
    // MARK: - Basic Information
    var id: String = UUID().uuidString
var name: String = ""
var age: Int = 0
var sex: String?
var color: String?
var foalingDate: Date = Date()

    // MARK: - Connections
var sire: String?
var dam: String?
var trainer: String = ""
var jockey: String?
var owner: String?
var breeder: String?
    
    // MARK: - Performance
var starts: Int = 0
var wins: Int = 0
var places: Int = 0
var shows: Int = 0
var earnings: Double = 0.0
var lastRaced: Date?
var bestTimeAtDistance: [String: TimeInterval] = [:]
var preferredDistance: String?
var preferredSurface: String?
    
    // MARK: - Analytics Properties
var bestClassLevel: Int = 0
var averageClassLevel: Double = 0.0
var classMovementTrend: String = "Stable"
var stakesWins: Int = 0
var gradedStakesWins: Int = 0
var pacePreference: String = "Unknown"
var bestPaceScenario: String = "Unknown"
var paceVersatility: Double = 0.0
var currentFormTrend: String = "Unknown"
var peakAge: Int?
var agePerformanceHistory: [AgePerformanceData] = []
    
    // MARK: - Breeding Information
var pedigreeRating: String?
var breedingValue: Double = 0.0
    
    // MARK: - UI State
var isFavorite: Bool = false
    @Relationship(inverse: \RaceEntry.horse) var raceEntries: [RaceEntry] = []
    
    init(id: String = UUID().uuidString,
         name: String,
         age: Int,
         trainer: String,
         starts: Int = 0,
         wins: Int = 0,
         places: Int = 0,
         shows: Int = 0,
         earnings: Double = 0) {
        self.id = id
        self.name = name
        self.age = age
        self.trainer = trainer
        self.starts = starts
        self.wins = wins
        self.places = places
        self.shows = shows
        self.earnings = earnings
        self.foalingDate = Date() // Default to current date, should be set properly
        self.bestTimeAtDistance = [:]
        self.breedingValue = 0.0
        self.isFavorite = false
    }
    
    // MARK: - Performance Calculations
    var winRate: Double {
        guard starts > 0 else { return 0.0 }
        return Double(wins) / Double(starts) * 100
    }
    
    var inTheMoneyRate: Double {
        guard starts > 0 else { return 0.0 }
        return Double(wins + places + shows) / Double(starts) * 100
    }
    
    var averageEarningsPerStart: Double {
        guard starts > 0 else { return 0.0 }
        return earnings / Double(starts)
    }
}
