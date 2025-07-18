# Poni App - AI Development Rules

## Tech Stack Overview

### Core Technologies
- **UI Framework**: SwiftUI (minimum iOS 17)
- **Data Layer**: SwiftData for persistence
- **Networking**: URLSession with async/await
- **State Management**: Native SwiftUI + ObservableObject
- **Concurrency**: Swift Concurrency (Tasks, Actors)
- **Testing**: XCTest + XCUITest
- **Logging**: Unified Logging (OSLog)
- **Build System**: Swift Package Manager

### Approved Services
- **Primary API**: Horse Racing USA API (RapidAPI)
- **Analytics**: Apple's App Analytics
- **Crash Reporting**: Apple Crash Reporter

## Development Rules

### 1. UI Development
#### Components:
- Use native SwiftUI components first
- Custom components must:
  - Be documented with /// comments
  - Support dynamic type
  - Be accessible
  - Support light/dark mode
- For complex lists: Use LazyVStack/LazyHStack
- Navigation: Native NavigationStack

#### Forbidden:
- No UIKit unless absolutely necessary
- No third-party component libraries
- No custom navigation solutions

### 2. Data Management
#### SwiftData:
- All models must be annotated with @Model
- Relationships must be explicitly defined
- Migration plans required for schema changes
- MainActor isolation for model operations

#### Caching:
- Memory cache: NSCache
- Disk cache: SwiftData
- No third-party caching solutions

### 3. Networking Layer
#### Requirements:
- All requests through RealDataService
- Rate limiting enforced (1 request/sec)
- Automatic retry for failed requests
- All endpoints must have mock data for testing

#### Error Handling:
- Custom APIError enum
- User-friendly error messages
- Network status monitoring

### 4. Testing Requirements
#### Unit Tests:
- 80% coverage minimum
- All view models must be tested
- All service layers must be tested
- Mock all network requests

#### UI Tests:
- Critical user journeys
- Accessibility validation
- Cross-device testing

### 5. Performance Rules
#### Must:
- Use Instruments for profiling
- Optimize image assets
- Implement pagination for large datasets
- Use lazy loading where possible

#### Avoid:
- Main thread blocking operations
- Force unwrapping
- Unbounded collections

### 6. Security Requirements
#### Data:
- No sensitive data in UserDefaults
- Secure API key storage
- Input validation for all text fields

#### Network:
- HTTPS required
- Certificate pinning
- No debug logging of API responses

### 7. Code Style
#### Formatting:
- 4-space indentation
- Type inference only when obvious
- Explicit access control
- 120 character line limit

#### Documentation:
- Public API: Full documentation
- Complex logic: Inline comments
- TODOs must include JIRA ticket

### Dependency Approval Process
1. Submit request to tech lead
2. Security review
3. Performance impact analysis
4. Maintenance assessment
5. Team approval

## Enforcement

### Code Review Checklist
- [ ] Follows style guide
- [ ] Proper error handling
- [ ] Accessibility support
- [ ] Performance considered
- [ ] Tests included
- [ ] Documentation complete

### Compliance Monitoring
- Weekly static analysis
- Monthly security audits
- Quarterly architecture reviews