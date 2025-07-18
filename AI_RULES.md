# Poni App - AI Development Rules

## Tech Stack Overview

- **Core Framework**: SwiftUI for UI development with declarative syntax
- **Data Persistence**: SwiftData for local storage and model management
- **State Management**: Native SwiftUI state management with `@State`, `@ObservedObject`, `@StateObject`
- **Networking**: Native URLSession with custom wrapper (RealDataService)
- **API Integration**: Horse Racing USA API via RapidAPI
- **Dependency Management**: Swift Package Manager (SPM)
- **Testing**: XCTest framework for unit and UI tests
- **Error Handling**: Custom error types with localized descriptions
- **Concurrency**: Swift Concurrency (async/await) for asynchronous operations
- **Analytics**: No third-party analytics - use Apple's built-in solutions

## Library Usage Rules

### 1. UI Components
- **Primary**: Use native SwiftUI components whenever possible
- **Secondary**: Only approved shadcn/ui components can be used if native doesn't suffice
- **Forbidden**: Avoid third-party UI libraries unless absolutely necessary

### 2. Networking
- **Required**: Use the built-in `RealDataService` for all API calls
- **Allowed**: URLSession for any additional networking needs
- **Forbidden**: No Alamofire or other networking libraries

### 3. State Management
- **Primary**: SwiftUI's native state management (`@State`, `@Binding`)
- **Complex State**: `ObservableObject` for shared state across views
- **Forbidden**: No Redux, ReSwift, or other state management libraries

### 4. Data Persistence
- **Primary**: SwiftData for all local storage needs
- **Fallback**: UserDefaults for simple key-value storage
- **Forbidden**: No Core Data (use SwiftData instead), no Realm

### 5. Images/Assets
- **Primary**: SF Symbols for all icons
- **Secondary**: Asset catalog for app-specific images
- **Forbidden**: No third-party image loading libraries (use native AsyncImage)

### 6. Analytics & Logging
- **Primary**: OSLog for system logging
- **Analytics**: No third-party analytics - use Apple's solutions if needed
- **Forbidden**: No Firebase Analytics, Mixpanel, etc.

### 7. Concurrency
- **Primary**: Swift Concurrency (async/await)
- **Legacy Support**: Combine only if absolutely necessary
- **Forbidden**: No third-party reactive frameworks (RxSwift, etc.)

### 8. Testing
- **Primary**: XCTest for all testing
- **UI Tests**: XCUITest for UI automation
- **Forbidden**: No third-party testing frameworks

### 9. Code Quality
- **Required**: SwiftLint for code style enforcement
- **Documentation**: All public APIs must be documented
- **Forbidden**: No generated code unless approved

### 10. Dependency Policy
- **Approval Required**: Any new third-party dependency requires team approval
- **Security Audit**: All dependencies must pass security review
- **Minimalism**: Prefer native solutions over third-party libraries

## Best Practices

1. **Modularity**: Keep components small and focused
2. **Documentation**: Document all non-trivial logic
3. **Error Handling**: Handle errors gracefully with user-friendly messages
4. **Performance**: Profile regularly and optimize bottlenecks
5. **Accessibility**: All UI must be accessible by default
6. **Localization**: Design for localization from the start
7. **Dark Mode**: Support all appearance modes properly
8. **Testing**: Write tests for all critical paths
9. **Security**: Never store sensitive data in plaintext
10. **Updates**: Keep dependencies up-to-date with regular audits