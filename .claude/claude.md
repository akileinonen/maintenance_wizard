# iOS Development - Maintenance Tracker Project

## Project Context

**Application**: Road Marking Machine Maintenance Tracker iOS App
**Platform**: iOS 15.0+
**Tech Stack**: Swift, SwiftUI, Firebase (Auth, Firestore, Storage)
**IDE**: Xcode
**Architecture**: MVVM with Firebase backend

## iOS Development Principles

### Swift & SwiftUI Best Practices

**Code Style**:
- Follow Swift API Design Guidelines
- Use Swift naming conventions (camelCase for properties/methods, PascalCase for types)
- Prefer `struct` over `class` for SwiftUI views and models (value semantics)
- Use `final class` for ViewModels and services (reference semantics)
- Leverage property wrappers: `@State`, `@Binding`, `@ObservedObject`, `@EnvironmentObject`, `@StateObject`
- Use `async/await` for asynchronous operations
- Prefer Swift native types over Objective-C types (String vs NSString, Array vs NSArray)

**SwiftUI Patterns**:
- Single Responsibility: Each view should have one clear purpose
- Extract subviews when body becomes complex (>10 lines)
- Use computed properties for derived state
- Avoid `@State` for complex objects; use `@StateObject` or `@ObservedObject` instead
- Keep view logic minimal; delegate business logic to ViewModels
- Use `@ViewBuilder` for conditional view composition
- Prefer `.task` over `.onAppear` for async operations

**Error Handling**:
- Use Swift's `Result` type for operations that can fail
- Throw custom errors conforming to `Error` protocol
- Use `do-catch` blocks for error handling
- Display user-friendly error messages in UI
- Log errors for debugging with `print()` or OSLog

**Performance**:
- Use `LazyVStack` and `LazyHStack` for long lists
- Implement pagination for large data sets
- Compress images before Firebase upload (max 2MB)
- Use `AsyncImage` with placeholder for network images
- Cache frequently accessed data
- Profile with Instruments for memory leaks and performance

### Firebase Integration

**Authentication**:
- Always check `Auth.auth().currentUser` before operations
- Handle auth state changes with `Auth.auth().addStateDidChangeListener`
- Store user profile data in Firestore, not just Auth
- Implement proper sign-out flow

**Firestore**:
- Use subcollections for hierarchical data when appropriate
- Implement proper error handling for network failures
- Use `.addSnapshotListener` for real-time updates
- Batch writes when updating multiple documents
- Use `.whereField()` for filtered queries
- Structure data for efficient queries (avoid deep nesting)

**Storage**:
- Store photos in logical paths: `companies/{companyId}/maintenance/{entryId}/{photoId}.jpg`
- Generate thumbnails for list views
- Use `StorageReference.putData()` with metadata
- Handle upload progress with `.observe(.progress)`
- Delete old photos when updating/deleting entries

**Security**:
- Implement and test Firestore Security Rules
- Never trust client-side validation alone
- Validate user roles server-side through Security Rules
- Use company isolation in all queries
- Sanitize user input before saving

### MVVM Architecture

**Models**:
- Pure Swift structs conforming to `Codable` and `Identifiable`
- Use `@DocumentID` for Firestore document IDs
- Include all necessary fields from Firebase schema
- Use enums for status fields (type-safe)

**ViewModels**:
- Conform to `ObservableObject`
- Use `@Published` for properties that trigger UI updates
- Handle all business logic and data operations
- Provide loading states (`isLoading`, `error`)
- Use `MainActor` for UI-related async operations
- Separate concerns: One ViewModel per main feature

**Views**:
- Only UI logic (layout, styling, user interaction)
- Observe ViewModels using `@StateObject` (owner) or `@ObservedObject` (dependency)
- Use `@EnvironmentObject` for app-wide state (e.g., AuthViewModel)
- Keep views focused and composable
- Extract reusable components

**Services**:
- Singleton pattern for Firebase services
- Handle all Firebase operations
- Return `async throws` for Firebase operations
- Provide clear error messages
- Log important operations

### Project Structure Guidelines

```
MaintenanceTracker/
├── App/                          # App entry point
├── Models/                       # Data models (Codable structs)
├── ViewModels/                   # Business logic (ObservableObject)
├── Views/                        # SwiftUI views
│   ├── Authentication/
│   ├── Machines/
│   ├── Maintenance/
│   ├── TimeTracking/
│   ├── Admin/
│   └── Components/              # Reusable UI components
├── Services/                    # Firebase & external services
├── Utilities/                   # Helpers, extensions, constants
└── Resources/                   # Assets, plists
```

## Development Workflow

### Phase-Based Development
- Follow the 8-phase plan in maintenance-tracker-ios-plan.md
- Complete each phase fully before moving to next
- Test each phase independently
- Commit after each working feature

### Testing Strategy
- Write unit tests for ViewModels and utility functions
- Test time calculation logic thoroughly
- Test Firebase integration with test data
- Manual testing on physical device for camera/photos
- Test offline behavior and error states
- Use TestFlight for beta testing

### Code Review Checklist
- [ ] Follows Swift naming conventions
- [ ] Proper error handling with user-friendly messages
- [ ] No force unwrapping (`!`) except for guaranteed cases
- [ ] Loading states implemented
- [ ] Empty states provided
- [ ] Accessibility labels for UI elements
- [ ] Images compressed before upload
- [ ] Firebase Security Rules protect data
- [ ] No sensitive data in logs
- [ ] ViewModels handle business logic, not Views

## Firebase Schema Reference

### Collections Structure
```
companies/
  {companyId}/
    - name: String
    - createdBy: String
    - createdDate: Timestamp
    - inviteCodes: [String]

users/
  {userId}/
    - email: String
    - name: String
    - companyId: String
    - role: String ("admin" | "user")
    - createdDate: Timestamp

machines/
  {machineId}/
    - companyId: String
    - machineId: String (user-friendly ID)
    - name: String
    - customCategories: [String]
    - createdDate: Timestamp
    - photoURL: String?

maintenance_entries/
  {entryId}/
    - companyId: String
    - machineId: String
    - category: String
    - description: String
    - estimatedTime: Double
    - photoURLs: [String]
    - status: String ("pending" | "in_progress" | "completed")
    - createdBy: String
    - createdByName: String
    - createdDate: Timestamp

time_entries/
  {timeEntryId}/
    - maintenanceEntryId: String
    - userId: String?
    - userName: String
    - date: Timestamp
    - startTime: String ("HH:mm")
    - endTime: String ("HH:mm")
    - lunchBreakDeducted: Bool
    - actualTimeSpent: Double
    - createdBy: String
    - createdDate: Timestamp

base_categories/
  {categoryId}/
    - name: String
```

## Common Patterns

### ViewModel Pattern
```swift
@MainActor
final class MachineViewModel: ObservableObject {
    @Published var machines: [Machine] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firebaseService: FirebaseService

    init(firebaseService: FirebaseService = .shared) {
        self.firebaseService = firebaseService
    }

    func fetchMachines(for companyId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            machines = try await firebaseService.fetchMachines(companyId: companyId)
        } catch {
            errorMessage = "Failed to load machines: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
```

### View Pattern
```swift
struct MachineListView: View {
    @StateObject private var viewModel = MachineViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.machines.isEmpty {
                    EmptyStateView(message: "No machines yet")
                } else {
                    List(viewModel.machines) { machine in
                        MachineRow(machine: machine)
                    }
                }
            }
            .navigationTitle("Machines")
            .task {
                if let companyId = authViewModel.user?.companyId {
                    await viewModel.fetchMachines(for: companyId)
                }
            }
        }
    }
}
```

### Firebase Service Pattern
```swift
final class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()

    func fetchMachines(companyId: String) async throws -> [Machine] {
        let snapshot = try await db.collection("machines")
            .whereField("companyId", isEqualTo: companyId)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            try? document.data(as: Machine.self)
        }
    }
}
```

## Key Implementation Details

### Photo Upload
1. Compress image to max 2MB using `UIImage.jpegData(compressionQuality:)`
2. Generate unique filename: `UUID().uuidString + ".jpg"`
3. Upload to path: `companies/{companyId}/maintenance/{entryId}/{filename}`
4. Store download URL in Firestore
5. Display with `AsyncImage` or cached loader

### Time Calculation
```swift
func calculateHours(from start: String, to end: String, deductLunch: Bool) -> Double {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"

    guard let startTime = formatter.date(from: start),
          let endTime = formatter.date(from: end) else {
        return 0
    }

    var hours = endTime.timeIntervalSince(startTime) / 3600
    if deductLunch { hours -= 0.5 }

    return max(0, hours)
}
```

### Role-Based Access
```swift
enum UserRole: String, Codable {
    case admin
    case user

    var isAdmin: Bool {
        self == .admin
    }
}

// In View
if authViewModel.user?.role.isAdmin == true {
    // Show admin UI
}
```

## Common Issues & Solutions

### Issue: SwiftUI view not updating
**Solution**: Ensure ViewModel uses `@Published` and View uses proper property wrapper (`@StateObject`, `@ObservedObject`)

### Issue: Firebase query returning old data
**Solution**: Use `.getDocuments(source: .server)` to bypass cache, or implement real-time listeners

### Issue: Image upload failing
**Solution**: Check Storage Rules, verify file size, ensure proper error handling and retry logic

### Issue: App crashes on logout
**Solution**: Clear all `@StateObject` and remove snapshot listeners in `.onDisappear`

### Issue: Time calculation incorrect
**Solution**: Verify date formatter format string, handle timezone properly, validate input times

## Resources

### Official Documentation
- [Swift Language Guide](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Key Firebase Guides
- [Firebase Auth iOS](https://firebase.google.com/docs/auth/ios/start)
- [Cloud Firestore iOS](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase Storage iOS](https://firebase.google.com/docs/storage/ios/start)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

## Project-Specific Commands

When working on this project, use these slash commands:

- `/implement` - Implement features following MVVM pattern
- `/build` - Build and run the Xcode project
- `/test` - Run unit tests and UI tests
- `/analyze --focus security` - Review Firebase Security Rules
- `/improve --focus performance` - Optimize image loading and Firebase queries
- `/document` - Generate documentation for ViewModels and Services

## Current Phase

Refer to [maintenance-tracker-ios-plan.md](maintenance-tracker-ios-plan.md) for the current development phase and tasks.
