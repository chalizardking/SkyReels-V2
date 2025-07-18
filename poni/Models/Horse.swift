import SwiftUI
import SwiftData

struct AgePerformanceData: Codable {
    let age: Int
    let performanceRating: Double
    let winsAtAge: Int
    let startsAtAge: Int
    let earningsAtAge: Double
    let averageSpeedAtAge: Double
    let classLevelAtAge: String
    let peakPerformanceIndicator: Bool
}

@Model
final class Horse {
    var id: String
    var name: String
    var age: Int
    var sex: String?
    var sire: String?
    var dam: String?
    var trainer: String
    var owner: String?
    var breeder: String?
    var starts: Int
    var wins: Int
    var places: Int
    var shows: Int
    var earnings: Double
    var lastRaced: Date?
    var bestTimeAtDistance: [String: TimeInterval]
    var preferredDistance: String?
    var preferredSurface: String?
    var isFavorite: Bool
    
    // Performance Tracking
    var bestClassLevel: Int
    var averageClassLevel: Double
    var classMovementTrend: String
    var stakesWins: Int
    var gradedStakesWins: Int
    var agePerformanceHistory: [AgePerformanceData]
    var peakAge: Int?
    var currentFormTrend: String
    
    @Relationship(deleteRule: .nullify, inverse: \RaceEntry.horse) var entries: [RaceEntry]?
    
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
        self.bestTimeAtDistance = [:]
        self.isFavorite = false
        
        // Initialize Performance Tracking
        self.bestClassLevel = 1
        self.averageClassLevel = 1.0
        self.classMovementTrend = "Developing"
        self.stakesWins = 0
        self.gradedStakesWins = 0
        self.agePerformanceHistory = []
        self.peakAge = nil
        self.currentFormTrend = "Developing"
        self.entries = []
    }
}
