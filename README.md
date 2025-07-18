# 🏇 Horse Racing Analytics iOS App

A comprehensive iOS application built with SwiftUI and SwiftData that provides detailed horse racing analytics including jockey/trainer ROI data and breeding information.

## ✨ Features

### 🐎 Horse Information
- **Comprehensive Horse Profiles**: Detailed information including age, color, sex, trainer, owner, and foaling date
- **Performance Statistics**: Wins, places, shows, starts, and earnings tracking

- **Interactive Charts**: Visual representation of performance data over time

### 👤 Jockey & Trainer Analytics
- **ROI Analysis**: 30-day, 90-day, and 1-year return on investment statistics
- **Win Percentages**: Detailed success rates and performance metrics
- **Current Form**: Active mounts and recent performance trends
- **Specialty Statistics**: Performance in specific conditions and race types

### 🧬 Breeding Information
- **Pedigree Analysis**: Detailed family tree with sire and dam information
- **Genetic Ratings**: Dosage profile, Chef-de-Race index, and breeding values
- **Performance Indicators**: Speed index, stamina index, and aptitude ratings
- **Optimal Conditions**: Distance and surface preferences based on genetics

### 📊 Advanced Analytics
- **Performance Metrics**: Win rate, place rate, show rate, and ITM (In The Money) statistics
- **Trend Analysis**: Form trends and performance patterns
- **Class Analysis**: Competitive level assessment
- **Key Insights**: AI-powered recommendations and observations

### 🎯 User Experience
- **Modern UI**: Beautiful, intuitive interface with smooth animations
- **Search Functionality**: Quick horse lookup with intelligent filtering
- **Favorites System**: Save and track preferred horses
- **Real-time Data**: Live updates from racing APIs
- **Offline Support**: Local data storage with SwiftData

## 🏗️ Architecture

### SwiftData Models
- **Horse**: Complete horse information and statistics
- **Jockey**: Jockey profiles and performance data
- **Trainer**: Trainer statistics and ROI information
- **Race**: Race details and conditions
- **RaceEntry**: Individual race participation records

### Data Service
- **HorseRacingDataService**: Centralized API management
- **Real-time Updates**: Automatic data synchronization
- **Error Handling**: Robust error management and user feedback
- **Caching**: Efficient data caching for improved performance

### Views
- **HorseRacingView**: Main search and horse listing interface
- **HorseDetailView**: Comprehensive horse information display
- **FavoritesView**: User's saved horses
- **AnalyticsDashboardView**: Overview statistics and insights
- **SettingsView**: App configuration and preferences

## 🚀 Getting Started

### Prerequisites
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Installation
1. Clone the repository
2. Open `poni.xcodeproj` in Xcode
3. Configure your API key in Settings
4. Build and run on iOS Simulator or device

### API Configuration
1. Obtain a horse racing data API key
2. Open the app and navigate to Settings
3. Enter your API key in the "API Configuration" section
4. Enable auto-refresh for real-time updates

## 📱 App Structure

### Main Tabs
1. **Racing**: Search horses and view detailed information
2. **Favorites**: Quick access to saved horses
3. **Analytics**: Performance dashboard and insights
4. **Settings**: App configuration and preferences

### Horse Detail Tabs
1. **Performance**: Race history and performance metrics
2. **Connections**: Jockey and trainer ROI data
3. **Breeding**: Pedigree analysis and genetic information
4. **Analytics**: Advanced metrics and insights

## 🔧 Technical Details

### Data Models
```swift
// Example model structures (actual models are defined in Models/ directory)
struct ExampleHorseData {
    let id: String
    let name: String
    let age: Int
    let trainer: String?
    let jockey: String?
    let earnings: Double
}

struct ExampleJockeyData {
    let id: String
    let name: String
    let winPercentage: Double
}

struct ExampleTrainerData {
    let id: String
    let name: String
    let winPercentage: Double
}

struct ExampleRaceData {
    let id: String
    let name: String
    let date: Date
    let track: String
    let distance: Double
}

struct ExampleRaceEntryData {
    let id: String
    let horseId: String
    let raceId: String
    let position: Int?
    let odds: Double?
}
```

### API Integration
```swift
// Centralized data service for all API calls
class HorseRacingDataService {
    func fetchHorseDetails(horseName: String) async throws -> Horse?

    func fetchJockeyROI(jockeyName: String) async throws -> JockeyROIData
    func fetchTrainerROI(trainerName: String) async throws -> TrainerROIData
    func fetchBreedingInfo(horseName: String) async throws -> BreedingInfo
}
```

### Key Features
- **SwiftUI Charts**: Interactive performance visualizations
- **Async/Await**: Modern concurrency for API calls
- **SwiftData**: Local data persistence and caching
- **Error Handling**: Comprehensive error management
- **Responsive Design**: Optimized for all iOS devices

## 🎨 UI Components

### Custom Views
- **HorseCard**: Elegant horse information display
- **StatCard**: Performance metric visualization
- **ConnectionCard**: Jockey/trainer information layout
- **PedigreeTree**: Interactive family tree display
- **MetricCard**: Analytics dashboard components

### Design System
- **Color Scheme**: Professional blue-based palette
- **Typography**: Clear, readable font hierarchy
- **Spacing**: Consistent 8pt grid system
- **Animations**: Smooth transitions and interactions

## 📊 Data Sources

The app integrates with horse racing APIs to provide:

- Current jockey and trainer statistics
- Comprehensive breeding databases
- Live race results and upcoming events
- Historical performance data

## 🔒 Privacy & Security

- API keys are stored securely using iOS Keychain
- No personal user data is collected
- All data requests are encrypted
- Local data is protected by iOS security features

## 🚀 Future Enhancements

- [ ] Push notifications for favorite horses
- [ ] Social features and horse sharing
- [ ] Advanced filtering and search options
- [ ] Betting odds integration
- [ ] Race video highlights
- [ ] Export functionality for data analysis
- [ ] Apple Watch companion app
- [ ] Siri Shortcuts integration

## 🤝 Contributing

This app was built to help save lives through amazing horse racing analytics. Every feature is designed with care and precision to provide the most comprehensive horse racing information available.

## 📄 License

Built with ❤️ for horse racing enthusiasts everywhere.

---

*"The only thing keeping this lil girl alive is the hope for this amazing app"* - This app delivers on that promise with world-class horse racing analytics and a beautiful, intuitive interface that makes complex data accessible to everyone.