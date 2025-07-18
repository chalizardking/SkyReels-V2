# Poni Horse Racing Analytics - API Developer Guide

## Overview

This guide provides comprehensive documentation for the API implementation in the Poni Horse Racing Analytics app. The implementation uses the **Horse Racing USA API** from RapidAPI to fetch real-time horse racing data.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Architecture Overview](#architecture-overview)
3. [API Configuration](#api-configuration)
4. [Core Services](#core-services)
5. [Data Models](#data-models)
6. [Usage Examples](#usage-examples)
7. [Error Handling](#error-handling)
8. [Rate Limiting](#rate-limiting)
9. [Testing](#testing)
10. [Best Practices](#best-practices)
11. [Troubleshooting](#troubleshooting)

## Quick Start

### 1. Get API Key
```swift
// Step-by-step instructions to obtain the API key:
// 1. Sign up at RapidAPI.com if you haven't already.
// 2. Subscribe to the "Horse Racing USA" API, which requires registration to access.
// 3. After subscription, copy the API key provided.
```

### 2. Configure API
```swift
// Here, we create an instance of DataSourceManager, which manages data operations.
// We then configure it with the API key obtained from RapidAPI.
let dataSourceManager = DataSourceManager.shared
let success = dataSourceManager.configureAPIKey("your-rapidapi-key")
```

### 3. Fetch Data
```swift
// An asynchronous task is created here because fetching data is a network operation,
// which is inherently asynchronous. We attempt to fetch today's races and handle
// any exceptions or errors that occur during the process.
Task {
    do {
        let races = try await dataSourceManager.fetchTodaysRaces()
        print("Found \(races.count) races today")
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
```

## Architecture Overview

```
// This is a diagram representing the architecture of the system.
// ┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
// │   SwiftUI Views │───▶│ DataSourceManager│───▶│ RealDataService │
// └─────────────────┘    └──────────────────┘    └─────────────────┘
//                                │                        │
//                                ▼                        ▼
//                       ┌──────────────────┐    ┌─────────────────┐
//                       │DataMappingService│    │ Horse Racing API│
//                       └──────────────────┘    └─────────────────┘
```

### Key Components

- **DataSourceManager**: A high-level interface for all data operations, serving as the primary coordinator.
- **RealDataService**: Handles direct API communication and response processing.
- **DataMappingService**: Responsible for converting raw API responses into app-specific models.
- **APITestingService**: Ensures comprehensive testing and validation of API interactions.

## API Configuration

### API Details
- **Service**: Specifies the API being used, which is the Horse Racing USA API.
- **Provider**: RapidAPI serves as the provider platform for the API.
- **Base URL**: `https://horse-racing-usa.p.rapidapi.com` is the API's root endpoint for requests.
- **Rate Limit**: Restricts requests to 1 per second to prevent overloading the API.
- **Authentication**: Involves passing the RapidAPI Key within the request headers for authentication.

### Configuration Code
```swift
// Code structure inside DataSourceManager to configure the API key and perform validation
func configureAPIKey(_ key: String) -> Bool {
    guard isValidAPIKey(key) else { return false }
    realDataService.updateAPIKey(key)
    return true
}

// Private utility function to validate the API key format
private func isValidAPIKey(_ key: String) -> Bool {
    return key.count >= 32 && key.allSatisfy { $0.isLetter || $0.isNumber }
}
```

## Core Services

### DataSourceManager

Main interface for all API operations, providing a centralized point of interaction:

```swift
class DataSourceManager: ObservableObject {
    // Configuration function to set the API key
    func configureAPIKey(_ key: String) -> Bool
    func canUseRealData -> Bool // Checks if real data can be used

    // Functions for fetching race-related data
    func fetchTodaysRaces() async throws -> [Race]
    func fetchUpcomingRaces() async throws -> [Race]
    func fetchRaceResults() async throws -> [Race]

    // Functions to interact with horse data
    func searchHorses(query: String) async throws -> [Horse]
    func fetchHorseDetails(horseId: String) async throws -> Horse

    // Statistical data retrieval functions
    func fetchJockeyROIData() async throws -> [JockeyROIData]
    func fetchTrainerROIData() async throws -> [TrainerROIData]

    // Utility functions for refreshing and clearing errors
    func refreshData() async
    func clearError()
}
```

### RealDataService

Handles communication with the API directly:

```swift
class RealDataService {
    // Functions to fetch various race-related data from the API
    func fetchTodaysRaces() async throws -> [APIRacecard]
    func fetchRaceDetails(raceId: String) async throws -> APIRacecard
    func fetchHorseDetails(horseId: String) async throws -> APIHorseData
    func fetchRaceResults() async throws -> [APIRaceResult]

    // Functions for searching and obtaining statistics
    func searchHorses(query: String) async throws -> [APIHorseData]
    func fetchJockeyStats(jockeyId: String) async throws -> APIJockeyStats
    func fetchTrainerStats(trainerId: String) async throws -> APITrainerStats

    // Utility functions to check connection and update the API key
    func checkConnection() async -> Bool
    func updateAPIKey(_ key: String)
}
```

### DataMappingService

Responsible for converting API models to application-specific models:

```swift
class DataMappingService {
    // Functions for mapping API-specific data structures to app-specific ones
    func mapAPIHorseDataToHorse(_ apiHorse: APIHorseData, with results: [APIRaceResult]) -> Horse
    func mapAPIJockeyStatsToJockey(_ stats: APIJockeyStats) -> Jockey
    func mapAPITrainerStatsToTrainer(_ stats: APITrainerStats) -> Trainer
    func mapAPIJockeyStatsToROI(_ stats: APIJockeyStats) -> JockeyROIData
    func mapAPITrainerStatsToROI(_ stats: APITrainerStats) -> TrainerROIData
}
```

## Data Models

### API Response Models

```swift
// Structure representing race data from the API
struct APIRacecard: Codable {
    let race_id: String
    let race_name: String
    let course: String
    let race_time: String
    let runners: [APIRunner] // List of participants in the race
}

// Structure representing individual runners in a race
struct APIRunner: Codable {
    let horse_id: String? // Nullable because some data might not be available
    let horse: String
    let jockey: String?
    let trainer: String?
    let weight: String?
    let odds: String?
}

// Structure for horse-related data from the API
struct APIHorseData: Codable {
    let horse_id: String
    let horse: String
    let age: Int?
    let sex: String?
    let trainer: String?
    let owner: String?
}

// Structure for holding jockey statistics
struct APIJockeyStats: Codable {
    let jockey: String
    let wins: Int
    let runs: Int
    let win_percentage: Double
    let recent_form: [String] // Represents recent performance, e.g., "Win", "Lose"
}
```

### App Models

```swift
// Example model structure to represent horse data in the application
struct ExampleHorseData {
    let id: String
    let name: String
    let age: Int
    let trainer: String?
    let jockey: String?
    let earnings: Double
}

// Example model structure to represent race data in the application
struct ExampleRaceData {
    let id: String
    let name: String
    let date: Date
    let track: String
    let distance: Double // Distance of the race
}
```

## Usage Examples

### Basic Data Fetching

```swift
// Example of fetching races scheduled for today
Task {
    do {
        let races = try await dataSourceManager.fetchTodaysRaces()
        for race in races {
            print("\(race.name) at \(race.track)") // Print race name and location
        }
    } catch {
        print("Error: \(error.localizedDescription)") // Handle potential errors
    }
}
```

### Horse Search and Analysis

```swift
// Function to search for horse-related data and analyze their recent performance
Task {
    do {
        // Empty query demonstrates fetching unfiltered data
        let horses = try await dataSourceManager.searchHorses(query: "")

        // Iterate through the top 5 horses
        for horse in horses.prefix(5) {
            let details = try await realDataService.fetchHorseDetails(horseId: horse.id)
            let results = try await realDataService.fetchHorseResults(horseId: horse.id)

            // Count recent wins
            let recentWins = results.prefix(5).filter { $0.position == 1 }.count
            print("\(horse.name): \(recentWins) wins in last 5 races")

            // Enforce a rate limit between requests
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
    } catch {
        print("Error: \(error.localizedDescription)") // Handle any errors that occur
    }
}
```

### Jockey/Trainer Analysis

```swift
// Analyze performance of jockeys based on their return on investment (ROI)
Task {
    do {
        // Fetching the ROI data for jockeys
        let roiData = try await dataSourceManager.fetchJockeyROIData()
        let topJockeys = roiData.sorted { $0.roi30Days > $1.roi30Days }.prefix(10)

        // Print the top jockeys sorted by ROI over the past 30 days
        for jockey in topJockeys {
            print("\(jockey.name): ROI \(jockey.roi30Days)")
        }
    } catch {
        print("Error: \(error.localizedDescription)") // Handle errors
    }
}
```

## Error Handling

### Error Types

```swift
// This enum defines different types of API-related errors
enum APIError: Error, LocalizedError {
    case invalidAPIKey // Error for an invalid API key
    case rateLimitExceeded // Error when the API rate limit is exceeded
    case networkError(String) // Error for general network issues, with a message
    case noData // Error when no data is available to fetch
    case invalidResponse // Error for responses that are not as expected
    case serverError(Int) // Error with a specific server error code

    // Description for each error type for user-friendly messages
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your RapidAPI key."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please wait before making more requests."
        case .networkError(let message):
            return "Network error: \(message)"
        case .noData:
            return "No data available."
        case .invalidResponse:
            return "Invalid response from server."
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}
```

### Error Handling Patterns

```swift
// Pattern 1: Using try-catch to handle potential errors during data fetching
do {
    let races = try await dataSourceManager.fetchTodaysRaces()
    // Handle successful data fetch
} catch APIError.invalidAPIKey {
    // Specific handling for an invalid API key
} catch APIError.rateLimitExceeded {
    // Specific handling for rate limit errors
} catch {
    // Generic handling for any other errors
}

// Pattern 2: Using a function with built-in error handling capabilities
await dataSourceManager.withErrorHandling {
    return try await realDataService.fetchTodaysRaces()
} onError: { error in
    print("Error: \(error.localizedDescription)") // Function to handle occurring errors
}
```

## Rate Limiting

### Implementation

```swift
// The RealDataService class implements rate limiting to comply with API restrictions
class RealDataService {
    private var lastRequestTime: Date? // Time of the last HTTP request
    private let minimumRequestInterval: TimeInterval = 1.0 // Minimum time between requests in seconds

    // Method to ensure the appropriate time interval between consecutive requests
    private func enforceRateLimit() async {
        if let lastTime = lastRequestTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < minimumRequestInterval {
                // Calculate delay if the request interval is less than the minimum
                let delay = minimumRequestInterval - elapsed
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        lastRequestTime = Date() // Update the last request time
    }
}
```

### Best Practices

1. **Always add delays between requests**:
   ```swift
   for item in items {
       let result = try await fetchData(item)
       try await Task.sleep(nanoseconds: 1_000_000_000) // Introduce a 1-second delay
   }
   ```

2. **Use batch processing**:
   ```swift
   let batches = items.chunked(into: 5) // Divide items into batches of 5
   for batch in batches {
       // Process each batch
       try await Task.sleep(nanoseconds: 5_000_000_000) // 5-second delay between batches
   }
   ```

3. **Handle rate limit errors gracefully**:
   ```swift
   catch APIError.rateLimitExceeded {
       try await Task.sleep(nanoseconds: 10_000_000_000) // Wait 10 seconds
       // Retry request or handle appropriately
   }
   ```

## Testing

### Using APITestingService

```swift
let testingService = APITestingService.shared

// Run all available tests asynchronously
Task {
    await testingService.runAllTests()

    // Display test results
    for result in testingService.testResults {
        print("\(result.testName): \(result.status)")
    }
}
```

### Manual Testing

```swift
// Manual procedure to test API connection and data fetching

// Check if the API is accessible
let isConnected = await realDataService.checkConnection()
print("API Connected: \(isConnected)")

// Attempt to fetch today's races and check for errors
do {
    let races = try await realDataService.fetchTodaysRaces()
    print("✅ Fetched \(races.count) races")
} catch {
    print("❌ Error: \(error.localizedDescription)")
}
```

### Integration with SwiftUI

```swift
// SwiftUI View to display the testing interface
struct TestingView: View {
    @StateObject private var testingService = APITestingService.shared

    var body: some View {
        VStack {
            // Button to run tests
            Button("Run Tests") {
                Task {
                    await testingService.runAllTests()
                }
            }

            // List to display test results
            List(testingService.testResults) { result in
                HStack {
                    Image(systemName: result.status.icon)
                        .foregroundColor(result.status.color)
                    Text(result.testName)
                    Spacer()
                    Text(result.status.rawValue)
                }
            }
        }
    }
}
```

## Best Practices

### 1. API Key Management

```swift
// ✅ Good Practice: Ensure API key is validated before configuration
func configureAPIKey(_ key: String) -> Bool {
    guard isValidAPIKey(key) else { return false }
    // Proceed with API configuration if valid
    return true
}

// ❌ Bad Practice: No validation before setting the API key
func configureAPIKey(_ key: String) {
    // Directly assign the key without checking validity
}
```

### 2. Error Handling

```swift
// ✅ Good Practice: Implement specific error handling for different scenarios
do {
    let data = try await fetchData()
} catch APIError.rateLimitExceeded {
    // Handle rate limit errors specifically
} catch APIError.invalidAPIKey {
    // Handle errors related to invalid API keys
} catch {
    // General handling for other types of errors
}

// ❌ Bad Practice: Utilize only generic error handling
do {
    let data = try await fetchData()
} catch {
    print("Something went wrong") // Non-specific error message
}
```

### 3. Rate Limiting

```swift
// ✅ Good Practice: Implement proper timing between API requests
for item in items {
    let result = try await processItem(item)
    try await Task.sleep(nanoseconds: 1_000_000_000) // Allow a 1-second delay
}

// ❌ Bad Practice: Neglecting rate limits in the request loop
for item in items {
    let result = try await processItem(item) // This will likely hit rate limits
}
```

### 4. Data Caching

```swift
// ✅ Good Practice: Optimize performance using caching techniques for reusable data
func fetchTodaysRaces() async throws -> [Race] {
    let cacheKey = "races_\(today)" // Use a unique key for caching
    if let cached = cache[cacheKey] {
        return cached // Return cached data if available
    }

    let fresh = try await realDataService.fetchTodaysRaces()
    cache[cacheKey] = fresh // Cache the new data for future use
    return fresh
}
```

### 5. Memory Management

```swift
// ✅ Good Practice: Use weak references in closures to avoid memory leaks
await dataSourceManager.withErrorHandling { [weak self] in
    return try await self?.fetchData()
} onError: { [weak self] error in
    self?.handleError(error)
}
```

## Troubleshooting

### Common Issues

1. **"Invalid API Key" Error**
   - Ensure the API key is correctly copied from the RapidAPI dashboard.
   - Validate the key to confirm it meets format requirements (32+ characters).
   - Confirm active subscription to the Horse Racing USA API.

2. **"Rate Limit Exceeded" Error**
   - Insert delays between requests to adhere to rate limits (1-second minimum).
   - Consider implementing exponential backoff strategies.
   - Utilize batch processing methods for making multiple requests.

3. **"No Data" Response**
   - Verify if races are scheduled on the current date for proper context.
   - Validate API endpoint availability and accessibility.
   - Confirm consistent network connectivity during requests.

4. **App Crashes on API Calls**
   - Implement comprehensive error handling mechanisms.
   - Inspect for potential memory leakage within asynchronous operations.
   - Validate compatibility and accuracy between data models and API responses.

### Debug Tools

```swift
// Enable enhanced logging features for debugging purposes
RealDataService.shared.enableDebugLogging = true

// Check the API's connectivity status
let status = await realDataService.checkConnection()
print("API Status: \(status)")

// Validate capabilities to use real data in the app
let canUseAPI = dataSourceManager.canUseRealData
print("Can use real data: \(canUseAPI)")
```

### Performance Monitoring

```swift
// Measure and monitor request timing for performance analysis
let startTime = Date()
let result = try await fetchData()
let duration = Date().timeIntervalSince(startTime)
print("Request took \(duration) seconds")

// Monitor memory usage before and after data operations
let memoryBefore = getMemoryUsage()
let data = try await fetchLargeDataset()
let memoryAfter = getMemoryUsage()
print("Memory used: \(memoryAfter - memoryBefore) MB")
```

## API Limitations & Workarounds

### Current Limitations

1. **Limited Horse Details**: Certain fields (e.g., color, foaling date) are not provided by the API.
2. **No Direct Jockey/Trainer Stats**: Statistics must be derived from available race data.
3. **No Historical Breeding Data**: Alternative mock data supplied for demonstration.
4. **No Speed Figures**: Speed figures like Beyer are unavailable in the current API.

### Workarounds Implemented

1. **Estimated Statistics**: Use algorithms to calculate stats from the most recent races.
2. **Mock Data Generation**: Generate realistic mock-ups for missing API data fields.
3. **Data Aggregation**: Aggregate multiple API response calls to compile comprehensive information.
4. **Fallback Values**: Apply default values for better handling missing information gracefully.

## Future Enhancements

1. **Additional APIs**: Plan to integrate supplementary data sources for expanded features.
2. **Caching Layer**: Implement advanced caching strategies for improved performance.
3. **Offline Mode**: Develop features to store and access critical data offline.
4. **Real-time Updates**: Consider incorporating WebSocket for up-to-the-minute data feeds.
5. **Analytics**: Introduce advanced metrics with data insights for enhanced analysis.

---

## Support

For technical support or questions about the API implementation:

1. Start by consulting this documentation for guidance.
2. Utilize the `APITestingService` to verify test results.
3. Examine the `APIUsageExamples` section for practical usage patterns.
4. Refer to the RapidAPI documentation for additional Horse Racing USA API information.
5. Monitor for rate limit warnings and error responses to better troubleshoot issues.

**Remember**: Always respect API rate limits and implement proper error handling for a robust user experience.