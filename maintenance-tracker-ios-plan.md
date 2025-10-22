# Road Marking Machine Maintenance Tracker - iOS App Development Plan

## Project Overview
An iOS application for tracking maintenance needs for road marking machines with Firebase backend, company-based user management, and time tracking capabilities.

## Tech Stack
- **Platform**: iOS (iPhone)
- **IDE**: Xcode
- **Language**: Swift + SwiftUI
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore (Database)
  - Firebase Storage (Photos)
- **Minimum iOS Version**: iOS 15.0+

## Project Structure

```
MaintenanceTracker/
├── App/
│   ├── MaintenanceTrackerApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Company.swift
│   ├── User.swift
│   ├── Machine.swift
│   ├── MaintenanceEntry.swift
│   ├── TimeEntry.swift
│   └── Category.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── CompanyViewModel.swift
│   ├── MachineViewModel.swift
│   ├── MaintenanceViewModel.swift
│   └── TimeTrackingViewModel.swift
├── Views/
│   ├── Authentication/
│   │   ├── LoginView.swift
│   │   ├── SignUpView.swift
│   │   └── CompanySetupView.swift
│   ├── Machines/
│   │   ├── MachineListView.swift
│   │   ├── MachineDetailView.swift
│   │   └── AddMachineView.swift
│   ├── Maintenance/
│   │   ├── MaintenanceListView.swift
│   │   ├── MaintenanceDetailView.swift
│   │   ├── AddMaintenanceView.swift
│   │   └── MaintenanceFilterView.swift
│   ├── TimeTracking/
│   │   ├── TimeEntryListView.swift
│   │   └── AddTimeEntryView.swift
│   ├── Admin/
│   │   ├── AdminDashboardView.swift
│   │   ├── CategoryManagementView.swift
│   │   ├── UserManagementView.swift
│   │   └── InviteUserView.swift
│   └── Components/
│       ├── PhotoPickerView.swift
│       ├── ImageGalleryView.swift
│       └── CustomTextField.swift
├── Services/
│   ├── FirebaseService.swift
│   ├── AuthService.swift
│   ├── StorageService.swift
│   └── NotificationService.swift
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions.swift
│   └── Helpers.swift
└── Resources/
    ├── Assets.xcassets
    └── GoogleService-Info.plist
```

## Development Phases

### Phase 1: Project Setup & Firebase Configuration
**Goal**: Get the basic project structure and Firebase connection working

**Tasks**:
1. Create new iOS project in Xcode
   - Select "App" template
   - Interface: SwiftUI
   - Language: Swift
   - Include Tests: Yes

2. Install Firebase SDK
   - Add Firebase using Swift Package Manager
   - Required packages:
     - FirebaseAuth
     - FirebaseFirestore
     - FirebaseStorage
   - Add GoogleService-Info.plist to project

3. Set up Firebase project
   - Create Firebase project at console.firebase.google.com
   - Enable Authentication (Email/Password)
   - Create Firestore Database (start in test mode, secure later)
   - Enable Storage for images
   - Download GoogleService-Info.plist

4. Configure Info.plist
   - Add camera and photo library usage descriptions
   - Configure Firebase initialization in App file

5. Create basic folder structure as outlined above

**Deliverable**: Empty app that successfully connects to Firebase

---

### Phase 2: Authentication & Company Setup
**Goal**: Users can sign up, log in, and create/join companies

**Models to Create**:
```swift
struct User {
    let id: String
    let email: String
    let name: String
    let companyId: String
    let role: UserRole // .admin or .user
    let createdDate: Date
}

struct Company {
    let id: String
    let name: String
    let createdBy: String
    let createdDate: Date
    var inviteCodes: [String]
}

enum UserRole: String, Codable {
    case admin
    case user
}
```

**Services to Create**:
- AuthService: Handle login, signup, logout
- FirebaseService: Basic CRUD operations

**Views to Create**:
1. LoginView
   - Email and password fields
   - Login button
   - Link to SignUpView

2. SignUpView
   - Name, email, password fields
   - Option: "Create new company" or "Join existing company"
   - If create: Show company name field
   - If join: Show invite code field

3. CompanySetupView
   - For new companies: Enter company name
   - For joining: Enter invite code

**Firebase Structure**:
```
companies/
  {companyId}/
    - name: string
    - createdBy: string
    - createdDate: timestamp
    - inviteCodes: array

users/
  {userId}/
    - email: string
    - name: string
    - companyId: string
    - role: string
    - createdDate: timestamp
```

**Deliverable**: Users can create accounts, create companies, and log in

---

### Phase 3: Machine Management
**Goal**: View and manage machines

**Models to Create**:
```swift
struct Machine {
    let id: String
    let companyId: String
    let machineId: String // User-friendly ID like "RM-001"
    let name: String
    var customCategories: [String]
    let createdDate: Date
    var photoURL: String?
}

struct Category {
    let id: String
    let name: String
    let isBase: Bool // true for base categories, false for custom
    let machineId: String? // nil for base, machineId for custom
}
```

**Views to Create**:
1. MachineListView
   - List of all company machines
   - Search bar
   - Each row shows: machine ID, name, thumbnail
   - Tap to open MachineDetailView
   - Admin only: "+" button to add machine

2. MachineDetailView
   - Machine ID and name at top
   - Maintenance overview section:
     - Total pending items
     - Total estimated time
   - "Add Maintenance Entry" button
   - List of maintenance entries (filtered by this machine)
   - Filter/sort options

3. AddMachineView (Admin only)
   - Machine ID field
   - Name field
   - Optional photo
   - Save button

**Firebase Structure**:
```
machines/
  {machineId}/
    - companyId: string
    - machineId: string
    - name: string
    - customCategories: array
    - createdDate: timestamp
    - photoURL: string

base_categories/
  {categoryId}/
    - name: string
```

**Deliverable**: Users can view machines and navigate to machine details. Admins can add machines.

---

### Phase 4: Maintenance Entry Creation
**Goal**: Create and view maintenance entries with photos

**Models to Create**:
```swift
struct MaintenanceEntry {
    let id: String
    let companyId: String
    let machineId: String
    let category: String
    let description: String
    let estimatedTime: Double // in hours
    var photoURLs: [String]
    let status: MaintenanceStatus
    let createdBy: String
    let createdByName: String
    let createdDate: Date
}

enum MaintenanceStatus: String, Codable {
    case pending
    case inProgress = "in_progress"
    case completed
}
```

**Services to Create**:
- StorageService: Upload/download photos from Firebase Storage

**Views to Create**:
1. AddMaintenanceView
   - Category picker (base + machine custom categories)
   - Description text editor
   - Time estimate field (numeric with "hours" label)
   - Photo picker (multiple photos)
   - Show thumbnails of selected photos
   - Submit button

2. PhotoPickerView (Component)
   - Use PHPickerViewController wrapped in SwiftUI
   - Allow multiple selection
   - Show selected images in grid

3. MaintenanceListView (in MachineDetailView)
   - List of maintenance entries
   - Each row shows:
     - Category badge
     - Description (truncated)
     - Estimated time
     - Status indicator
     - First photo thumbnail
   - Filter by category dropdown
   - Filter by status
   - Sort options (date, time estimate)

4. MaintenanceDetailView
   - Full details of entry
   - Photo gallery (swipeable)
   - Time entries list
   - "Add Time Entry" button
   - Admin: Edit/Delete options

**Firebase Structure**:
```
maintenance_entries/
  {entryId}/
    - companyId: string
    - machineId: string
    - category: string
    - description: string
    - estimatedTime: number
    - photoURLs: array
    - status: string
    - createdBy: string
    - createdByName: string
    - createdDate: timestamp
```

**Photo Storage**:
```
Storage: companies/{companyId}/maintenance/{entryId}/{photoId}.jpg
```

**Deliverable**: Users can create maintenance entries with photos and view them

---

### Phase 5: Time Tracking
**Goal**: Log time spent on maintenance tasks

**Models to Create**:
```swift
struct TimeEntry {
    let id: String
    let maintenanceEntryId: String
    let userId: String? // nil for guest
    let userName: String
    let date: Date
    let startTime: String // "08:00"
    let endTime: String // "16:30"
    let lunchBreakDeducted: Bool
    let actualTimeSpent: Double // calculated in hours
    let createdBy: String
    let createdDate: Date
}
```

**Views to Create**:
1. TimeEntryListView (in MaintenanceDetailView)
   - List of all time entries for this maintenance task
   - Shows: Person, date, time range, hours spent
   - Total hours at top
   - Edit/delete options

2. AddTimeEntryView
   - Person picker (dropdown of company users + "Guest/Other" option)
   - If guest: Show text field for name
   - Date picker
   - Start time picker
   - End time picker
   - Checkbox: "Deduct lunch break (30 min)"
   - Auto-calculated hours displayed
   - Save button

**Helper Functions**:
```swift
func calculateTimeSpent(start: String, end: String, deductLunch: Bool) -> Double {
    // Parse time strings
    // Calculate difference
    // Subtract 0.5 hours if deductLunch is true
    // Return hours as Double
}
```

**Firebase Structure**:
```
time_entries/
  {timeEntryId}/
    - maintenanceEntryId: string
    - userId: string (or null)
    - userName: string
    - date: timestamp
    - startTime: string
    - endTime: string
    - lunchBreakDeducted: boolean
    - actualTimeSpent: number
    - createdBy: string
    - createdDate: timestamp
```

**Deliverable**: Users can log time entries and view time tracking history

---

### Phase 6: Admin Panel
**Goal**: Admin users can manage categories, users, and companies

**Views to Create**:
1. AdminDashboardView
   - Only visible to admin users
   - Navigation to:
     - Category Management
     - User Management
     - Machine Management
   - Company statistics overview

2. CategoryManagementView
   - Tab 1: Base Categories
     - List of base categories
     - Add/edit/delete buttons
   - Tab 2: Machine-Specific Categories
     - Select machine dropdown
     - Show custom categories for selected machine
     - Add/edit/delete buttons

3. UserManagementView
   - List of all company users
   - Shows: Name, email, role
   - Change role button
   - Generate invite code button
   - Remove user option

4. InviteUserView
   - Generate new invite code
   - Display code (copyable)
   - Show list of existing invite codes
   - Revoke code option

**Admin Features**:
- Check user role on app launch
- Show/hide admin menu based on role
- Protect admin actions in Firebase Security Rules

**Firebase Security Rules** (to implement):
```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function belongsToCompany(companyId) {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.companyId == companyId;
    }
    
    // Users can read their own data
    match /users/{userId} {
      allow read: if isAuthenticated() && request.auth.uid == userId;
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }
    
    // Company data
    match /companies/{companyId} {
      allow read: if belongsToCompany(companyId);
      allow write: if isAdmin() && belongsToCompany(companyId);
    }
    
    // Machines
    match /machines/{machineId} {
      allow read: if belongsToCompany(resource.data.companyId);
      allow create: if isAdmin() && belongsToCompany(request.resource.data.companyId);
      allow update, delete: if isAdmin() && belongsToCompany(resource.data.companyId);
    }
    
    // Maintenance entries
    match /maintenance_entries/{entryId} {
      allow read: if belongsToCompany(resource.data.companyId);
      allow create: if belongsToCompany(request.resource.data.companyId);
      allow update, delete: if belongsToCompany(resource.data.companyId);
    }
    
    // Time entries
    match /time_entries/{timeEntryId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAuthenticated();
    }
    
    // Base categories
    match /base_categories/{categoryId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
  }
}
```

**Deliverable**: Admin users can manage all aspects of the system

---

### Phase 7: UI Polish & User Experience
**Goal**: Make the app look professional and easy to use

**Tasks**:
1. Design consistent color scheme
   - Primary color
   - Secondary color
   - Accent colors for status (pending: yellow, in progress: blue, completed: green)

2. Create reusable components
   - Custom buttons with loading states
   - Custom text fields with validation
   - Alert/confirmation dialogs
   - Loading spinners

3. Add empty states
   - "No machines yet" with call to action
   - "No maintenance entries" placeholder
   - "No time entries logged"

4. Implement pull-to-refresh on lists

5. Add search functionality to lists
   - Machine list
   - Maintenance entry list
   - User list (admin)

6. Image optimization
   - Compress photos before upload
   - Generate thumbnails
   - Lazy loading for image galleries

7. Error handling
   - Network error messages
   - Firebase error messages
   - Form validation errors
   - Offline mode indicators

8. Loading states
   - Skeleton screens for lists
   - Progress indicators for uploads
   - Shimmer effects

**Deliverable**: Polished, professional-looking app with smooth UX

---

### Phase 8: Testing & Deployment
**Goal**: Test thoroughly and prepare for App Store

**Tasks**:
1. Unit Tests
   - Test calculation functions (time tracking)
   - Test data models
   - Test ViewModels

2. UI Tests
   - Test main user flows
   - Test admin flows
   - Test photo upload

3. Manual Testing Checklist
   - Create company
   - Invite user
   - Add machine
   - Create maintenance entry with photos
   - Log time entry
   - Filter and sort lists
   - Admin category management
   - Offline behavior

4. App Store Preparation
   - Create app icons (all sizes)
   - Create launch screen
   - Write app description
   - Take screenshots
   - Privacy policy
   - Terms of service

5. TestFlight Distribution
   - Add internal testers
   - Collect feedback
   - Fix bugs

6. App Store Submission
   - Complete App Store Connect listing
   - Submit for review
   - Address any review feedback

**Deliverable**: Published app on App Store

---

## Key Implementation Notes

### Firebase Configuration
```swift
// MaintenanceTrackerApp.swift
import SwiftUI
import Firebase

@main
struct MaintenanceTrackerApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthViewModel())
        }
    }
}
```

### Photo Upload Strategy
1. Compress image to reasonable size (max 2MB)
2. Generate unique filename: `UUID().uuidString + ".jpg"`
3. Upload to Firebase Storage: `companies/{companyId}/maintenance/{entryId}/{filename}`
4. Store download URL in Firestore
5. Display using AsyncImage in SwiftUI

### Time Calculation Example
```swift
func calculateHours(from start: String, to end: String, deductLunch: Bool) -> Double {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    
    guard let startTime = formatter.date(from: start),
          let endTime = formatter.date(from: end) else {
        return 0
    }
    
    let difference = endTime.timeIntervalSince(startTime)
    var hours = difference / 3600
    
    if deductLunch {
        hours -= 0.5
    }
    
    return max(0, hours) // Ensure non-negative
}
```

### Offline Support Considerations
For a future enhancement, consider:
- Local caching with Core Data or Realm
- Queue uploads when offline
- Sync when connection restored
- Show offline indicator in UI

---

## Estimated Timeline

- **Phase 1**: 1-2 days
- **Phase 2**: 2-3 days
- **Phase 3**: 2-3 days
- **Phase 4**: 3-4 days
- **Phase 5**: 2-3 days
- **Phase 6**: 2-3 days
- **Phase 7**: 3-4 days
- **Phase 8**: 3-5 days

**Total**: Approximately 3-4 weeks for a single developer

---

## Resources & Documentation

### Firebase Documentation
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [Firebase Authentication](https://firebase.google.com/docs/auth/ios/start)
- [Cloud Firestore](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase Storage](https://firebase.google.com/docs/storage/ios/start)

### SwiftUI Resources
- [Apple SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [PHPickerViewController](https://developer.apple.com/documentation/photokit/phpickerviewcontroller)

### Useful Swift Packages
- Firebase iOS SDK
- Kingfisher (for image caching, optional)

---

## Next Steps

1. Set up Xcode project
2. Create Firebase project and download GoogleService-Info.plist
3. Install Firebase SDK via Swift Package Manager
4. Start with Phase 1 and work through sequentially
5. Test each phase before moving to the next

Good luck with your development! 🚀
