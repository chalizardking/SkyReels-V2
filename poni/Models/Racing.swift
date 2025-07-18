import SwiftUI
import SwiftData

@Model
final class Jockey {
    var id: String
    var name: String
    var wins: Int
    var places: Int
    var shows: Int
    var totalMounts: Int
    var winPercentage: Double
    var roi30Days: Double
    var roi90Days: Double
    var roi1Year: Double
    @Relationship(deleteRule: .nullify, inverse: \RaceEntry.jockey) var entries: [RaceEntry]?
    
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
        self.entries = []
    }
}

@Model
final class Trainer {
    var id: String
    var name: String
    var wins: Int
    var places: Int
    var shows: Int
    var totalStarts: Int
    var winPercentage: Double
    var roi30Days: Double
    var roi90Days: Double
    var roi1Year: Double
    @Relationship(deleteRule: .nullify, inverse: \RaceEntry.trainer) var entries: [RaceEntry]?
    
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
        self.entries = []
    }
}

@Model
final class Race {
    var id: String
    var track: String
    var date: Date
    var raceNumber: Int
    var distance: String
    var surface: String
    var purse: Double
    var raceClass: String
    var conditions: String
    @Relationship(deleteRule: .cascade, inverse: \RaceEntry.race) var entries: [RaceEntry]
    
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
    }
}

@Model
final class RaceEntry {
    var id: String
    var postPosition: Int
    var morningLineOdds: Double
    var finalOdds: Double?
    var finishPosition: Int?
    var beatenLengths: Double?
    var finalTime: TimeInterval?
    @Relationship(deleteRule: .nullify) var horse: Horse?
    @Relationship(deleteRule: .nullify) var jockey: Jockey?
    @Relationship(deleteRule: .nullify) var trainer: Trainer?
    @Relationship(deleteRule: .nullify) var race: Race?
    
    init(id: String = UUID().uuidString,
         postPosition: Int,
         morningLineOdds: Double,
         horse: Horse? = nil,
         jockey: Jockey? = nil,
         trainer: Trainer? = nil,
         race: Race? = nil) {
        self.id = id
        self.postPosition = postPosition
        self.morningLineOdds = morningLineOdds
        self.horse = horse
        self.jockey = jockey
        self.trainer = trainer
        self.race = race
    }
}
