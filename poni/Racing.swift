import SwiftUI
import SwiftData

@Model
class Jockey {
    var id: String = UUID().uuidString
    var name: String = ""
    var wins: Int = 0
    var places: Int = 0
    var shows: Int = 0
    var totalMounts: Int = 0
    var winPercentage: Double = 0.0
    var roi30Days: Double = 0.0
    var roi90Days: Double = 0.0
    var roi1Year: Double = 0.0
    @Relationship(inverse: \RaceEntry.jockey) var raceEntries: [RaceEntry] = []
    
    init(id: String = UUID().uuidString,
         name: String,
         wins: Int = 0,
         places: Int = 0,
         shows: Int = 0,
         totalMounts: Int = 0) {
        self.id = id
        self.name = name
        self.wins = wins
        self.places = places
        self.shows = shows
        self.totalMounts = totalMounts
        self.winPercentage = totalMounts > 0 ? Double(wins) / Double(totalMounts) * 100 : 0
        self.roi30Days = 0
        self.roi90Days = 0
        self.roi1Year = 0
    }
}

@Model
class Trainer {
    var id: String = UUID().uuidString
    var name: String = ""
    var wins: Int = 0
    var places: Int = 0
    var shows: Int = 0
    var totalStarts: Int = 0
    var winPercentage: Double = 0.0
    var roi30Days: Double = 0.0
    var roi90Days: Double = 0.0
    var roi1Year: Double = 0.0
    @Relationship(inverse: \RaceEntry.trainer) var raceEntries: [RaceEntry] = []
    
    init(id: String = UUID().uuidString,
         name: String,
         wins: Int = 0,
         places: Int = 0,
         shows: Int = 0,
         totalStarts: Int = 0) {
        self.id = id
        self.name = name
        self.wins = wins
        self.places = places
        self.shows = shows
        self.totalStarts = totalStarts
        self.winPercentage = totalStarts > 0 ? Double(wins) / Double(totalStarts) * 100 : 0
        self.roi30Days = 0
        self.roi90Days = 0
        self.roi1Year = 0
    }
}

@Model
class Race {
    var id: String = UUID().uuidString
    var track: String = ""
    var date: Date = Date()
    var raceNumber: Int = 0
    var distance: String = ""
    var surface: String = ""
    var purse: Double = 0.0
    var raceClass: String = ""
    var conditions: String = ""
    @Relationship(deleteRule: .cascade, inverse: \RaceEntry.race) var entries: [RaceEntry] = []
    
    // New properties for race analysis
    var name: String = ""
    var classLevel: Int = 0
    var competitionLevel: String = "Unknown"
    var paceAnalysis: String = "Unknown"
    var energyDistribution: String = "Unknown"
    
    init(id: String = UUID().uuidString,
         track: String,
         date: Date,
         raceNumber: Int,
         distance: String,
         surface: String,
         purse: Double,
         raceClass: String,
         conditions: String) {
        self.id = id
        self.track = track
        self.date = date
        self.raceNumber = raceNumber
        self.distance = distance
        self.surface = surface
        self.purse = purse
        self.raceClass = raceClass
        self.conditions = conditions
        self.entries = []
        self.name = "\(track) R\(raceNumber)"
    }
}

@Model 
class RaceEntry {
    var id: String = UUID().uuidString
    var horse: Horse?
    var jockey: Jockey?
    var trainer: Trainer?
    var race: Race?
    var postPosition: Int = 0
    var morningLineOdds: Double = 0.0
    var finalOdds: Double?
    var finishPosition: Int?
    var beatenLengths: Double?
    var finalTime: TimeInterval?
    var fractionalTimes: [TimeInterval] = []
    
    init(id: String = UUID().uuidString,
         horse: Horse,
         jockey: Jockey,
         trainer: Trainer,
         postPosition: Int,
         morningLineOdds: Double) {
        self.id = id
        self.horse = horse
        self.jockey = jockey
        self.trainer = trainer
        self.postPosition = postPosition
        self.morningLineOdds = morningLineOdds
        self.fractionalTimes = []
    }
}
