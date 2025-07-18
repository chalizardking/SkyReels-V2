//
//  DataSourceManager.swift
//  poni
//
//  Created by Assistant on 2024
//

import Foundation
import SwiftUI
import SwiftData
import OSLog

// MARK: - Error Types

/// Custom error types for data source operations
enum DataSourceError: LocalizedError {
    case networkUnavailable
    case invalidResponse
    case rateLimitExceeded
    case operationCancelled
    case invalidAPIKey
    case dataMappingFailed
    case httpError(Int)
    case noData
    case decodingError
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network is unavailable. Please check your connection."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please wait before making more requests."
        case .operationCancelled:
            return "The operation was cancelled."
        case .invalidAPIKey:
            return "Invalid API key. Please check your configuration."
        case .dataMappingFailed:
            return "Failed to process the data. Please try again."
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .noData:
            return "No data received from the server."
        case .decodingError:
            return "Error processing the server response."
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - Data Source Manager

/// Manages data operations for the application, including API communication and caching
@MainActor
class DataSourceManager: ObservableObject {
    // MARK: - Shared Instance
    
    static let shared = DataSourceManager()
    
    // MARK: - Dependencies
    
    private let realService: RealDataServiceProtocol
    private let mappingService: DataMappingServiceProtocol
    private let userDefaults: UserDefaults
    private let logger: Logger
    
    // MARK: - Published Properties
    
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var apiKeyConfigured = false
    @Published private(set) var lastUpdated: Date?
    @Published var hasCompletedOnboarding: Bool = false
    
    // MARK: - Private Properties
    
    private let maxRetryAttempts = 3
    private let retryDelay: TimeInterval = 2.0
    private let rateLimitDelay: TimeInterval = 0.2
    
    // MARK: - Initialization
    
    init(
        realService: RealDataServiceProtocol = RealDataService.shared,
        mappingService: DataMappingServiceProtocol = DataMappingService.shared,
        userDefaults: UserDefaults = .standard,
        logger: Logger = Logger(subsystem: "com.poni.app", category: "DataSourceManager")
    ) {
        self.realService = realService
        self.mappingService = mappingService
        self.userDefaults = userDefaults
        self.logger = logger
        
        // Initialize onboarding status from UserDefaults
        hasCompletedOnboarding = userDefaults.bool(forKey: "has_completed_onboarding")
        
        checkAPIKeyConfiguration()
        setupBackgroundRefresh()
    }
    
    // MARK: - Configuration
    
    /// Configures the API key for the data service
    /// - Parameter apiKey: The API key to configure
    /// - Returns: Boolean indicating if the configuration was successful
    func configureAPIKey(_ apiKey: String) -> Bool {
        guard isValidAPIKey(apiKey) else {
            errorMessage = "Invalid API key format. Please enter a valid RapidAPI key (minimum 32 characters)."
            apiKeyConfigured = false
            return false
        }
        
        realService.updateAPIKey(apiKey)
        apiKeyConfigured = true
        userDefaults.set(apiKey, forKey: "racing_api_key")
        clearError()
        
        logger.info("API key configured successfully")
        return true
    }
    
    /// Validates the format of an API key
    /// - Parameter key: The API key to validate
    /// - Returns: Boolean indicating if the key is valid
    private func isValidAPIKey(_ key: String) -> Bool {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        // RapidAPI keys are typically 50+ characters with alphanumeric and special characters
        return trimmedKey.count >= 32 && !trimmedKey.isEmpty
    }
    
    /// Checks if a valid API key is configured
    private func checkAPIKeyConfiguration() {
        let apiKey = userDefaults.string(forKey: "racing_api_key") ?? ""
        apiKeyConfigured = isValidAPIKey(apiKey)
        
        if apiKeyConfigured {
            realService.updateAPIKey(apiKey)
            logger.info("Valid API key found in configuration")
        } else {
            logger.warning("No valid API key found in configuration")
        }
    }
    
    // MARK: - Network Utilities
    
    /// Checks if network is available
    /// - Returns: Boolean indicating network availability
    private func isNetworkAvailable() -> Bool {
        // In a real app, you would check network reachability here
        // For now, we'll assume network is available
        return true
    }
    
    /// Sets up background refresh notifications
    private func setupBackgroundRefresh() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBackgroundRefresh),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        logger.info("Background refresh setup complete")
    }
    
    /// Handles background refresh when the app becomes active
    @objc private func handleBackgroundRefresh() {
        // Only refresh if data is older than 30 minutes
        guard let lastUpdated = lastUpdated,
              Date().timeIntervalSince(lastUpdated) > 1800 else {
            logger.debug("Skipping background refresh - data is still fresh")
            return
        }
        
        logger.info("Performing background refresh")
        Task {
            await fetchHorses()
        }
    }
    
    /// Clears any error messages
    func clearError() {
        errorMessage = nil
    }
    
    /// Sets an error message
    /// - Parameter message: The error message to set
    func setError(_ message: String) {
        errorMessage = message
    }
    
    /// Marks onboarding as completed
    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: "has_completed_onboarding")
        logger.info("Onboarding marked as completed")
    }
    
    // MARK: - Data Fetching Methods
    
    /// Fetches a list of horses with optional filtering
    /// - Parameters:
    ///   - query: Search query to filter horses by name
    ///   - limit: Maximum number of horses to return
    ///   - forceRefresh: If true, bypasses cache and fetches fresh data
    /// - Returns: Array of Horse objects
    func fetchHorses(query: String = "", limit: Int = 20, forceRefresh: Bool = false) async -> [Horse] {
        // Check if we have cached results and don't need to refresh
        if !forceRefresh, let lastUpdated = lastUpdated, Date().timeIntervalSince(lastUpdated) < 300 {
            logger.debug("Returning cached horses data")
            return await fetchCachedHorses(query: query, limit: limit)
        }
        
        return await withErrorHandling {
            // Validate preconditions
            guard self.isNetworkAvailable() else {
                self.logger.error("No network connection available")
                return await self.fetchCachedHorses(query: query, limit: limit)
            }
            
            guard self.apiKeyConfigured else {
                self.logger.error("API key not configured")
                throw DataSourceError.invalidAPIKey
            }
            
            // Start loading state
            await MainActor.run {
                self.isLoading = true
            }
            
            // Fetch horses from API with retry
            let apiHorses = try await self.withRetry {
                try await self.realService.searchHorses(query: query)
            }
            
            // Process horses in parallel with limited concurrency
            var horses: [Horse] = []
            let limitedHorses = Array(apiHorses.prefix(limit))
            
            try await withThrowingTaskGroup(of: (Int, Horse).self) { group in
                // Add tasks to the group
                for (index, apiHorse) in limitedHorses.enumerated() {
                    group.addTask { [weak self] in
                        guard let self = self else { throw DataSourceError.operationCancelled }
                        
                        do {
                            // Fetch detailed results for each horse with retry
                            let results = try await withRetry {
                                try await self.realService.fetchHorseResults(horseId: apiHorse.horse_id)
                            }
                            
                            // Map API response to domain model
                            let horse = await self.mappingService.mapAPIHorseDataToHorse(apiHorse, with: results)
                            
                            // Add small delay to respect rate limiting
                            try await Task.sleep(nanoseconds: UInt64(self.rateLimitDelay * 1_000_000_000))
                            
                            return (index, horse)
                        } catch {
                            self.logger.error("Failed to fetch results for horse \(apiHorse.horse_id): \(error.localizedDescription)")
                            throw error
                        }
                    }
                }
                
                // Process results as they complete
                var results = [(Int, Horse)]()
                results.reserveCapacity(limitedHorses.count)
                
                for try await result in group {
                    results.append(result)
                }
                
                // Sort by original index to maintain order
                horses = results.sorted { $0.0 < $1.0 }.map { $0.1 }
            }
            
            // Update state
            await MainActor.run {
                self.lastUpdated = Date()
                self.isLoading = false
            }
            
            self.logger.info("Successfully fetched \(horses.count) horses")
            
            // Cache the results
            await self.cacheHorses(horses)
            
            return horses
        } ?? []
    }
    
    /// Fetches detailed information for a specific horse
    /// - Parameter horseId: The unique identifier for the horse
    /// - Returns: Optional Horse object with detailed information
    func fetchHorseDetails(horseId: String) async -> Horse? {
        await withErrorHandling {
            guard self.isNetworkAvailable() else {
                self.logger.error("No network connection available")
                throw DataSourceError.invalidResponse
            }
            
            // Fetch horse details
            let apiHorse = try await self.withRetry {
                try await self.realService.fetchHorseDetails(horseId: horseId)
            }
            
            // Fetch race results for the horse
            let results = try await self.withRetry {
                try await self.realService.fetchHorseResults(horseId: horseId)
            }
            
            // Map to domain model
            let horse = await self.mappingService.mapAPIHorseDataToHorse(apiHorse, with: results)
            self.logger.info("Fetched details for horse: \(horse.name)")
            
            // Update cache
            await MainActor.run {
                self.lastUpdated = Date()
            }
            
            return horse
        }
    }
    
    // MARK: - Race Data
    
    /// Fetches today's races with detailed information
    /// - Returns: Array of Race objects with entries and results
    func fetchTodaysRaces() async -> [Race] {
        return await withErrorHandling {
            guard self.isNetworkAvailable() else {
                self.logger.error("No network connection available")
                return []
            }
            
            guard self.apiKeyConfigured else {
                self.logger.error("API key not configured")
                throw DataSourceError.invalidAPIKey
            }
            
            // Start loading state
            await MainActor.run {
                self.isLoading = true
            }
            
            // Fetch today's racecards
            let racecards = try await self.withRetry {
                try await self.realService.fetchTodaysRaces()
            }
            
            // Process races in parallel
            var races: [Race] = []
            
            try await withThrowingTaskGroup(of: Race.self) { group in
                for racecard in racecards {
                    group.addTask { [weak self] in
                        guard let self = self else { throw DataSourceError.operationCancelled }
                        
                        // Map racecard to Race model
                        var race = await self.mappingService.mapAPIRacecardToRace(racecard)
                        
                        // Process each entry in the race
                        for runner in racecard.runners {
                            do {
                                // Fetch detailed results for each horse
                                let results = try await withRetry {
                                    try await self.realService.fetchHorseResults(horseId: runner.horse_id)
                                }
                                
                                // Map horse data
                                let horse = await self.mappingService.mapAPIHorseDataToHorse(runner, with: results)
                                
                                // Fetch jockey and trainer stats
                                let jockeyStats = try await withRetry {
                                    try await self.realService.fetchJockeyStats(jockeyId: runner.jockey_id ?? "")
                                }
                                
                                let trainerStats = try await withRetry {
                                    try await self.realService.fetchTrainerStats(trainerId: runner.trainer_id ?? "")
                                }
                                
                                // Map to domain models
                                let jockey = await self.mappingService.mapAPIJockeyStatsToJockey(jockeyStats)
                                let trainer = await self.mappingService.mapAPITrainerStatsToTrainer(trainerStats)
                                
                                // Create race entry
                                if let entry = await self.mappingService.mapAPIRaceResultToRaceEntry(
                                    APIRaceResult(
                                        date: racecard.date,
                                        course: racecard.course,
                                        distance: racecard.distance,
                                        position: "", // Position would be in results
                                        runners: racecard.runners.count,
                                        going: racecard.going,
                                        race_class: racecard.race_class,
                                        prize: nil,
                                        time: nil,
                                        weight: nil,
                                        odds: nil
                                    ),
                                    horse: horse,
                                    jockey: jockey,
                                    trainer: trainer
                                ) {
                                    race.entries.append(entry)
                                }
                                
                                // Add small delay to respect rate limiting
                                try await Task.sleep(nanoseconds: UInt64(self.rateLimitDelay * 1_000_000_000))
                                
                            } catch {
                                self.logger.error("Failed to process race entry: \(error.localizedDescription)")
                                // Continue with other entries even if one fails
                                continue
                            }
                        }
                        
                        return race
                    }
                }
                
                // Collect all races
                for try await race in group {
                    races.append(race)
                }
            }
            
            // Update state
            await MainActor.run {
                self.lastUpdated = Date()
                self.isLoading = false
            }
            
            self.logger.info("Successfully fetched \(races.count) races")
            
            return races
        } ?? []
    }
    
    // MARK: - Caching
    
    /// Fetches horses from cache
    /// - Parameters:
    ///   - query: Optional query to filter cached horses
    ///   - limit: Maximum number of horses to return
    /// - Returns: Array of cached Horse objects
    private func fetchCachedHorses(query: String, limit: Int) async -> [Horse] {
        // In a real app, you would fetch from Core Data or another cache
        // This is a simplified implementation
        self.logger.debug("Fetching horses from cache")
        return []
    }
    
    /// Caches the provided horses
    /// - Parameter horses: Array of Horse objects to cache
    private func cacheHorses(_ horses: [Horse]) async {
        // In a real app, you would save to Core Data or another cache
        self.logger.debug("Caching \(horses.count) horses")
    }
    
    // MARK: - Retry Mechanism
    
    /// Executes an async operation with automatic retry logic
    /// - Parameters:
    ///   - attempts: Maximum number of retry attempts
    ///   - delay: Delay between retries in seconds
    ///   - operation: The operation to retry
    /// - Returns: The result of the operation
    private func withRetry<T>(
        attempts: Int = 3,
        delay: TimeInterval = 2.0,
        _ operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...attempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                // Don't retry for certain errors
                if let dataError = error as? DataSourceError, 
                   case .invalidAPIKey = dataError {
                    throw dataError
                }
                
                // Log the retry attempt
                self.logger.warning("Attempt \(attempt)/\(attempts) failed: \(error.localizedDescription)")
                
                // If this was the last attempt, rethrow the error
                guard attempt < attempts else { break }
                
                // Calculate exponential backoff with jitter
                let jitter = Double.random(in: 0.5...1.5)
                let delayTime = delay * pow(2.0, Double(attempt - 1)) * jitter
                
                // Wait before retrying
                try await Task.sleep(nanoseconds: UInt64(delayTime * 1_000_000_000))
            }
        }
        
        // If we get here, all retry attempts failed
        throw lastError ?? DataSourceError.networkUnavailable
    }
    
    // MARK: - Error Handling
    
    /// Wraps an async operation with error handling and loading state management
    /// - Parameter operation: The async operation to execute
    /// - Returns: The result of the operation or nil if it failed
    private func withErrorHandling<T>(_ operation: @escaping () async throws -> T) async -> T? {
        // Set loading state
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        defer {
            // Reset loading state when done
            Task { @MainActor [weak self] in
                self?.isLoading = false
            }
        }
        
        do {
            return try await operation()
        } catch let error as NSError {
            let errorMessage = handleError(error)
            
            // Update error state on the main thread
            await MainActor.run {
                self.errorMessage = errorMessage
            }
            
            self.logger.error("Operation failed: \(errorMessage)")
            return nil
        } catch {
            let errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            
            await MainActor.run {
                self.errorMessage = errorMessage
            }
            
            self.logger.error("Unexpected error: \(errorMessage)")
            return nil
        }
    }
    
    /// Handles different types of errors and returns user-friendly messages
    /// - Parameter error: The error that occurred
    /// - Returns: A user-friendly error message
    private func handleError(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch (nsError.domain, nsError.code) {
        case (NSURLErrorDomain, NSURLErrorNotConnectedToInternet):
            return "No internet connection. Please check your network settings."
        case (NSURLErrorDomain, NSURLErrorTimedOut):
            return "The request timed out. Please try again."
        case (NSURLErrorDomain, NSURLErrorBadServerResponse):
            return "The server is currently unavailable. Please try again later."
        case (NSURLErrorDomain, NSURLErrorCancelled):
            return "Request was cancelled."
        case (NSURLErrorDomain, NSURLErrorSecureConnectionFailed):
            return "Could not establish a secure connection."
        default:
            if let dataError = error as? DataSourceError {
                return dataError.localizedDescription
            } else if let apiError = error as? APIError {
                switch apiError {
                case .unauthorized:
                    // Clear API key on unauthorized
                    userDefaults.removeObject(forKey: "racing_api_key")
                    Task { @MainActor [weak self] in
                        self?.apiKeyConfigured = false
                    }
                    return "Your session has expired. Please log in again."
                case .rateLimitExceeded:
                    return "Too many requests. Please wait before trying again."
                case .serverError:
                    return "The server is experiencing issues. Please try again later."
                case .networkError(let message):
                    return "A network error occurred: \(message)"
                default:
                    return apiError.localizedDescription
                }
            } else {
                return "An unexpected error occurred. Please try again."
            }
        }
    }
}

// MARK: - Protocol Definitions

/// Protocol for the real data service to enable dependency injection for testing
protocol RealDataServiceProtocol: AnyObject {
    var apiKey: String { get set }
    
    func searchHorses(query: String) async throws -> [APIHorseData]
    func fetchHorseDetails(horseId: String) async throws -> APIHorseData
    func fetchHorseResults(horseId: String) async throws -> [APIRaceResult]
    func fetchJockeyStats(jockeyId: String) async throws -> APIJockeyStats
    func fetchTrainerStats(trainerId: String) async throws -> APITrainerStats
    func fetchTodaysRaces() async throws -> [APIRacecard]
    
    func updateAPIKey(_ key: String)
}

// MARK: - RealDataService Extension

extension RealDataService: RealDataServiceProtocol {
    var apiKey: String {
        get { APIConfiguration.apiKey }
        set { APIConfiguration.apiKey = newValue }
    }
}
