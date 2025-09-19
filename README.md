# DrivingLogger 🚗💨

**The smartest way to automatically track and manage your drives.**

DrivingLogger is an iOS app designed for Uber, Lyft drivers, and other professional drivers. It automatically tracks your driving routes, distance, and duration, storing the data securely on your device to help with expense reporting and driving pattern analysis.

## ✨ Key Features

- **GPS-Based Trip Tracking**: Accurately records your route from start to finish using `CoreLocation`.
    
- **Background Tracking**: Automatically continues to track trips even when the app is in the background, so you never miss a thing.
    
- **Route Visualization on Map**: Visualizes both live and past trip routes as a polyline on a map using `MapKit`.
    
- **Intuitive Map UX**: When the user manually pans the map, a "recenter" button appears, allowing for an easy return to tracking mode.
    
- **Trip History Management**: All trips are saved to the device's local `SwiftData` database, accessible anytime as a list with detailed route views.
    
- **Multi-language Support**: Supports English and Korean, automatically switching based on the device's language settings (using String Catalogs).
    

### 🗓️ Upcoming Features

- **Receipt Scanning**: Scan gas receipts using the Vision framework's OCR to automatically recognize and save data.
    
- **Data Analysis & Reporting**: Provide charts and reports analyzing monthly/periodic driving distance, time, and estimated earnings.
    
- **iCloud Sync**: Securely sync trip data across multiple devices.
    

## 🛠️ Tech Stack & Architecture

This project is built using the latest iOS technologies.

- **Platform**: iOS 17.0+
    
- **UI Framework**: SwiftUI
    
- **Data Persistence**: SwiftData
    
- **Location & Maps**: CoreLocation, MapKit
    
- **Architecture**: MVVM (Model-View-ViewModel)
    
- **Concurrency**: Swift Concurrency (Async/Await)
    
- **Design Pattern**: Dependency Injection to decouple views and logic.
    

## 🚀 Getting Started

How to build and run this project on your local machine.

### Prerequisites

- macOS Sonoma 14.0 or later
    
- Xcode 15.0 or later
    

### Build Steps

1. **Clone the Repository**
    
    ```
    git clone [https://github.com/your-username/DrivingLogger.git](https://github.com/your-username/DrivingLogger.git)
    cd DrivingLogger
    ```
    
2. Open the project in Xcode
    
    Open the .xcodeproj file in Xcode.
    
3. Configure Info.plist (Important)
    
    For the app to access location data correctly, you must add the following permission descriptions and background mode to your Info.plist file:
    
    - `Privacy - Location When In Use Usage Description`
        
    - `Privacy - Location Always and When In Use Usage Description`
        
    - `Required background modes`: `App registers for location updates`
        
4. Build and Run
    
    Select a simulator or a physical device and press Cmd + R to run the app.
    

## 📂 Project Structure

The project is organized according to the MVVM architectural pattern as follows:

```
DrivingLogger/
├── Models/
│   └── Trip.swift          # The SwiftData model
├── Views/
│   ├── MainTabView.swift   # The main tab view
│   ├── DashboardView.swift # The dashboard to start/stop trips
│   ├── TrackingMapView.swift # The live tracking map view
│   ├── TripHistoryView.swift # The list of past trips
│   └── ...                 # Other SwiftUI views
├── ViewModels/
│   └── DashboardViewModel.swift # Logic for the dashboard
│   └── ...                 # Other ViewModels
├── Managers/
│   └── LocationManager.swift # Manages all CoreLocation logic
└── Resources/
    └── Localizable.xcstrings # Localization strings
```

## 📜 License

This project is distributed under the [MIT License](https://www.google.com/search?q=LICENSE "null").
