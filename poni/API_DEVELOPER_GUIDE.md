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
// 1. Sign up at RapidAPI.com
// 2. Subscribe to "Horse Racing USA" API
// 3. Copy your API key
```

### 2. Configure API
```swift
let dataSourceManager = DataSourceManager.shared
let success = dataSourceManager.configureAPIKey("your-rapidapi-key")
```

### 3. Fetch Data
```swift
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
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   SwiftUI Views │───▶│ DataSourceManager│───▶│ RealDataService │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │DataMappingService│    │ Horse Racing API│
                       └──────────────────┘    └─────────────────┘
```

### Key Components

- **DataSourceManager**: High-level interface for all data operations
- **RealDataService**: Direct API communication and response handling
- **DataMappingService**: Converts API responses to app models
- **APITestingService**: Comprehensive testing and validation

## API Configuration

### API Details
- **Service**: Horse Racing USA API
- **Provider**: RapidAPI
- **Base URL**: `https://horse-racing-usa.p.rapidapi.com`
- **Rate Limit**: 1 request per second
- **Authentication**: RapidAPI Key in headers

### Configuration Code
```swift
// In DataSourceManager
func configureAPIKey(_ key: String) -> Bool {
    guard isValidAPIKey(key) else { return false }
    realDataService.updateAPIKey(key)
    return true
}

private func isValidAPIKey(_ key: String) -> Bool {
    return key.count >= 32 && key.allSatisfy { $0.isLetter || $0.isNumber }
}
```

## Core Services

### DataSourceManager

Main interface for all API operations:

```swift
class DataSourceManager: ObservableObject {
    // Configuration
    func configureAPIKey(_ key: String) -> Bool
    func canUseRealData -> Bool
    
    // Race Data
    func fetchTodaysRaces() async throws -> [Race]
    func fetchUpcomingRaces() async throws -> [Race]
    func fetchRaceResults() async throws -> [Race]
    
    // Horse Data
    func searchHorses(query: String) async throws -> [Horse]
    func fetchHorseDetails(horseId: String) async throws -> Horse
    
    // Statistics
    func fetchJockeyROIData() async throws -> [JockeyROIData]
    func fetchTrainerROIData() async throws -> [TrainerROIData]
    
    // Utility
    func refreshData() async
    func clearError()
}
```

### RealDataService

Direct API communication:

```swift
class RealDataService {
    // Core API Methods
    func fetchTodaysRaces() async throws -> [APIRacecard]
    func fetchRaceDetails(raceId: String) async throws -> APIRacecard
    func fetchHorseDetails(horseId: String) async throws -> APIHorseData
    func fetchRaceResults() async throws -> [APIRaceResult]
    
    // Search & Statistics
    func searchHorses(query: String) async throws -> [APIHorseData]
    func fetchJockeyStats(jockeyId: String) async throws -> APIJockeyStats
    func fetchTrainerStats(trainerId: String) async throws -> APITrainerStats
    
    // Utility
    func checkConnection() async -> Bool
    func updateAPIKey(_ key: String)
}
```

### DataMappingService

Converts API models to app models:

```swift
class DataMappingService {
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
// Race Data
struct APIRacecard: Codable {
    let race_id: String
    let race_name: String
    let course: String
    let race_time: String
    let runners: [APIRunner]
}

struct APIRunner: Codable {
    let horse_id: String?
    let horse: String
    let jockey: String?
    let trainer: String?
    let weight: String?
    let odds: String?
}

// Horse Data
struct APIHorseData: Codable {
    let horse_id: String
    let horse: String
    let age: Int?
    let sex: String?
    let trainer: String?
    let owner: String?
}

// Statistics
struct APIJockeyStats: Codable {
    let jockey: String
    let wins: Int
    let runs: Int
    let win_percentage: Double
    let recent_form: [String]
}
```

### App Models

```swift
// Example model structure (actual models are defined in Models/ directory)
struct ExampleHorseData {
    let id: String
    let name: String
    let age: Int
    let trainer: String?
    let jockey: String?
    let earnings: Double
}

struct ExampleRaceData {
    let id: String
    let name: String
    let date: Date
    let track: String
    let distance: Double
}
```

## Usage Examples

### Basic Data Fetching

```swift
// Fetch today's races
Task {
    do {
        let races = try await dataSourceManager.fetchTodaysRaces()
        for race in races {
            print("\(race.name) at \(race.track)")
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
```

### Horse Search and Analysis

```swift
// Search for horses and analyze performance
Task {
    do {
        let horses = try await dataSourceManager.searchHorses(query: "")
        
        for horse in horses.prefix(5) {
            let details = try await realDataService.fetchHorseDetails(horseId: horse.id)
            let results = try await realDataService.fetchHorseResults(horseId: horse.id)
            
            let recentWins = results.prefix(5).filter { $0.position == 1 }.count
            print("\(horse.name): \(recentWins) wins in last 5 races")
            
            // Rate limiting
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
```

### Jockey/Trainer Analysis

```swift
// Analyze jockey performance
Task {
    do {
        let roiData = try await dataSourceManager.fetchJockeyROIData()
        let topJockeys = roiData.sorted { $0.roi30Days > $1.roi30Days }.prefix(10)
        
        for jockey in topJockeys {
            print("\(jockey.name): ROI \(jockey.roi30Days)")
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
```

## Error Handling

### Error Types

```swift
enum APIError: Error, LocalizedError {
    case invalidAPIKey
    case rateLimitExceeded
    case networkError(String)
    case noData
    case invalidResponse
    case serverError(Int)
    
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
// Pattern 1: Basic try-catch
do {
    let races = try await dataSourceManager.fetchTodaysRaces()
    // Handle success
} catch APIError.invalidAPIKey {
    // Handle invalid API key
} catch APIError.rateLimitExceeded {
    // Handle rate limit
} catch {
    // Handle other errors
}

// Pattern 2: Using DataSourceManager's error handling
await dataSourceManager.withErrorHandling {
    return try await realDataService.fetchTodaysRaces()
} onError: { error in
    print("Error: \(error.localizedDescription)")
}
```

## Rate Limiting

### Implementation

```swift
class RealDataService {
    private var lastRequestTime: Date?
    private let minimumRequestInterval: TimeInterval = 1.0 // 1 second
    
    private func enforceRateLimit() async {
        if let lastTime = lastRequestTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < minimumRequestInterval {
                let delay = minimumRequestInterval - elapsed
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }
}
```

### Best Practices

1. **Always add delays between requests**:
   ```swift
   for item in items {
       let result = try await fetchData(item)
       try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
   }
   ```

2. **Use batch processing**:
   ```swift
   let batches = items.chunked(into: 5)
   for batch in batches {
       // Process batch
       try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds between batches
   }
   ```

3. **Handle rate limit errors gracefully**:
   ```swift
   catch APIError.rateLimitExceeded {
       try await Task.sleep(nanoseconds: 10_000_000_000) // Wait 10 seconds
       // Retry request
   }
   ```

## Testing

### Using APITestingService

```swift
let testingService = APITestingService.shared

// Run all tests
Task {
    await testingService.runAllTests()
    
    // Check results
    for result in testingService.testResults {
        print("\(result.testName): \(result.status)")
    }
}
```

### Manual Testing

```swift
// Test API connection
let isConnected = await realDataService.checkConnection()
print("API Connected: \(isConnected)")

// Test data fetching
do {
    let races = try await realDataService.fetchTodaysRaces()
    print("✅ Fetched \(races.count) races")
} catch {
    print("❌ Error: \(error.localizedDescription)")
}
```

### Integration with SwiftUI

```swift
struct TestingView: View {
    @StateObject private var testingService = APITestingService.shared
    
    var body: some View {
        VStack {
            Button("Run Tests") {
                Task {
                    await testingService.runAllTests()
                }
            }
            
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
// ✅ Good: Validate API key format
func configureAPIKey(_ key: String) -> Bool {
    guard isValidAPIKey(key) else { return false }
    // Configure API
    return true
}

// ❌ Bad: No validation
func configureAPIKey(_ key: String) {
    // Direct assignment without validation
}
```

### 2. Error Handling

```swift
// ✅ Good: Specific error handling
do {
    let data = try await fetchData()
} catch APIError.rateLimitExceeded {
    // Specific handling for rate limits
} catch APIError.invalidAPIKey {
    // Specific handling for API key issues
} catch {
    // Generic error handling
}

// ❌ Bad: Generic error handling only
do {
    let data = try await fetchData()
} catch {
    print("Something went wrong")
}
```

### 3. Rate Limiting

```swift
// ✅ Good: Proper rate limiting
for item in items {
    let result = try await processItem(item)
    try await Task.sleep(nanoseconds: 1_000_000_000)
}

// ❌ Bad: No rate limiting
for item in items {
    let result = try await processItem(item) // Will hit rate limits
}
```

### 4. Data Caching

```swift
// ✅ Good: Cache frequently accessed data
func fetchTodaysRaces() async throws -> [Race] {
    let cacheKey = "races_\(today)"
    if let cached = cache[cacheKey] {
        return cached
    }
    
    let fresh = try await realDataService.fetchTodaysRaces()
    cache[cacheKey] = fresh
    return fresh
}
```

### 5. Memory Management

```swift
// ✅ Good: Use weak references in closures
await dataSourceManager.withErrorHandling { [weak self] in
    return try await self?.fetchData()
} onError: { [weak self] error in
    self?.handleError(error)
}
```

## Troubleshooting

### Common Issues

1. **"Invalid API Key" Error**
   - Verify API key from RapidAPI dashboard
   - Check key format (should be 32+ characters)
   - Ensure subscription to Horse Racing USA API

2. **"Rate Limit Exceeded" Error**
   - Add delays between requests (minimum 1 second)
   - Implement exponential backoff
   - Use batch processing for multiple requests

3. **"No Data" Response**
   - Check if races are scheduled for the current date
   - Verify API endpoint availability
   - Check network connectivity

4. **App Crashes on API Calls**
   - Ensure proper error handling
   - Check for memory leaks in async operations
   - Verify data model compatibility

### Debug Tools

```swift
// Enable detailed logging
RealDataService.shared.enableDebugLogging = true

// Check API status
let status = await realDataService.checkConnection()
print("API Status: \(status)")

// Validate configuration
let canUseAPI = dataSourceManager.canUseRealData
print("Can use real data: \(canUseAPI)")
```

### Performance Monitoring

```swift
// Monitor request timing
let startTime = Date()
let result = try await fetchData()
let duration = Date().timeIntervalSince(startTime)
print("Request took \(duration) seconds")

// Monitor memory usage
let memoryBefore = getMemoryUsage()
let data = try await fetchLargeDataset()
let memoryAfter = getMemoryUsage()
print("Memory used: \(memoryAfter - memoryBefore) MB")
```

## API Limitations & Workarounds

### Current Limitations

1. **Limited Horse Details**: Some fields (color, foaling date) not available
2. **No Direct Jockey/Trainer Stats**: Generated from race data
3. **No Historical Breeding Data**: Mock data provided
4. **No Speed Figures**: Beyer speed not available

### Workarounds Implemented

1. **Estimated Statistics**: Calculate jockey/trainer stats from recent races
2. **Mock Data Generation**: Provide realistic mock data for missing fields
3. **Data Aggregation**: Combine multiple API calls for comprehensive data
4. **Fallback Values**: Use sensible defaults for missing information

## Future Enhancements

1. **Additional APIs**: Integrate supplementary data sources
2. **Caching Layer**: Implement sophisticated caching strategy
3. **Offline Mode**: Store critical data for offline access
4. **Real-time Updates**: WebSocket integration for live data
5. **Analytics**: Advanced performance metrics and insights

---

## Support

For technical support or questions about the API implementation:

1. Check this documentation first
2. Review the `APITestingService` results
3. Examine the `APIUsageExamples` for patterns
4. Check RapidAPI documentation for Horse Racing USA API
5. Monitor rate limits and error responses

**Remember**: Always respect API rate limits and implement proper error handling for a robust user experience.