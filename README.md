# MaxNotes

MaxNotes is a SwiftUI iOS app for creating, editing, and geotagging notes with optional images, synced via Firebase.

## Features Summary
- Email/password authentication with Firebase Auth.
- Create, edit, and delete text notes.
- Per-note creation date and updated timestamp.
- Optional image attachment from the device photo gallery.
- Geolocation per note and a map view showing notes as pins.
- Real-time notes syncing via Firestore streams.

## Tech Stack
- `SwiftUI` + `Observation` for UI and state.
- `Firebase Auth` and `Cloud Firestore` for authentication and note persistence.
- `MapKit` and `CoreLocation` for showing notes on a map and attaching locations.
- `PhotosUI` and a small `ImageProcessing` abstraction for picking and compressing images.
- `os.Logger`-based logging for Firestore and general errors.

## Architecture & Practices
- **Layered structure**
- `Domain`: models (`Note`, `NoteLocation`, `AppUser`) and protocols (`NoteRepositoryProtocol`, `AuthServiceProtocol`, `ImageStorageProtocol`).
- `Data`: concrete implementations (`FirestoreNoteRepository`, `FirebaseAuthService`, `LocalImageStorage`) and `Mock*` types for previews/tests.
- `Features`: screen-specific view models and views (Auth, List, Map, Editor, shared components).
- `Core`: cross-cutting utilities (DI container, logging, location service, string helpers, image processing).
- **Async/await and streams**
- Notes are observed via `AsyncThrowingStream<[Note]>` from Firestore and fed into `ListViewModel` and `MapViewModel`.
- Auth state is exposed as an `AsyncStream<AppUser?>` in `FirebaseAuthService`, which `RootView` listens to in a `.task` to drive the root navigation (loading / login / main).
- **State management**
- View models are `@Observable` classes, and views bind them via `@Bindable` or `@State` when stored locally.
- Screens keep their own view models alive (`MainView` owns `ListViewModel`, `MapViewModel`, and `NoteEditorViewModel`) so navigation and modals share state consistently.

## Dependency Injection
- **Current approach**
- A single `DependencyContainer` (`Core/DI/DependencyContainer.swift`) wires up the app-wide dependencies: `AuthServiceProtocol`, `LocationServiceProtocol`, `ImageStorageProtocol`, and `ImageProcessing`.
- `RootView` receives the container from `MaxNotesApp` and uses it to construct feature-specific view models (`LoginViewModel`, `ListViewModel`, `MapViewModel`, `NoteEditorViewModel`) and user-scoped `NoteRepositoryProtocol` instances.
- This keeps the dependency graph explicit and centralized, and it also makes previews easier by allowing the container to be configured with mock services.

- **Tradeoffs and alternatives**
- **Manual DI:** Chosen for this project to ensure **compile-time safety** and explicit dependency graphs without external libraries.
- **Environment:** In a deeper view hierarchy, injecting services via SwiftUI's `@Environment` would reduce the need to pass dependencies through intermediate views.
- **Scalability:** For larger modularized applications, I would consider:
- `Swinject` (for container-based resolution and reducing boilerplate).
- `swift-dependencies` (Point-Free) for rigorous test control and ergonomic SwiftUI integration.

## Notes
- **Gallery image attachment** is implemented using `PhotosUI` and an `ImageProcessing` abstraction; users can attach and preview a photo per note.
- **Firebase Storage** integration was attempted for remote image uploads with Firebase Storage, but it was blocked by region restrictions in the current environment.
- **Local file-based storage** is used instead via `LocalImageStorage`, which writes compressed JPEGs under the app’s `Application Support/NoteImages` directory and cleans them up when notes are deleted.

## Known Bugs & Limitations

- **Location permissions UX**  
`LocationService` requests `whenInUse` authorization and then waits for a valid location fix.  
If location is slow or never resolves (permissions denied, restricted, or unreliable GPS), the user eventually
sees only a generic “Location request timed out” badge.  
There is no explicit retry button or guided permissions UI.

- **Map centering behavior**  
The map auto-centers on the user's location only once (`hasCenteredOnUser`).  
If the user moves significantly or toggles permissions during runtime, the map does not automatically re-center.

- **Image storage edge cases**  
Images are stored locally under `Application Support/NoteImages`.  
If the directory becomes unavailable (sandbox issues, disk pressure), saving/deleting images may fail (logged internally), and the UI shows only a generic error.

- **Authentication flows**  
The app supports Firebase email/password only.  
Password reset, email verification, and OAuth providers are not implemented, and Firebase error messages are shown directly to the user, which may not always be ideal UX.

## Running the App
- Open `MaxNotes.xcodeproj` in Xcode (iOS 17+ target recommended).
- The project expects a valid `GoogleService-Info.plist` at `MaxNotes/GoogleService-Info.plist`. This repo currently commits a development configuration;
- Run on a simulator or device with location services and Photos access enabled for the best experience.

## Use of AI Tools
I used AI tools (ChatGPT and Gemini) as a supportive assistant for planning and code reviews. The core architecture, data flow, and business logic were designed and implemented by me; AI was used mainly for review, refinement, and boilerplate reduction.

- **Planning & architecture** – I drafted the layered architecture (DI container, view models, Firestore streams) myself, then used AI to review the structure, challenge assumptions, and surface potential edge cases.
- **UI/UX review** – I requested feedback on layout ergonomics and platform-consistent patterns to keep the app feeling native to iOS.
- **Code review & quality checks** – I used AI for code reviews to find edge cases and potential issues I missed.
- **Utility functions** – I used AI for small helper snippets (e.g. image compression helpers, file manager utilities) to reduce boilerplate.
- **Documentation** – AI assisted in refining the structure and clarity of this README; the underlying content, architecture, and implementation decisions remain my own.

## Future Improvements
- Replace the manual `DependencyContainer` with Swinject or Point-Free’s `swift-dependencies` for more composable, testable feature modules.
- Improve location/map UX (onboarding for permissions, explicit "center on me" button, clearer error states).
- Extend authentication with password reset and email verification flows.
