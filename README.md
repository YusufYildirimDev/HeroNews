# HeroNews

HeroNews is a native iOS application developed as a technical case study. It allows users to browse news headlines, view details, search specifically, and manage a local reading list with offline support.

## 🏗 Architecture & Design

The project strictly follows the **MVVM (Model-View-ViewModel)** architectural pattern to ensure separation of concerns, testability, and scalability.

### Core Layers
* **View (UI):** Built programmatically using `UIKit` and Auto Layout. No Storyboards were used to ensure cleaner git history and better conflict resolution.
* **ViewModel:** Handles business logic, state management, and transforms data for the View.
* **Model:** Decoupled Data Transfer Objects (DTOs) and Domain Models.
* **Networking:** A generic, protocol-oriented network layer using native `URLSession` and `async/await`.

### Key Design Decisions (Senior Perspective)
1.  **Concurrency:** * `ReadingListManager` is implemented as an **Actor** to guarantee thread safety when accessing `UserDefaults`.
    * [cite_start]`NewsListViewModel` uses `async let` to fetch headlines and the reading list in parallel, optimizing performance[cite: 45].
2.  **Offline Handling:** * A `NetworkMonitor` singleton observes connection changes. [cite_start]API requests are paused when offline and automatically resumed when the connection returns[cite: 35].
3.  **Performance:** * Images are cached using `NSCache` via a custom `ImageLoader` to minimize network usage.
    * `DateFormatter` instances are static to avoid expensive initialization costs during scrolling.
4.  [cite_start]**No 3rd Party Libraries:** * As requested[cite: 37], the app uses zero external dependencies.

## Features Checklist

- [x] [cite_start]**News List:** Displays headlines with title, image, author, and dynamic dates[cite: 12, 13].
- [x] [cite_start]**Detail Screen:** Scrollable content with a large image placement[cite: 14, 15].
- [x] [cite_start]**Auto Refresh:** Updates headlines every 60 seconds asynchronously without blocking the UI[cite: 16].
- [x] [cite_start]**Persistence:** Users can add/remove news to a local reading list that persists across app launches[cite: 18, 19].
- [x] [cite_start]**Smart UX:** - "New headlines added" toast message appears when background refresh finds new data[cite: 25].
    - [cite_start]Scroll position is preserved during refreshes[cite: 24].
- [x] [cite_start]**Search:** Real-time filtering of news headlines[cite: 23].
- [x] [cite_start]**Unit Tests:** ViewModel logic is covered with XCTest using Mock services[cite: 28].

## 🛠 Requirements

* iOS 15.0+
* Xcode 14.0+
* Swift 5.5+ (Async/Await)

##  Testing

The project includes a `HeroNewsTests` target.
* **Scope:** The tests cover the `NewsListViewModel`'s state transitions, data loading success/failure paths, and the toggling logic for the reading list.
* **Mocks:** Dependency Injection is used to mock the Network Service and Persistence Manager.
