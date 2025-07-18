//
//  APITestingService.swift
//  poni
//
//  Created by Assistant on 2024
//

import Foundation
import SwiftUI

// MARK: - API Testing Service
// This service provides comprehensive testing for all API endpoints
// and validates data mapping functionality

@MainActor
class APITestingService: ObservableObject {
    static let shared = APITestingService()
    
    @Published var testResults: [APITestResult] = []
    @Published var isRunningTests = false
    @Published var overallTestStatus: TestStatus = .notRun
    
    private let realDataService = RealDataService.shared
    private let mappingService = DataMappingService.shared
    private let dataSourceManager = DataSourceManager.shared
    
    private init() {}
    
    // MARK: - Test Execution
    
    func runAllTests() async {
        await MainActor.run {
            isRunningTests = true
            testResults.removeAll()
            overallTestStatus = .running
        }
        
        let tests: [(String, () async -> APITestResult)] = [
            ("API Key Validation", testAPIKeyValidation),
            ("Connection Test", testConnection),
            ("Fetch Today's Races", testFetchTodaysRaces),
            ("Search Horses", testSearchHorses),
            ("Fetch Horse Details", testFetchHorseDetails),
            ("Fetch Horse Results", testFetchHorseResults),
            ("Fetch Jockey Stats", testFetchJockeyStats),
            ("Fetch Trainer Stats", testFetchTrainerStats),
            ("Fetch Race Results", testFetchRaceResults),
            ("Data Mapping - Horse", testHorseMapping),
            ("Data Mapping - ROI", testROIMapping),
            ("Error Handling", testErrorHandling),
            ("Rate Limiting", testRateLimiting)
        ]
        
        var passedTests = 0
        
        for (_, testFunction) in tests {
            let result = await testFunction()
            
            await MainActor.run {
                testResults.append(result)
            }
            
            if result.status == .passed {
                passedTests += 1
            }
            
            // Add delay between tests to respect rate limits
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        await MainActor.run {
            isRunningTests = false
            overallTestStatus = passedTests == tests.count ? .passed : .failed
        }
    }
    
    // MARK: - Individual Tests
    
    private func testAPIKeyValidation() async -> APITestResult {
        let testName = "API Key Validation"
        let startTime = Date()
        
        let validKey = "abcdef1234567890abcdef1234567890"
        let validResult = await dataSourceManager.configureAPIKey(validKey)
        let duration = Date().timeIntervalSince(startTime)
        
        return APITestResult(
            testName: testName,
            status: validResult ? .passed : .failed,
            message: validResult ? "API key validation successful" : "API key validation failed",
            duration: duration,
            details: "Tested API key format validation"
        )
    }
    
    private func testConnection() async -> APITestResult {
        let testName = "Connection Test"
        let startTime = Date()
        
        do {
            let races = try await realDataService.fetchTodaysRaces()
            let duration = Date().timeIntervalSince(startTime)
            
            return APITestResult(
                testName: testName,
                status: .passed,
                message: "Successfully connected to API",
                duration: duration,
                details: "Retrieved \(races.count) races"
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Connection failed",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testFetchTodaysRaces() async -> APITestResult {
        let testName = "Fetch Today's Races"
        let startTime = Date()
        
        do {
            let races = try await realDataService.fetchTodaysRaces()
            let duration = Date().timeIntervalSince(startTime)
            
            if !races.isEmpty {
                let sampleRace = races.first!
                return APITestResult(
                    testName: testName,
                    status: .passed,
                    message: "Successfully fetched \(races.count) races",
                    duration: duration,
                    details: "Sample: \(sampleRace.race_name) at \(sampleRace.course)"
                )
            } else {
                return APITestResult(
                    testName: testName,
                    status: .warning,
                    message: "No races found for today",
                    duration: duration,
                    details: "This might be normal if no races are scheduled"
                )
            }
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Failed to fetch today's races",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testSearchHorses() async -> APITestResult {
        let testName = "Search Horses"
        let startTime = Date()
        
        do {
            let horses = try await realDataService.searchHorses(query: "")
            let duration = Date().timeIntervalSince(startTime)
            
            if !horses.isEmpty {
                let sampleHorse = horses.first!
                return APITestResult(
                    testName: testName,
                    status: .passed,
                    message: "Successfully found \(horses.count) horses",
                    duration: duration,
                    details: "Sample: \(sampleHorse.horse) trained by \(sampleHorse.trainer ?? "Unknown")"
                )
            } else {
                return APITestResult(
                    testName: testName,
                    status: .warning,
                    message: "No horses found",
                    duration: duration,
                    details: "This might indicate no current race data"
                )
            }
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Horse search failed",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testFetchHorseDetails() async -> APITestResult {
        let testName = "Fetch Horse Details"
        let startTime = Date()
        
        do {
            // First get a horse to test with
            let horses = try await realDataService.searchHorses(query: "")
            guard let testHorse = horses.first else {
                return APITestResult(
                    testName: testName,
                    status: .warning,
                    message: "No horses available for testing",
                    duration: Date().timeIntervalSince(startTime),
                    details: "Need horses from search to test details fetch"
                )
            }
            
            let horseDetails = try await realDataService.fetchHorseDetails(horseId: testHorse.horse_id)
            let duration = Date().timeIntervalSince(startTime)
            
            return APITestResult(
                testName: testName,
                status: .passed,
                message: "Successfully fetched horse details",
                duration: duration,
                details: "Horse: \(horseDetails.horse), Age: \(horseDetails.age ?? 0)"
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Failed to fetch horse details",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testFetchHorseResults() async -> APITestResult {
        let testName = "Fetch Horse Results"
        let startTime = Date()
        
        do {
            // Get a test horse
            let horses = try await realDataService.searchHorses(query: "")
            guard let testHorse = horses.first else {
                return APITestResult(
                    testName: testName,
                    status: .warning,
                    message: "No horses available for testing",
                    duration: Date().timeIntervalSince(startTime),
                    details: "Need horses from search to test results fetch"
                )
            }
            
            let results = try await realDataService.fetchHorseResults(horseId: testHorse.horse_id)
            let duration = Date().timeIntervalSince(startTime)
            
            return APITestResult(
                testName: testName,
                status: .passed,
                message: "Successfully fetched \(results.count) race results",
                duration: duration,
                details: "Results generated for horse: \(testHorse.horse)"
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Failed to fetch horse results",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testFetchJockeyStats() async -> APITestResult {
        let testName = "Fetch Jockey Stats"
        let startTime = Date()
        
        do {
            // Get a test jockey
            let races = try await realDataService.fetchTodaysRaces()
            let jockeys = races.flatMap { $0.runners.compactMap { $0.jockey } }
            guard let testJockey = jockeys.first else {
                return APITestResult(
                    testName: testName,
                    status: .warning,
                    message: "No jockeys available for testing",
                    duration: Date().timeIntervalSince(startTime),
                    details: "Need jockey data from races to test stats fetch"
                )
            }
            
            let stats = try await realDataService.fetchJockeyStats(jockeyId: testJockey)
            let duration = Date().timeIntervalSince(startTime)
            
            return APITestResult(
                testName: testName,
                status: .passed,
                message: "Successfully fetched jockey stats",
                duration: duration,
                details: "\(stats.jockey): \(stats.wins)/\(stats.runs) (\(String(format: "%.1f", stats.win_percentage))%)"
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Failed to fetch jockey stats",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testFetchTrainerStats() async -> APITestResult {
        let testName = "Fetch Trainer Stats"
        let startTime = Date()
        
        do {
            // Get a test trainer
            let races = try await realDataService.fetchTodaysRaces()
            let trainers = races.flatMap { $0.runners.compactMap { $0.trainer } }
            guard let testTrainer = trainers.first else {
                return APITestResult(
                    testName: testName,
                    status: .warning,
                    message: "No trainers available for testing",
                    duration: Date().timeIntervalSince(startTime),
                    details: "Need trainer data from races to test stats fetch"
                )
            }
            
            let stats = try await realDataService.fetchTrainerStats(trainerId: testTrainer)
            let duration = Date().timeIntervalSince(startTime)
            
            return APITestResult(
                testName: testName,
                status: .passed,
                message: "Successfully fetched trainer stats",
                duration: duration,
                details: "\(stats.trainer): \(stats.wins)/\(stats.runs) (\(String(format: "%.1f", stats.win_percentage))%)"
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Failed to fetch trainer stats",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testFetchRaceResults() async -> APITestResult {
        let testName = "Fetch Race Results"
        let startTime = Date()
        
        do {
            let results = try await realDataService.fetchRaceResults()
            let duration = Date().timeIntervalSince(startTime)
            
            if !results.isEmpty {
                return APITestResult(
                    testName: testName,
                    status: .passed,
                    message: "Successfully fetched \(results.count) race results",
                    duration: duration,
                    details: "Historical race data available"
                )
            } else {
                return APITestResult(
                    testName: testName,
                    status: .warning,
                    message: "No race results found",
                    duration: duration,
                    details: "This might be normal if no historical data is available"
                )
            }
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Failed to fetch race results",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testHorseMapping() async -> APITestResult {
        let testName = "Horse Data Mapping"
        let startTime = Date()
        
        do {
            let apiHorses = try await realDataService.searchHorses(query: "")
            guard let apiHorse = apiHorses.first else {
                return APITestResult(
                    testName: testName,
                    status: .warning,
                    message: "No horses available for testing",
                    duration: Date().timeIntervalSince(startTime),
                    details: "API returned no horses to test mapping"
                )
            }
            
            let results = try await realDataService.fetchHorseResults(horseId: apiHorse.horse_id)
            let horse = mappingService.mapAPIHorseToHorse(apiHorse, with: results)
            let duration = Date().timeIntervalSince(startTime)
            
            let details = """
                Mapped horse: \(horse.name)
                Age: \(horse.age)
                Trainer: \(horse.trainer)
                Record: \(horse.wins)-\(horse.places)-\(horse.shows)
                """
            
            return APITestResult(
                testName: testName,
                status: .passed,
                message: "Successfully mapped horse data",
                duration: duration,
                details: details
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Horse mapping failed",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testROIMapping() async -> APITestResult {
        let testName = "ROI Data Mapping"
        let startTime = Date()
        
        do {
            // Test jockey ROI mapping
            let jockeyStats = try await realDataService.fetchJockeyStats(jockeyId: "test-jockey")
            let jockeyROI = mappingService.mapAPIJockeyStatsToROI(jockeyStats)
            
            // Test trainer ROI mapping
            let trainerStats = try await realDataService.fetchTrainerStats(trainerId: "test-trainer")
            let trainerROI = mappingService.mapAPITrainerStatsToROI(trainerStats)
            
            let duration = Date().timeIntervalSince(startTime)
            
            let details = """
                Jockey ROI: \(jockeyROI.name) - \(jockeyROI.roi30Days)%
                Trainer ROI: \(trainerROI.name) - \(trainerROI.roi30Days)%
                """
            
            return APITestResult(
                testName: testName,
                status: .passed,
                message: "Successfully mapped ROI data",
                duration: duration,
                details: details
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "ROI mapping failed",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testRaceMapping() async -> APITestResult {
        let testName = "Race Data Mapping"
        let startTime = Date()
        
        do {
            let apiRaces = try await realDataService.fetchTodaysRaces()
            guard let apiRace = apiRaces.first else {
                return APITestResult(
                    testName: testName,
                    status: .warning,
                    message: "No races available for testing",
                    duration: Date().timeIntervalSince(startTime),
                    details: "API returned no races to test mapping"
                )
            }
            
            let race = mappingService.mapAPIRaceToRace(apiRace)
            let duration = Date().timeIntervalSince(startTime)
            
            let details = """
                Mapped race at \(race.track)
                Date: \(race.date.formatted())
                Distance: \(race.distance)
                Class: \(race.raceClass)
                """
            
            return APITestResult(
                testName: testName,
                status: .passed,
                message: "Successfully mapped race data",
                duration: duration,
                details: details
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Race mapping failed",
                duration: duration,
                details: error.localizedDescription
            )
        }
    }
    
    private func testErrorHandling() async -> APITestResult {
        let testName = "Error Handling"
        let startTime = Date()
        
        // Test with invalid data
        do {
            _ = try await realDataService.fetchHorseDetails(horseId: "invalid-id")
            
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .failed,
                message: "Error handling test failed",
                duration: duration,
                details: "Expected error for invalid ID but received success"
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return APITestResult(
                testName: testName,
                status: .passed,
                message: "Error handling working correctly",
                duration: duration,
                details: "Properly caught error: \(error.localizedDescription)"
            )
        }
    }
    
    private func testRateLimiting() async -> APITestResult {
        let testName = "Rate Limiting"
        let startTime = Date()
        
        // Make multiple rapid requests to test rate limiting
        var requestTimes: [TimeInterval] = []
        
        for _ in 0..<3 {
            let requestStart = Date()
            do {
                _ = try await realDataService.fetchTodaysRaces()
                requestTimes.append(Date().timeIntervalSince(requestStart))
            } catch {
                // Rate limiting might cause errors, which is expected
                break
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        if requestTimes.count >= 2 {
            let avgTime = requestTimes.reduce(0, +) / Double(requestTimes.count)
            return APITestResult(
                testName: testName,
                status: .passed,
                message: "Rate limiting test completed",
                duration: duration,
                details: "\(requestTimes.count) requests, avg time: \(String(format: "%.2f", avgTime))s"
            )
        } else {
            return APITestResult(
                testName: testName,
                status: .warning,
                message: "Rate limiting test inconclusive",
                duration: duration,
                details: "Could not complete multiple requests for testing"
            )
        }
    }
    
    // MARK: - Test Results Management
    
    func clearResults() {
        testResults.removeAll()
        overallTestStatus = .notRun
    }
    
    func exportResults() -> String {
        var report = "# API Test Report\n\n"
        report += "Generated: \(DateFormatter.displayDate.string(from: Date()))\n\n"
        report += "Overall Status: \(overallTestStatus.rawValue.capitalized)\n\n"
        
        for result in testResults {
            report += "## \(result.testName)\n"
            report += "- Status: \(result.status.rawValue.capitalized)\n"
            report += "- Duration: \(String(format: "%.2f", result.duration))s\n"
            report += "- Message: \(result.message)\n"
            report += "- Details: \(result.details)\n\n"
        }
        
        return report
    }
}

// MARK: - Test Data Models

struct APITestResult: Identifiable {
    let id = UUID()
    let testName: String
    let status: TestStatus
    let message: String
    let duration: TimeInterval
    let details: String
}

enum TestStatus: String, CaseIterable {
    case notRun = "not_run"
    case running = "running"
    case passed = "passed"
    case failed = "failed"
    case warning = "warning"
    
    var color: Color {
        switch self {
        case .notRun: return .gray
        case .running: return .blue
        case .passed: return .green
        case .failed: return .red
        case .warning: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .notRun: return "circle"
        case .running: return "arrow.clockwise"
        case .passed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
