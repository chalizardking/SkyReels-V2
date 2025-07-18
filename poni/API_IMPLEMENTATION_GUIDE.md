# Horse Racing App - API Implementation Guide

## Overview
This document outlines the complete API implementation for the Poni Horse Racing Analytics app, including all available endpoints, data mapping, and usage examples.

## API Configuration

### Horse Racing USA API (RapidAPI)
- **Base URL**: `https://horse-racing-usa.p.rapidapi.com`
- **Authentication**: RapidAPI Key required
- **Rate Limits**: Respect API rate limits with built-in delays

### API Key Setup
1. Visit [RapidAPI Horse Racing USA](https://rapidapi.com/divanshu-bansal/api/horse-racing-usa)
2. Subscribe to get your API key
3. Configure in app Settings

## Available Endpoints

### 1. Race Data

#### Fetch Today's Races
```swift
func fetchTodaysRaces() async throws -> [APIRacecard]
```
- **Endpoint**: `/racecards`
- **Returns**: Array of race cards with runners
- **Usage**: Main source for current race data

#### Fetch Race Results
```swift
func fetchRaceResults() async throws -> [APIRacecard]
```
- **Endpoint**: `/results`
- **Returns**: Historical race results
- **Usage**: Past performance analysis

#### Fetch Race Details
```swift
func fetchRaceDetails(raceId: String) async throws -> APIRacecard
```
- **Endpoint**: `/race/{raceId}`
- **Returns**: Detailed race information
- **Usage**: Specific race analysis

### 2. Horse Data

#### Search Horses
```swift
func searchHorses(query: String) async throws -> [APIHorseData]
```
- **Implementation**: Searches through race cards
- **Returns**: Filtered horses matching query
- **Search Fields**: Horse name, jockey, trainer, sire, dam

#### Fetch Horse Details
```swift
func fetchHorseDetails(horseId: String) async throws -> APIHorseData
```
- **Implementation**: Searches race cards for specific horse
- **Returns**: Horse information with connections
- **Usage**: Detailed horse profiles

#### Fetch Horse Results
```swift
func fetchHorseResults(horseId: String) async throws -> [APIRaceResult]
```
- **Implementation**: Creates race history from available data
- **Returns**: Mock race results based on participation
- **Usage**: Performance tracking

### 3. Jockey & Trainer Statistics

#### Fetch Jockey Stats
```swift
func fetchJockeyStats(jockeyId: String) async throws -> APIJockeyStats
```
- **Implementation**: Estimated stats from recent race data
- **Returns**: Win rate, ROI, performance metrics
- **Note**: Estimated data due to API limitations

#### Fetch Trainer Stats
```swift
func fetchTrainerStats(trainerId: String) async throws -> APITrainerStats
```
- **Implementation**: Estimated stats from recent race data
- **Returns**: Win rate, ROI, performance metrics
- **Note**: Estimated data due to API limitations

### 4. Additional Endpoints

#### Fetch Upcoming Races
```swift
func fetchUpcomingRaces() async throws -> [APIRacecard]
```
- **Implementation**: Alias for today's races
- **Returns**: Current race cards

#### Fetch Track Information
```swift
func fetchTrackInfo(trackName: String) async throws -> [APIRacecard]
```
- **Implementation**: Filters races by track name
- **Returns**: Track-specific race data

## Data Models

### API Response Models

```swift
struct APIRacecard: Codable {
    let race_id: String
    let race_name: String
    let race_time: String
    let course: String
    let distance: String
    let going: String?
    let race_class: String?
    let runners: [APIHorseData]
}

struct APIHorseData: Codable {
    let horse_id: String
    let horse: String
    let age: Int?
    let sex: String?
    let weight: String?
    let jockey: String?
    let jockey_id: String?
    let trainer: String?
    let trainer_id: String?
    let owner: String?
    let sire: String?
    let dam: String?
    let dam_sire: String?
    let foaling_date: String?
    let breeder: String?
    let odds: String?
}

struct APIRaceResult: Codable {
    let date: String
    let course: String
    let distance: String
    let position: String
    let runners: Int
    let going: String?
    let race_class: String?
    let prize: String?
    let time: String?
    let weight: String?
    let odds: String?
}

struct APIJockeyStats: Codable {
    let jockey_id: String
    let jockey: String
    let wins: Int
    let runs: Int
    let win_percentage: Double
    let place_percentage: Double
    let profit_loss: Double
    let roi: Double
}

struct APITrainerStats: Codable {
    let trainer_id: String
    let trainer: String
    let wins: Int
    let runs: Int
    let win_percentage: Double
    let place_percentage: Double
    let profit_loss: Double
    let roi: Double
}
```

## Data Mapping

### Horse Mapping
```swift
func mapAPIHorseDataToHorse(_ apiHorse: APIHorseData, with results: [APIRaceResult] = []) -> Horse
```
- Maps API horse data to app Horse model
- Calculates performance metrics from results
- Handles missing data with defaults

### ROI Data Mapping
```swift
func mapAPIJockeyStatsToROI(_ apiStats: APIJockeyStats) -> JockeyROIData
func mapAPITrainerStatsToROI(_ apiStats: APITrainerStats) -> TrainerROIData
```
- Converts API stats to ROI data structures
- Estimates missing time-period data

### Race History Mapping
```swift
func mapAPIResultsToRaceHistory(_ results: [APIRaceResult]) -> [RaceHistoryEntry]
```
- Converts race results to history entries
- Formats dates and positions

## Error Handling

### API Errors
```swift
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case noData
    case decodingError
    case networkError(String)
    case rateLimitExceeded
    case unauthorized
    case serverError(Int)
}
```

### Error Messages
- User-friendly error descriptions
- API key validation guidance
- Network connectivity checks

## Rate Limiting

### Implementation
- Built-in delays between API calls (500ms)
- Batch processing with limits
- Graceful degradation on rate limit exceeded

### Best Practices
- Limit search results (20-50 items)
- Cache frequently accessed data
- Use background queues for API calls

## Usage Examples

### Search for Horses
```swift
let horses = try await dataSourceManager.searchHorses(query: "Secretariat")
```

### Get Race Results
```swift
let races = try await dataSourceManager.fetchRaceResults()
```

### Fetch Jockey Performance
```swift
let jockeyROI = try await dataSourceManager.fetchJockeyROIData(for: "John Smith")
```

## Limitations & Workarounds

### API Limitations
1. **No dedicated horse search**: Implemented via race card filtering
2. **Limited jockey/trainer stats**: Estimated from race participation
3. **No historical data**: Limited to recent races
4. **No Beyer Speed figures**: Not available in current API
5. **Limited breeding data**: Basic sire/dam information only

### Workarounds
1. **Estimated Statistics**: Generate reasonable estimates for missing data
2. **Mock Data**: Provide placeholder data for unavailable fields
3. **Caching**: Store frequently accessed data locally
4. **Graceful Degradation**: Handle missing data elegantly

## Future Enhancements

### Additional APIs
1. **Equibase API**: For comprehensive historical data
2. **Breeding APIs**: For detailed pedigree information
3. **Speed Figure APIs**: For Beyer and other speed ratings
4. **Weather APIs**: For track condition data

### Data Enrichment
1. Local database for historical storage
2. Machine learning for performance predictions
3. Advanced analytics and insights
4. Real-time race tracking

## Testing

### API Testing
1. Test with valid API key
2. Test error handling with invalid key
3. Test rate limiting behavior
4. Test network connectivity issues

### Data Validation
1. Verify data mapping accuracy
2. Test with various horse names
3. Validate date parsing
4. Check performance calculations

## Deployment

### Production Considerations
1. Secure API key storage
2. Error logging and monitoring
3. Performance optimization
4. User feedback collection

### Monitoring
1. API response times
2. Error rates
3. User engagement metrics
4. Data quality metrics