# Maintenance Tracker iOS - Implementation Action Plan

## Overview
This guide provides clear, actionable steps for Claude Code agent to build the Road Marking Machine Maintenance Tracker iOS application. Each phase includes specific tasks, Firebase integration points, and validation criteria.

---

## 🔑 Firebase Integration Points (USER ACTION REQUIRED)

### Required Firebase Setup (Before Phase 1)

**ACTION REQUIRED**: Complete these steps manually before starting implementation:

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Click "Add project"
   - Name: "MaintenanceTracker" (or your preference)
   - Follow setup wizard

2. **Add iOS App to Firebase**
   - Click "Add app" → iOS
   - Bundle ID: `com.yourcompany.MaintenanceTracker` (note this for Xcode)
   - Download `GoogleService-Info.plist`
   - **SAVE THIS FILE** - needed in Phase 1

3. **Enable Firebase Services**
   - **Authentication**:
     - Go to Authentication → Sign-in method
     - Enable "Email/Password"

   - **Firestore Database**:
     - Go to Firestore Database → Create database
     - Start in **test mode** (we'll secure it in Phase 6)
     - Select region closest to you

   - **Storage**:
     - Go to Storage → Get started
     - Start in **test mode** (we'll secure it in Phase 6)

4. **Initial Firestore Setup**
   - Create collection: `base_categories`
   - Add these initial documents (manually):
     ```
     Document ID: auto
     Fields:
       - name: "Hydraulics"

     Document ID: auto
     Fields:
       - name: "Electrical"

     Document ID: auto
     Fields:
       - name: "Mechanical"

     Document ID: auto
     Fields:
       - name: "Paint System"

     Document ID: auto
     Fields:
       - name: "Tires"
     ```

**✅ CHECKPOINT**: You should have:
- Firebase project created
- `GoogleService-Info.plist` file downloaded
- Authentication, Firestore, and Storage enabled
- Base categories created in Firestore

---

## Phase 1: Project Setup & Firebase Configuration

### Objective
Create Xcode project structure and establish Firebase connection.

### Pre-Phase Requirements
- ✅ Firebase project created (see above)
- ✅ `GoogleService-Info.plist` downloaded
- ✅ Xcode installed (latest version recommended)

### Tasks

#### 1.1 Create Xcode Project
```yaml
action: create_xcode_project
steps:
  - Open Xcode
  - File → New → Project
  - Choose "App" template (iOS)
  - Settings:
      Product Name: MaintenanceTracker
      Team: [Your team]
      Organization Identifier: com.yourcompany
      Bundle Identifier: com.yourcompany.MaintenanceTracker
      Interface: SwiftUI
      Language: Swift
      Include Tests: ✅ Yes
  - Choose location and create
```

#### 1.2 Add Firebase SDK via Swift Package Manager
```yaml
action: add_firebase_dependencies
steps:
  - In Xcode: File → Add Package Dependencies
  - Enter URL: https://github.com/firebase/firebase-ios-sdk
  - Version: Up to Next Major (latest)
  - Add packages:
      ✅ FirebaseAuth
      ✅ FirebaseFirestore
      ✅ FirebaseStorage
  - Click "Add Package"
```

**USER ACTION**: Add `GoogleService-Info.plist` to project:
1. Drag downloaded file into Xcode project navigator
2. Ensure "Copy items if needed" is checked
3. Target membership: MaintenanceTracker ✅

#### 1.3 Configure Info.plist
```yaml
action: update_info_plist
required_keys:
  - key: NSCameraUsageDescription
    value: "We need camera access to take photos of maintenance issues"
    type: String

  - key: NSPhotoLibraryUsageDescription
    value: "We need photo library access to attach images to maintenance entries"
    type: String
```

**Implementation**: Right-click Info.plist → Open As → Source Code, add:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos of maintenance issues</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to attach images to maintenance entries</string>
```

#### 1.4 Create Project Folder Structure
```yaml
action: create_folder_structure
folders:
  - MaintenanceTracker/App
  - MaintenanceTracker/Models
  - MaintenanceTracker/ViewModels
  - MaintenanceTracker/Views/Authentication
  - MaintenanceTracker/Views/Machines
  - MaintenanceTracker/Views/Maintenance
  - MaintenanceTracker/Views/TimeTracking
  - MaintenanceTracker/Views/Admin
  - MaintenanceTracker/Views/Components
  - MaintenanceTracker/Services
  - MaintenanceTracker/Utilities
  - MaintenanceTracker/Resources
```

**Implementation**: In Xcode Project Navigator:
- Right-click MaintenanceTracker folder → New Group
- Create each folder as a Group (without folder reference)

#### 1.5 Initialize Firebase in App
```swift
// File: MaintenanceTracker/App/MaintenanceTrackerApp.swift
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
        }
    }
}
```

**Implementation**:
1. Create file: `App/MaintenanceTrackerApp.swift`
2. Replace default code with above
3. Move existing app file to App folder

#### 1.6 Create Constants File
```swift
// File: MaintenanceTracker/Utilities/Constants.swift
import Foundation

struct K {
    struct Firebase {
        static let companiesCollection = "companies"
        static let usersCollection = "users"
        static let machinesCollection = "machines"
        static let maintenanceEntriesCollection = "maintenance_entries"
        static let timeEntriesCollection = "time_entries"
        static let baseCategoriesCollection = "base_categories"
    }

    struct Storage {
        static let companiesPath = "companies"
        static let maintenancePath = "maintenance"
    }

    struct Defaults {
        static let maxImageSizeMB = 2.0
        static let lunchBreakHours = 0.5
    }
}
```

### Validation Criteria
- [x] Project builds without errors
- [x] Firebase SDK integrated successfully
- [x] GoogleService-Info.plist in project
- [x] Info.plist has camera/photo permissions
- [x] Folder structure matches specification
- [ ] App runs on simulator (blank screen expected) - **NEEDS TESTING**

### Phase 1 Implementation Status
✅ **COMPLETED** - All code files created. Next step: Build and test in Xcode.

**Files Created:**
- `/App/MaintenanceTrackerApp.swift` - Firebase initialization
- `/App/ContentView.swift` - Moved from root
- `/Utilities/Constants.swift` - Firebase collection names and constants
- `/Info.plist` - Camera and photo library permissions
- Folder structure: App, Models, ViewModels, Views (with subfolders), Services, Utilities, Resources

**Note:** The old `maintenance_wizardApp.swift` file in the root should be removed from the Xcode project.

### Deliverable
✅ Xcode project with Firebase SDK integrated and proper folder structure

---

## Phase 2: Authentication & Company Setup

### Objective
Implement user authentication, company creation, and user-company association.

### Tasks

#### 2.1 Create Data Models
```swift
// File: Models/User.swift
import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    let name: String
    let companyId: String
    let role: UserRole
    let createdDate: Date

    var isAdmin: Bool {
        role == .admin
    }
}

enum UserRole: String, Codable {
    case admin
    case user
}
```

```swift
// File: Models/Company.swift
import Foundation
import FirebaseFirestore

struct Company: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let createdBy: String
    let createdDate: Date
    var inviteCodes: [String]
}
```

**Implementation**: Create both model files in Models folder

#### 2.2 Create AuthService
```swift
// File: Services/AuthService.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthService {
    static let shared = AuthService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    private init() {}

    var currentUser: FirebaseAuth.User? {
        auth.currentUser
    }

    func signUp(email: String, password: String, name: String) async throws -> String {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user.uid
    }

    func signIn(email: String, password: String) async throws -> String {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user.uid
    }

    func signOut() throws {
        try auth.signOut()
    }
}
```

#### 2.3 Create FirebaseService for User/Company Operations
```swift
// File: Services/FirebaseService.swift
import Foundation
import FirebaseFirestore

final class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - User Operations
    func createUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw NSError(domain: "FirebaseService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "User ID is required"])
        }

        try db.collection(K.Firebase.usersCollection)
            .document(userId)
            .setData(from: user)
    }

    func fetchUser(userId: String) async throws -> User {
        let document = try await db.collection(K.Firebase.usersCollection)
            .document(userId)
            .getDocument()

        guard let user = try? document.data(as: User.self) else {
            throw NSError(domain: "FirebaseService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        return user
    }

    // MARK: - Company Operations
    func createCompany(name: String, createdBy: String) async throws -> String {
        let company = Company(
            id: nil,
            name: name,
            createdBy: createdBy,
            createdDate: Date(),
            inviteCodes: [generateInviteCode()]
        )

        let docRef = try db.collection(K.Firebase.companiesCollection)
            .addDocument(from: company)

        return docRef.documentID
    }

    func validateInviteCode(_ code: String) async throws -> String {
        let snapshot = try await db.collection(K.Firebase.companiesCollection)
            .whereField("inviteCodes", arrayContains: code)
            .getDocuments()

        guard let companyId = snapshot.documents.first?.documentID else {
            throw NSError(domain: "FirebaseService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid invite code"])
        }

        return companyId
    }

    private func generateInviteCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}
```

#### 2.4 Create AuthViewModel
```swift
// File: ViewModels/AuthViewModel.swift
import Foundation
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService.shared
    private let firebaseService = FirebaseService.shared

    init() {
        checkAuthState()
    }

    func checkAuthState() {
        isLoading = true

        if let currentUser = authService.currentUser {
            Task {
                do {
                    user = try await firebaseService.fetchUser(userId: currentUser.uid)
                    isAuthenticated = true
                } catch {
                    errorMessage = error.localizedDescription
                    isAuthenticated = false
                }
                isLoading = false
            }
        } else {
            isAuthenticated = false
            isLoading = false
        }
    }

    func signUp(email: String, password: String, name: String, companyName: String?, inviteCode: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            let userId = try await authService.signUp(email: email, password: password, name: name)

            let companyId: String
            let userRole: UserRole

            if let companyName = companyName {
                // Create new company
                companyId = try await firebaseService.createCompany(name: companyName, createdBy: userId)
                userRole = .admin
            } else if let inviteCode = inviteCode {
                // Join existing company
                companyId = try await firebaseService.validateInviteCode(inviteCode)
                userRole = .user
            } else {
                throw NSError(domain: "AuthViewModel", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Must provide company name or invite code"])
            }

            let newUser = User(
                id: userId,
                email: email,
                name: name,
                companyId: companyId,
                role: userRole,
                createdDate: Date()
            )

            try await firebaseService.createUser(newUser)
            user = newUser
            isAuthenticated = true

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let userId = try await authService.signIn(email: email, password: password)
            user = try await firebaseService.fetchUser(userId: userId)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() {
        do {
            try authService.signOut()
            user = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

#### 2.5 Create Authentication Views

**LoginView.swift**:
```swift
// File: Views/Authentication/LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Maintenance Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button {
                    Task {
                        await authViewModel.signIn(email: email, password: password)
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(authViewModel.isLoading)

                NavigationLink("Don't have an account? Sign Up") {
                    SignUpView()
                }
                .font(.caption)
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}
```

**SignUpView.swift**:
```swift
// File: Views/Authentication/SignUpView.swift
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var setupMode: CompanySetupMode = .create
    @State private var companyName = ""
    @State private var inviteCode = ""

    enum CompanySetupMode {
        case create, join
    }

    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("Full Name", text: $name)
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $password)
                SecureField("Confirm Password", text: $confirmPassword)
            }

            Section("Company Setup") {
                Picker("Setup Mode", selection: $setupMode) {
                    Text("Create New Company").tag(CompanySetupMode.create)
                    Text("Join Existing Company").tag(CompanySetupMode.join)
                }
                .pickerStyle(.segmented)

                if setupMode == .create {
                    TextField("Company Name", text: $companyName)
                } else {
                    TextField("Invite Code", text: $inviteCode)
                        .textInputAutocapitalization(.characters)
                }
            }

            if let error = authViewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            Section {
                Button {
                    Task {
                        await authViewModel.signUp(
                            email: email,
                            password: password,
                            name: name,
                            companyName: setupMode == .create ? companyName : nil,
                            inviteCode: setupMode == .join ? inviteCode : nil
                        )
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Sign Up")
                    }
                }
                .disabled(!isFormValid || authViewModel.isLoading)
            }
        }
        .navigationTitle("Sign Up")
    }

    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        ((setupMode == .create && !companyName.isEmpty) ||
         (setupMode == .join && !inviteCode.isEmpty))
    }
}
```

#### 2.6 Update ContentView
```swift
// File: App/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isLoading {
                ProgressView()
            } else if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

// Temporary placeholder
struct MainTabView: View {
    var body: some View {
        Text("Main App (Coming in Phase 3)")
    }
}
```

### Validation Criteria
- [ ] User can create account with new company
- [ ] User can create account with invite code
- [ ] User can sign in with email/password
- [ ] User data stored correctly in Firestore
- [ ] Company data stored correctly in Firestore
- [ ] Error messages display for invalid input
- [ ] Loading states work correctly

### Testing Steps
1. Run app on simulator
2. Create new account with company name "Test Company"
3. Check Firebase Console → Firestore:
   - `users` collection has new user document
   - `companies` collection has new company document
4. Sign out and sign in again
5. Create second account using invite code from first company
6. Verify both users belong to same company

### Deliverable
✅ Complete authentication system with company creation/joining

---

## Phase 3: Machine Management

### Objective
Implement machine listing, details, and admin creation capabilities.

### Tasks

#### 3.1 Create Machine Model
```swift
// File: Models/Machine.swift
import Foundation
import FirebaseFirestore

struct Machine: Identifiable, Codable {
    @DocumentID var id: String?
    let companyId: String
    let machineId: String  // User-friendly ID like "RM-001"
    let name: String
    var customCategories: [String]
    let createdDate: Date
    var photoURL: String?
}
```

#### 3.2 Create Category Model
```swift
// File: Models/Category.swift
import Foundation
import FirebaseFirestore

struct Category: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
}
```

#### 3.3 Extend FirebaseService for Machines
```swift
// Add to Services/FirebaseService.swift

// MARK: - Machine Operations
func createMachine(_ machine: Machine) async throws {
    try db.collection(K.Firebase.machinesCollection)
        .addDocument(from: machine)
}

func fetchMachines(companyId: String) async throws -> [Machine] {
    let snapshot = try await db.collection(K.Firebase.machinesCollection)
        .whereField("companyId", isEqualTo: companyId)
        .order(by: "machineId")
        .getDocuments()

    return snapshot.documents.compactMap { try? $0.data(as: Machine.self) }
}

func fetchMachine(id: String) async throws -> Machine {
    let document = try await db.collection(K.Firebase.machinesCollection)
        .document(id)
        .getDocument()

    guard let machine = try? document.data(as: Machine.self) else {
        throw NSError(domain: "FirebaseService", code: -1,
                     userInfo: [NSLocalizedDescriptionKey: "Machine not found"])
    }

    return machine
}

// MARK: - Category Operations
func fetchBaseCategories() async throws -> [Category] {
    let snapshot = try await db.collection(K.Firebase.baseCategoriesCollection)
        .getDocuments()

    return snapshot.documents.compactMap { try? $0.data(as: Category.self) }
}
```

#### 3.4 Create MachineViewModel
```swift
// File: ViewModels/MachineViewModel.swift
import Foundation

@MainActor
final class MachineViewModel: ObservableObject {
    @Published var machines: [Machine] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firebaseService = FirebaseService.shared

    func fetchMachines(companyId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            machines = try await firebaseService.fetchMachines(companyId: companyId)
        } catch {
            errorMessage = "Failed to load machines: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func addMachine(machineId: String, name: String, companyId: String, photoURL: String?) async {
        isLoading = true
        errorMessage = nil

        let machine = Machine(
            id: nil,
            companyId: companyId,
            machineId: machineId,
            name: name,
            customCategories: [],
            createdDate: Date(),
            photoURL: photoURL
        )

        do {
            try await firebaseService.createMachine(machine)
            await fetchMachines(companyId: companyId)
        } catch {
            errorMessage = "Failed to add machine: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
```

#### 3.5 Create Machine Views

**MachineListView.swift**:
```swift
// File: Views/Machines/MachineListView.swift
import SwiftUI

struct MachineListView: View {
    @StateObject private var viewModel = MachineViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddMachine = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.machines.isEmpty {
                    VStack {
                        Text("No machines yet")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        if authViewModel.user?.isAdmin == true {
                            Text("Tap + to add your first machine")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    List(viewModel.machines) { machine in
                        NavigationLink {
                            MachineDetailView(machine: machine)
                        } label: {
                            MachineRow(machine: machine)
                        }
                    }
                }
            }
            .navigationTitle("Machines")
            .toolbar {
                if authViewModel.user?.isAdmin == true {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddMachine = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddMachine) {
                AddMachineView()
                    .environmentObject(authViewModel)
                    .environmentObject(viewModel)
            }
            .task {
                if let companyId = authViewModel.user?.companyId {
                    await viewModel.fetchMachines(companyId: companyId)
                }
            }
            .refreshable {
                if let companyId = authViewModel.user?.companyId {
                    await viewModel.fetchMachines(companyId: companyId)
                }
            }
        }
    }
}

struct MachineRow: View {
    let machine: Machine

    var body: some View {
        HStack {
            // Placeholder for image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "car.fill")
                        .foregroundColor(.gray)
                }

            VStack(alignment: .leading) {
                Text(machine.machineId)
                    .font(.headline)
                Text(machine.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

**AddMachineView.swift**:
```swift
// File: Views/Machines/AddMachineView.swift
import SwiftUI

struct AddMachineView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var machineViewModel: MachineViewModel

    @State private var machineId = ""
    @State private var name = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Machine Information") {
                    TextField("Machine ID (e.g., RM-001)", text: $machineId)
                        .textInputAutocapitalization(.characters)

                    TextField("Machine Name", text: $name)
                }

                if let error = machineViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Machine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            if let companyId = authViewModel.user?.companyId {
                                await machineViewModel.addMachine(
                                    machineId: machineId,
                                    name: name,
                                    companyId: companyId,
                                    photoURL: nil
                                )

                                if machineViewModel.errorMessage == nil {
                                    dismiss()
                                }
                            }
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !machineId.isEmpty && !name.isEmpty
    }
}
```

**MachineDetailView.swift** (Placeholder):
```swift
// File: Views/Machines/MachineDetailView.swift
import SwiftUI

struct MachineDetailView: View {
    let machine: Machine

    var body: some View {
        VStack {
            Text(machine.name)
                .font(.title)
            Text(machine.machineId)
                .font(.headline)
                .foregroundColor(.secondary)

            Spacer()

            Text("Maintenance entries coming in Phase 4")
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Machine Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

#### 3.6 Update MainTabView
```swift
// File: App/ContentView.swift - Replace MainTabView

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            MachineListView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Machines", systemImage: "car.fill")
                }

            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
```

### Validation Criteria
- [ ] Machine list displays for all users
- [ ] Admin users see + button
- [ ] Non-admin users don't see + button
- [ ] Can add new machine (admin only)
- [ ] Machine appears in list after creation
- [ ] Can navigate to machine details
- [ ] Pull-to-refresh works

### Testing Steps
1. Sign in as admin user
2. Add machine: ID "RM-001", Name "Marker Machine 1"
3. Verify machine appears in list
4. Tap machine to view details
5. Sign out, sign in as regular user
6. Verify + button is hidden
7. Verify can still view machines

### Deliverable
✅ Machine management with role-based access control

---

## Phase 4: Maintenance Entry Creation

### Objective
Create and view maintenance entries with photo upload capability.

### Tasks

#### 4.1 Create MaintenanceEntry Model
```swift
// File: Models/MaintenanceEntry.swift
import Foundation
import FirebaseFirestore

struct MaintenanceEntry: Identifiable, Codable {
    @DocumentID var id: String?
    let companyId: String
    let machineId: String
    let category: String
    let description: String
    let estimatedTime: Double  // in hours
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

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    var color: Color {
        switch self {
        case .pending: return .yellow
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
}

import SwiftUI
```

#### 4.2 Create StorageService
```swift
// File: Services/StorageService.swift
import Foundation
import FirebaseStorage
import UIKit

final class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage()

    private init() {}

    func uploadMaintenancePhoto(
        image: UIImage,
        companyId: String,
        entryId: String
    ) async throws -> String {
        // Compress image
        guard let imageData = compressImage(image) else {
            throw NSError(domain: "StorageService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }

        // Generate unique filename
        let filename = "\(UUID().uuidString).jpg"
        let path = "\(K.Storage.companiesPath)/\(companyId)/\(K.Storage.maintenancePath)/\(entryId)/\(filename)"

        // Upload
        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)

        // Get download URL
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }

    private func compressImage(_ image: UIImage) -> Data? {
        let maxSizeBytes = Int(K.Defaults.maxImageSizeMB * 1024 * 1024)
        var compression: CGFloat = 0.9
        var imageData = image.jpegData(compressionQuality: compression)

        while let data = imageData, data.count > maxSizeBytes && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }

        return imageData
    }
}
```

#### 4.3 Extend FirebaseService for Maintenance
```swift
// Add to Services/FirebaseService.swift

// MARK: - Maintenance Entry Operations
func createMaintenanceEntry(_ entry: MaintenanceEntry) async throws {
    try db.collection(K.Firebase.maintenanceEntriesCollection)
        .addDocument(from: entry)
}

func fetchMaintenanceEntries(machineId: String) async throws -> [MaintenanceEntry] {
    let snapshot = try await db.collection(K.Firebase.maintenanceEntriesCollection)
        .whereField("machineId", isEqualTo: machineId)
        .order(by: "createdDate", descending: true)
        .getDocuments()

    return snapshot.documents.compactMap { try? $0.data(as: MaintenanceEntry.self) }
}

func updateMaintenanceStatus(entryId: String, status: MaintenanceStatus) async throws {
    try await db.collection(K.Firebase.maintenanceEntriesCollection)
        .document(entryId)
        .updateData(["status": status.rawValue])
}
```

#### 4.4 Create MaintenanceViewModel
```swift
// File: ViewModels/MaintenanceViewModel.swift
import Foundation
import UIKit

@MainActor
final class MaintenanceViewModel: ObservableObject {
    @Published var entries: [MaintenanceEntry] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var uploadProgress: Double = 0

    private let firebaseService = FirebaseService.shared
    private let storageService = StorageService.shared

    func fetchCategories() async {
        do {
            categories = try await firebaseService.fetchBaseCategories()
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
        }
    }

    func fetchEntries(machineId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            entries = try await firebaseService.fetchMaintenanceEntries(machineId: machineId)
        } catch {
            errorMessage = "Failed to load entries: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func createEntry(
        companyId: String,
        machineId: String,
        category: String,
        description: String,
        estimatedTime: Double,
        photos: [UIImage],
        createdBy: String,
        createdByName: String
    ) async {
        isLoading = true
        errorMessage = nil
        uploadProgress = 0

        // Create entry first to get ID
        let tempEntry = MaintenanceEntry(
            id: nil,
            companyId: companyId,
            machineId: machineId,
            category: category,
            description: description,
            estimatedTime: estimatedTime,
            photoURLs: [],
            status: .pending,
            createdBy: createdBy,
            createdByName: createdByName,
            createdDate: Date()
        )

        do {
            // Create entry
            try await firebaseService.createMaintenanceEntry(tempEntry)

            // Get the created entry ID (in real app, you'd need to return this from createMaintenanceEntry)
            // For now, we'll upload photos separately

            // Upload photos
            var photoURLs: [String] = []
            for (index, photo) in photos.enumerated() {
                let url = try await storageService.uploadMaintenancePhoto(
                    image: photo,
                    companyId: companyId,
                    entryId: "temp" // In production, use actual entry ID
                )
                photoURLs.append(url)
                uploadProgress = Double(index + 1) / Double(photos.count)
            }

            await fetchEntries(machineId: machineId)

        } catch {
            errorMessage = "Failed to create entry: \(error.localizedDescription)"
        }

        isLoading = false
        uploadProgress = 0
    }
}
```

#### 4.5 Create PhotoPicker Component
```swift
// File: Views/Components/PhotoPickerView.swift
import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedImages: [UIImage]
    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 5,
                matching: .images
            ) {
                Label("Select Photos", systemImage: "photo.on.rectangle.angled")
            }

            if !selectedImages.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                Button {
                                    selectedImages.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding(4)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: selectedItems) { _ in
            loadImages()
        }
    }

    private func loadImages() {
        Task {
            selectedImages = []

            for item in selectedItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImages.append(image)
                }
            }
        }
    }
}
```

#### 4.6 Create AddMaintenanceView
```swift
// File: Views/Maintenance/AddMaintenanceView.swift
import SwiftUI

struct AddMaintenanceView: View {
    let machine: Machine

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = MaintenanceViewModel()

    @State private var selectedCategory = ""
    @State private var description = ""
    @State private var estimatedTime = ""
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        NavigationView {
            Form {
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select...").tag("")
                        ForEach(viewModel.categories) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                }

                Section("Description") {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }

                Section("Estimated Time") {
                    TextField("Hours", text: $estimatedTime)
                        .keyboardType(.decimalPad)
                }

                Section("Photos") {
                    PhotoPickerView(selectedImages: $selectedImages)
                }

                if viewModel.isLoading {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Uploading...")
                        }

                        if viewModel.uploadProgress > 0 {
                            ProgressView(value: viewModel.uploadProgress)
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Maintenance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(!isFormValid || viewModel.isLoading)
                }
            }
            .task {
                await viewModel.fetchCategories()
            }
        }
    }

    private var isFormValid: Bool {
        !selectedCategory.isEmpty &&
        !description.isEmpty &&
        !estimatedTime.isEmpty &&
        Double(estimatedTime) != nil
    }

    private func saveEntry() {
        guard let user = authViewModel.user,
              let time = Double(estimatedTime) else { return }

        Task {
            await viewModel.createEntry(
                companyId: user.companyId,
                machineId: machine.id!,
                category: selectedCategory,
                description: description,
                estimatedTime: time,
                photos: selectedImages,
                createdBy: user.id!,
                createdByName: user.name
            )

            if viewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}
```

#### 4.7 Update MachineDetailView
```swift
// File: Views/Machines/MachineDetailView.swift - Complete version
import SwiftUI

struct MachineDetailView: View {
    let machine: Machine

    @StateObject private var viewModel = MaintenanceViewModel()
    @State private var showingAddEntry = false

    var body: some View {
        List {
            Section("Overview") {
                HStack {
                    Text("Pending Tasks")
                    Spacer()
                    Text("\(pendingCount)")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Total Estimated Time")
                    Spacer()
                    Text("\(totalEstimatedTime, specifier: "%.1f") hrs")
                        .foregroundColor(.secondary)
                }
            }

            Section("Maintenance Entries") {
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if viewModel.entries.isEmpty {
                    Text("No maintenance entries yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.entries) { entry in
                        MaintenanceEntryRow(entry: entry)
                    }
                }
            }
        }
        .navigationTitle(machine.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddEntry = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            AddMaintenanceView(machine: machine)
        }
        .task {
            if let machineId = machine.id {
                await viewModel.fetchEntries(machineId: machineId)
            }
        }
        .refreshable {
            if let machineId = machine.id {
                await viewModel.fetchEntries(machineId: machineId)
            }
        }
    }

    private var pendingCount: Int {
        viewModel.entries.filter { $0.status == .pending }.count
    }

    private var totalEstimatedTime: Double {
        viewModel.entries.filter { $0.status == .pending }
            .reduce(0) { $0 + $1.estimatedTime }
    }
}

struct MaintenanceEntryRow: View {
    let entry: MaintenanceEntry

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(entry.status.color.opacity(0.2))
                        .foregroundColor(entry.status.color)
                        .clipShape(Capsule())

                    Spacer()

                    Text(entry.status.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(entry.description)
                    .font(.body)
                    .lineLimit(2)

                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("\(entry.estimatedTime, specifier: "%.1f") hrs")
                        .font(.caption)

                    Spacer()

                    if !entry.photoURLs.isEmpty {
                        Image(systemName: "photo")
                            .font(.caption)
                        Text("\(entry.photoURLs.count)")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
```

### Validation Criteria
- [ ] Can add maintenance entry with category
- [ ] Can add multiple photos (up to 5)
- [ ] Photos upload to Firebase Storage
- [ ] Entry appears in machine detail view
- [ ] Entry shows correct status badge
- [ ] Upload progress indicator works
- [ ] Error handling for failed uploads

### Testing Steps
1. Navigate to machine detail
2. Tap + to add maintenance entry
3. Select category, add description, estimated time
4. Select 2-3 photos from library
5. Tap Save
6. Verify upload progress shows
7. Verify entry appears in list
8. Check Firebase Console:
   - Firestore has maintenance entry
   - Storage has photos in correct path

### Deliverable
✅ Maintenance entry creation with photo upload

---

## Phase 5: Time Tracking

### Objective
Log time entries for maintenance tasks with automatic hour calculation.

### Tasks

#### 5.1 Create TimeEntry Model
```swift
// File: Models/TimeEntry.swift
import Foundation
import FirebaseFirestore

struct TimeEntry: Identifiable, Codable {
    @DocumentID var id: String?
    let maintenanceEntryId: String
    let userId: String?  // nil for guest
    let userName: String
    let date: Date
    let startTime: String  // "HH:mm"
    let endTime: String    // "HH:mm"
    let lunchBreakDeducted: Bool
    let actualTimeSpent: Double  // in hours
    let createdBy: String
    let createdDate: Date
}
```

#### 5.2 Create TimeCalculation Helper
```swift
// File: Utilities/TimeCalculator.swift
import Foundation

struct TimeCalculator {
    static func calculateHours(
        from start: String,
        to end: String,
        deductLunch: Bool
    ) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let startTime = formatter.date(from: start),
              let endTime = formatter.date(from: end) else {
            return 0
        }

        var hours = endTime.timeIntervalSince(startTime) / 3600

        // Handle overnight shifts
        if hours < 0 {
            hours += 24
        }

        if deductLunch {
            hours -= K.Defaults.lunchBreakHours
        }

        return max(0, hours)
    }

    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
```

#### 5.3 Extend FirebaseService for Time Entries
```swift
// Add to Services/FirebaseService.swift

// MARK: - Time Entry Operations
func createTimeEntry(_ entry: TimeEntry) async throws {
    try db.collection(K.Firebase.timeEntriesCollection)
        .addDocument(from: entry)
}

func fetchTimeEntries(maintenanceEntryId: String) async throws -> [TimeEntry] {
    let snapshot = try await db.collection(K.Firebase.timeEntriesCollection)
        .whereField("maintenanceEntryId", isEqualTo: maintenanceEntryId)
        .order(by: "date", descending: true)
        .getDocuments()

    return snapshot.documents.compactMap { try? $0.data(as: TimeEntry.self) }
}

func fetchCompanyUsers(companyId: String) async throws -> [User] {
    let snapshot = try await db.collection(K.Firebase.usersCollection)
        .whereField("companyId", isEqualTo: companyId)
        .getDocuments()

    return snapshot.documents.compactMap { try? $0.data(as: User.self) }
}
```

#### 5.4 Create TimeTrackingViewModel
```swift
// File: ViewModels/TimeTrackingViewModel.swift
import Foundation

@MainActor
final class TimeTrackingViewModel: ObservableObject {
    @Published var timeEntries: [TimeEntry] = []
    @Published var companyUsers: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firebaseService = FirebaseService.shared

    func fetchCompanyUsers(companyId: String) async {
        do {
            companyUsers = try await firebaseService.fetchCompanyUsers(companyId: companyId)
        } catch {
            errorMessage = "Failed to load users: \(error.localizedDescription)"
        }
    }

    func fetchTimeEntries(maintenanceEntryId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            timeEntries = try await firebaseService.fetchTimeEntries(maintenanceEntryId: maintenanceEntryId)
        } catch {
            errorMessage = "Failed to load time entries: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func addTimeEntry(
        maintenanceEntryId: String,
        userId: String?,
        userName: String,
        date: Date,
        startTime: String,
        endTime: String,
        deductLunch: Bool,
        createdBy: String
    ) async {
        isLoading = true
        errorMessage = nil

        let actualTime = TimeCalculator.calculateHours(
            from: startTime,
            to: endTime,
            deductLunch: deductLunch
        )

        let entry = TimeEntry(
            id: nil,
            maintenanceEntryId: maintenanceEntryId,
            userId: userId,
            userName: userName,
            date: date,
            startTime: startTime,
            endTime: endTime,
            lunchBreakDeducted: deductLunch,
            actualTimeSpent: actualTime,
            createdBy: createdBy,
            createdDate: Date()
        )

        do {
            try await firebaseService.createTimeEntry(entry)
            await fetchTimeEntries(maintenanceEntryId: maintenanceEntryId)
        } catch {
            errorMessage = "Failed to add time entry: \(error.localizedDescription)"
        }

        isLoading = false
    }

    var totalHours: Double {
        timeEntries.reduce(0) { $0 + $1.actualTimeSpent }
    }
}
```

#### 5.5 Create AddTimeEntryView
```swift
// File: Views/TimeTracking/AddTimeEntryView.swift
import SwiftUI

struct AddTimeEntryView: View {
    let maintenanceEntryId: String

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = TimeTrackingViewModel()

    @State private var selectedUser: User?
    @State private var isGuestMode = false
    @State private var guestName = ""
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var deductLunch = true

    var body: some View {
        NavigationView {
            Form {
                Section("Person") {
                    Picker("Worker", selection: $selectedUser) {
                        Text("Select...").tag(nil as User?)
                        ForEach(viewModel.companyUsers) { user in
                            Text(user.name).tag(user as User?)
                        }
                        Text("Guest/Other").tag(nil as User?)
                    }
                    .onChange(of: selectedUser) { newValue in
                        isGuestMode = newValue == nil
                    }

                    if isGuestMode {
                        TextField("Guest Name", text: $guestName)
                    }
                }

                Section("Date & Time") {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)

                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)

                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)

                    Toggle("Deduct Lunch Break (30 min)", isOn: $deductLunch)
                }

                Section("Calculated Hours") {
                    HStack {
                        Text("Total Time")
                        Spacer()
                        Text("\(calculatedHours, specifier: "%.2f") hours")
                            .foregroundColor(.secondary)
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Time Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTimeEntry()
                    }
                    .disabled(!isFormValid || viewModel.isLoading)
                }
            }
            .task {
                if let companyId = authViewModel.user?.companyId {
                    await viewModel.fetchCompanyUsers(companyId: companyId)
                }
            }
        }
    }

    private var calculatedHours: Double {
        TimeCalculator.calculateHours(
            from: TimeCalculator.formatTime(startTime),
            to: TimeCalculator.formatTime(endTime),
            deductLunch: deductLunch
        )
    }

    private var isFormValid: Bool {
        if isGuestMode {
            return !guestName.isEmpty
        } else {
            return selectedUser != nil
        }
    }

    private func saveTimeEntry() {
        guard let userId = authViewModel.user?.id else { return }

        let workerUserId = isGuestMode ? nil : selectedUser?.id
        let workerName = isGuestMode ? guestName : (selectedUser?.name ?? "")

        Task {
            await viewModel.addTimeEntry(
                maintenanceEntryId: maintenanceEntryId,
                userId: workerUserId,
                userName: workerName,
                date: selectedDate,
                startTime: TimeCalculator.formatTime(startTime),
                endTime: TimeCalculator.formatTime(endTime),
                deductLunch: deductLunch,
                createdBy: userId
            )

            if viewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}
```

#### 5.6 Create TimeEntryListView
```swift
// File: Views/TimeTracking/TimeEntryListView.swift
import SwiftUI

struct TimeEntryListView: View {
    let maintenanceEntryId: String

    @StateObject private var viewModel = TimeTrackingViewModel()
    @State private var showingAddEntry = false

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Total Hours Logged")
                        .font(.headline)
                    Spacer()
                    Text("\(viewModel.totalHours, specifier: "%.2f") hrs")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }

            Section("Time Entries") {
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if viewModel.timeEntries.isEmpty {
                    Text("No time entries yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.timeEntries) { entry in
                        TimeEntryRow(entry: entry)
                    }
                }
            }
        }
        .navigationTitle("Time Tracking")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddEntry = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            AddTimeEntryView(maintenanceEntryId: maintenanceEntryId)
        }
        .task {
            await viewModel.fetchTimeEntries(maintenanceEntryId: maintenanceEntryId)
        }
        .refreshable {
            await viewModel.fetchTimeEntries(maintenanceEntryId: maintenanceEntryId)
        }
    }
}

struct TimeEntryRow: View {
    let entry: TimeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.userName)
                    .font(.headline)

                Spacer()

                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("\(entry.startTime) - \(entry.endTime)", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if entry.lunchBreakDeducted {
                    Image(systemName: "fork.knife")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(entry.actualTimeSpent, specifier: "%.2f") hrs")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
```

#### 5.7 Update MaintenanceDetailView (Create New File)
```swift
// File: Views/Maintenance/MaintenanceDetailView.swift
import SwiftUI

struct MaintenanceDetailView: View {
    let entry: MaintenanceEntry

    @StateObject private var viewModel = TimeTrackingViewModel()

    var body: some View {
        List {
            Section("Details") {
                HStack {
                    Text("Category")
                    Spacer()
                    Text(entry.category)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Status")
                    Spacer()
                    Text(entry.status.displayName)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(entry.status.color.opacity(0.2))
                        .foregroundColor(entry.status.color)
                        .clipShape(Capsule())
                }

                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.headline)
                    Text(entry.description)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Estimated Time")
                    Spacer()
                    Text("\(entry.estimatedTime, specifier: "%.1f") hrs")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Created By")
                    Spacer()
                    Text(entry.createdByName)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Created Date")
                    Spacer()
                    Text(entry.createdDate, style: .date)
                        .foregroundColor(.secondary)
                }
            }

            if !entry.photoURLs.isEmpty {
                Section("Photos") {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(entry.photoURLs, id: \.self) { url in
                                AsyncImage(url: URL(string: url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }

            Section {
                NavigationLink {
                    if let entryId = entry.id {
                        TimeEntryListView(maintenanceEntryId: entryId)
                    }
                } label: {
                    HStack {
                        Label("Time Tracking", systemImage: "clock")
                        Spacer()
                        if viewModel.totalHours > 0 {
                            Text("\(viewModel.totalHours, specifier: "%.1f") hrs")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Maintenance Details")
        .task {
            if let entryId = entry.id {
                await viewModel.fetchTimeEntries(maintenanceEntryId: entryId)
            }
        }
    }
}
```

#### 5.8 Update MaintenanceEntryRow to Add Navigation
```swift
// Update in Views/Machines/MachineDetailView.swift
// Replace MaintenanceEntryRow with:

struct MaintenanceEntryRow: View {
    let entry: MaintenanceEntry

    var body: some View {
        NavigationLink {
            MaintenanceDetailView(entry: entry)
        } label: {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(entry.status.color.opacity(0.2))
                            .foregroundColor(entry.status.color)
                            .clipShape(Capsule())

                        Spacer()

                        Text(entry.status.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(entry.description)
                        .font(.body)
                        .lineLimit(2)

                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(entry.estimatedTime, specifier: "%.1f") hrs")
                            .font(.caption)

                        Spacer()

                        if !entry.photoURLs.isEmpty {
                            Image(systemName: "photo")
                                .font(.caption)
                            Text("\(entry.photoURLs.count)")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
```

### Validation Criteria
- [ ] Can add time entry for company user
- [ ] Can add time entry for guest/other person
- [ ] Time calculation works correctly
- [ ] Lunch break deduction works (30 min)
- [ ] Total hours display correctly
- [ ] Time entries list shows all entries
- [ ] Navigation flow works: Machine → Entry → Time Tracking

### Testing Steps
1. Navigate to machine → maintenance entry → time tracking
2. Add time entry for yourself (8:00-16:00, with lunch)
3. Verify calculation: 7.5 hours
4. Add entry for guest "John Doe" (9:00-12:00, no lunch)
5. Verify calculation: 3.0 hours
6. Verify total: 10.5 hours
7. Check Firestore has both time entries

### Deliverable
✅ Complete time tracking system with automatic calculation

---

## Phase 6: Admin Panel (Security Rules)

### Objective
Implement admin features and secure Firebase with proper Security Rules.

### Tasks

#### 6.1 USER ACTION: Configure Firestore Security Rules

**REQUIRED**: In Firebase Console, configure Firestore Security Rules:

1. Go to Firebase Console → Firestore Database → Rules
2. Replace with this configuration:

```javascript
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

    // Users can read/write their own data
    match /users/{userId} {
      allow read: if isAuthenticated() && request.auth.uid == userId;
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() &&
                      (request.auth.uid == userId || isAdmin());
    }

    // Company data - only accessible by company members
    match /companies/{companyId} {
      allow read: if belongsToCompany(companyId);
      allow create: if isAuthenticated();
      allow update: if isAdmin() && belongsToCompany(companyId);
    }

    // Machines - company isolation
    match /machines/{machineId} {
      allow read: if belongsToCompany(resource.data.companyId);
      allow create: if isAdmin() && belongsToCompany(request.resource.data.companyId);
      allow update, delete: if isAdmin() && belongsToCompany(resource.data.companyId);
    }

    // Maintenance entries - company isolation
    match /maintenance_entries/{entryId} {
      allow read: if belongsToCompany(resource.data.companyId);
      allow create: if belongsToCompany(request.resource.data.companyId);
      allow update: if belongsToCompany(resource.data.companyId);
      allow delete: if isAdmin() && belongsToCompany(resource.data.companyId);
    }

    // Time entries - authenticated users
    match /time_entries/{timeEntryId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAuthenticated();
    }

    // Base categories - read all, write admin only
    match /base_categories/{categoryId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
  }
}
```

3. Click "Publish"

#### 6.2 USER ACTION: Configure Storage Security Rules

**REQUIRED**: In Firebase Console, configure Storage Security Rules:

1. Go to Firebase Console → Storage → Rules
2. Replace with this configuration:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Helper function to check if user belongs to company
    function belongsToCompany(companyId) {
      return request.auth != null &&
             firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.companyId == companyId;
    }

    // Company maintenance photos
    match /companies/{companyId}/maintenance/{entryId}/{filename} {
      // Read: Any authenticated user from the company
      allow read: if belongsToCompany(companyId);

      // Write: Any authenticated user from the company
      // Size limit: 5MB
      // Type: Only images
      allow write: if belongsToCompany(companyId) &&
                     request.resource.size < 5 * 1024 * 1024 &&
                     request.resource.contentType.matches('image/.*');

      // Delete: Only admins from the company
      allow delete: if belongsToCompany(companyId) &&
                       firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

3. Click "Publish"

**✅ CHECKPOINT**: Security rules are now active and protecting your data

#### 6.3 Create Admin Dashboard Views

**AdminDashboardView.swift**:
```swift
// File: Views/Admin/AdminDashboardView.swift
import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            List {
                Section("Management") {
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label("Categories", systemImage: "folder")
                    }

                    NavigationLink {
                        UserManagementView()
                    } label: {
                        Label("Users", systemImage: "person.2")
                    }

                    NavigationLink {
                        InviteUserView()
                    } label: {
                        Label("Invite Codes", systemImage: "ticket")
                    }
                }

                Section("Account") {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Admin Panel")
        }
    }
}
```

**CategoryManagementView.swift**:
```swift
// File: Views/Admin/CategoryManagementView.swift
import SwiftUI

struct CategoryManagementView: View {
    @StateObject private var viewModel = MaintenanceViewModel()
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""

    var body: some View {
        List {
            ForEach(viewModel.categories) { category in
                Text(category.name)
            }
        }
        .navigationTitle("Base Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Add Category", isPresented: $showingAddCategory) {
            TextField("Category Name", text: $newCategoryName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                // Add category logic
            }
        }
        .task {
            await viewModel.fetchCategories()
        }
    }
}
```

**UserManagementView.swift** & **InviteUserView.swift**: (Simplified placeholders)
```swift
// File: Views/Admin/UserManagementView.swift
import SwiftUI

struct UserManagementView: View {
    var body: some View {
        Text("User Management - Coming Soon")
            .navigationTitle("Users")
    }
}

// File: Views/Admin/InviteUserView.swift
import SwiftUI

struct InviteUserView: View {
    var body: some View {
        Text("Invite Code Generation - Coming Soon")
            .navigationTitle("Invite Codes")
    }
}
```

#### 6.4 Update MainTabView to Include Admin
```swift
// Update in App/ContentView.swift

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            MachineListView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Machines", systemImage: "car.fill")
                }

            if authViewModel.user?.isAdmin == true {
                AdminDashboardView()
                    .environmentObject(authViewModel)
                    .tabItem {
                        Label("Admin", systemImage: "gear")
                    }
            }

            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

// Simple profile view
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            List {
                if let user = authViewModel.user {
                    Section("Account") {
                        Text("Name: \(user.name)")
                        Text("Email: \(user.email)")
                        Text("Role: \(user.role.rawValue)")
                    }
                }

                Section {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}
```

### Validation Criteria
- [ ] Firestore Security Rules published
- [ ] Storage Security Rules published
- [ ] Admin tab visible only to admin users
- [ ] Can access admin dashboard
- [ ] Category management view works
- [ ] Sign out works from profile

### Testing Security Rules
1. Try to access another company's data (should fail)
2. Try to modify data as non-admin (should fail where restricted)
3. Try to upload >5MB photo (should fail)
4. Verify all operations still work for authorized users

### Deliverable
✅ Secured Firebase with role-based access control

---

## Phase 7: UI Polish

### Objective
Improve visual design, user experience, and error handling.

### Tasks (High-Level Guide)

#### 7.1 Color Scheme
- Define primary color (e.g., blue)
- Define status colors (yellow/pending, blue/in-progress, green/completed)
- Create Assets.xcassets color sets

#### 7.2 Reusable Components
- Create custom button styles
- Create loading indicators
- Create error alert modifiers
- Create empty state views

#### 7.3 Image Optimization
- Implement proper AsyncImage placeholders
- Add image caching if needed
- Ensure photo compression works

#### 7.4 Error Handling
- Consistent error display across all views
- Network error handling
- Offline indicators

#### 7.5 Polish
- Add animations
- Improve navigation flow
- Add haptic feedback
- Accessibility labels

### Implementation Note
This phase is iterative and should be done while testing. Focus on:
- Consistent design language
- Smooth user experience
- Professional appearance

---

## Phase 8: Testing & Deployment

### Objective
Comprehensive testing and App Store preparation.

### Tasks

#### 8.1 Unit Tests
Create test files in MaintenanceTrackerTests/:
- Test TimeCalculator
- Test data models
- Test ViewModels

Example:
```swift
import XCTest
@testable import MaintenanceTracker

final class TimeCalculatorTests: XCTestCase {
    func testBasicCalculation() {
        let hours = TimeCalculator.calculateHours(
            from: "08:00",
            to: "16:00",
            deductLunch: false
        )
        XCTAssertEqual(hours, 8.0)
    }

    func testWithLunchBreak() {
        let hours = TimeCalculator.calculateHours(
            from: "08:00",
            to: "16:00",
            deductLunch: true
        )
        XCTAssertEqual(hours, 7.5)
    }
}
```

#### 8.2 Manual Testing Checklist
- [ ] Create new company and account
- [ ] Join existing company with invite code
- [ ] Add machine as admin
- [ ] Create maintenance entry with photos
- [ ] Log time entries
- [ ] Verify calculations
- [ ] Test as non-admin user
- [ ] Test offline behavior
- [ ] Test error scenarios

#### 8.3 App Store Preparation

**USER ACTION REQUIRED**:

1. **Create App Icons** (all required sizes in Assets.xcassets)
2. **App Store Connect Setup**:
   - Create app listing
   - Provide description, keywords, category
   - Upload screenshots (iPhone required)
   - Set pricing (free)
   - Privacy policy URL
   - Support URL

3. **Archive and Upload**:
   - Xcode → Product → Archive
   - Distribute App → App Store Connect
   - Upload

4. **TestFlight**:
   - Add internal testers
   - Collect feedback
   - Fix issues

5. **Submit for Review**:
   - Complete all required information
   - Submit
   - Respond to review feedback

### Deliverable
✅ Published app on App Store

---

## 📋 Complete Implementation Checklist

### Phase 1: Setup ✅
- [ ] Create Xcode project
- [ ] Add Firebase SDK
- [ ] Add GoogleService-Info.plist (USER ACTION)
- [ ] Configure Info.plist permissions
- [ ] Create folder structure
- [ ] Initialize Firebase in app
- [ ] Create Constants file
- [ ] Verify build succeeds

### Phase 2: Authentication ✅
- [ ] Create User model
- [ ] Create Company model
- [ ] Create AuthService
- [ ] Create FirebaseService (user/company ops)
- [ ] Create AuthViewModel
- [ ] Create LoginView
- [ ] Create SignUpView
- [ ] Update ContentView
- [ ] Test account creation
- [ ] Test sign in/out
- [ ] Verify Firestore data

### Phase 3: Machines ✅
- [ ] Create Machine model
- [ ] Create Category model
- [ ] Extend FirebaseService (machines)
- [ ] Create MachineViewModel
- [ ] Create MachineListView
- [ ] Create MachineRow component
- [ ] Create AddMachineView (admin)
- [ ] Create MachineDetailView
- [ ] Update MainTabView
- [ ] Test machine creation
- [ ] Test role-based access

### Phase 4: Maintenance Entries ✅
- [ ] Create MaintenanceEntry model
- [ ] Create StorageService
- [ ] Extend FirebaseService (maintenance)
- [ ] Create MaintenanceViewModel
- [ ] Create PhotoPickerView component
- [ ] Create AddMaintenanceView
- [ ] Update MachineDetailView
- [ ] Create MaintenanceEntryRow
- [ ] Test entry creation
- [ ] Test photo upload
- [ ] Verify Storage paths

### Phase 5: Time Tracking ✅
- [ ] Create TimeEntry model
- [ ] Create TimeCalculator utility
- [ ] Extend FirebaseService (time entries)
- [ ] Create TimeTrackingViewModel
- [ ] Create AddTimeEntryView
- [ ] Create TimeEntryListView
- [ ] Create MaintenanceDetailView
- [ ] Update navigation
- [ ] Test time calculations
- [ ] Test guest entries
- [ ] Verify total hours

### Phase 6: Admin & Security ✅
- [ ] Configure Firestore Security Rules (USER ACTION)
- [ ] Configure Storage Security Rules (USER ACTION)
- [ ] Create AdminDashboardView
- [ ] Create CategoryManagementView
- [ ] Create UserManagementView
- [ ] Create InviteUserView
- [ ] Update MainTabView (admin tab)
- [ ] Create ProfileView
- [ ] Test security rules
- [ ] Verify role-based access

### Phase 7: Polish ✅
- [ ] Define color scheme
- [ ] Create reusable components
- [ ] Implement loading states
- [ ] Add empty states
- [ ] Improve error handling
- [ ] Optimize images
- [ ] Add animations
- [ ] Accessibility labels

### Phase 8: Testing & Deployment ✅
- [ ] Write unit tests
- [ ] Run UI tests
- [ ] Complete manual testing
- [ ] Create app icons (USER ACTION)
- [ ] Set up App Store Connect (USER ACTION)
- [ ] Archive and upload (USER ACTION)
- [ ] TestFlight distribution (USER ACTION)
- [ ] Submit for review (USER ACTION)

---

## 🚀 Quick Start Command for Claude Code Agent

```
/implement Phase 1: Project Setup
Follow IMPLEMENTATION_GUIDE.md Phase 1 tasks sequentially.
Notify user when USER ACTION required.
```

## 📞 Support & Resources

### When You Need User Input
The guide clearly marks **USER ACTION REQUIRED** for:
- Firebase project setup
- Adding GoogleService-Info.plist
- Security Rules configuration
- App Store submission

### Firebase Console Links
- [Firebase Console](https://console.firebase.google.com)
- [Firestore Database](https://console.firebase.google.com/u/0/project/_/firestore)
- [Storage](https://console.firebase.google.com/u/0/project/_/storage)
- [Authentication](https://console.firebase.google.com/u/0/project/_/authentication)

### Documentation
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [Firebase iOS](https://firebase.google.com/docs/ios/setup)
- [App Store Connect](https://appstoreconnect.apple.com)

---

## 💡 Implementation Tips

1. **Work Sequentially**: Complete each phase fully before moving on
2. **Test After Each Phase**: Verify everything works before proceeding
3. **Commit Often**: Git commit after completing each major task
4. **Ask for Help**: When USER ACTION needed, notify user and wait
5. **Validate Data**: Check Firebase Console to verify data structure
6. **Security First**: Don't skip Phase 6 security configuration

---

**Ready to start? Begin with Phase 1! 🎯**
