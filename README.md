# StudySpaces

A comprehensive Flutter application for discovering study spaces at Cornell University libraries with real-time reporting, leaderboards, and user profiles.

## ✨ Features

### Core Functionality
- 📚 **Browse Cornell University Study Spaces** - View all available study spaces with detailed information
- 🏛️ **Detailed Space Information** - Library descriptions, hours, capacity, features, and contact details
- 📊 **Real-time Fullness Reporting** - Report and view current space occupancy levels
- 🏆 **Leaderboard System** - Track and compare user reporting activity across different time periods
- 👤 **User Profiles** - Personal statistics, preferences, and favorite spaces
- 🌓 **Dark/Light Mode** - Toggle between themes with persistent preferences
- 🎯 **Smart Filtering** - Filter spaces by availability, features, and preferences
- ⭐ **Favorite Spaces** - Mark and prioritize frequently used study spaces
- 📍 **Location-based Features** - Geofencing for accurate reporting
- 🔄 **Pull-to-Refresh** - Keep space information up to date

### Advanced Features
- 🎨 **Beautiful Material Design 3 UI** - Modern, responsive interface
- ✨ **Hero Animations** - Smooth transitions between screens
- 📱 **Cross-platform Support** - iOS, Android, and Web
- 🌐 **Reservation Integration** - Direct links to Cornell's space reservation system
- 📈 **Analytics Dashboard** - Personal and community statistics
- 🔍 **Smart Search & Sort** - Find spaces by availability, favorites, and distance

## 📊 App Structure

```
lib/
├── main.dart                           # App entry point with theme management
├── data/
│   └── spaces_data.dart               # JSON data for spaces, fullness, and profiles
├── models/
│   ├── models.dart                    # Model exports
│   ├── profile.dart                   # User profile data model
│   └── space.dart                     # Study space data model
├── utils/
│   ├── color_utils.dart              # Color and theme utilities
│   ├── profile_utils.dart            # Profile data management
│   ├── spaces_utils.dart             # Space operations & geofencing
│   └── text_utils.dart               # Text formatting utilities
└── screens/
    ├── main_navigation_screen.dart    # Bottom tab navigation controller
    ├── home_screen.dart              # Main space listing with filters
    ├── space_details_screen.dart     # Detailed space view & reservations
    ├── report_screen.dart            # Fullness reporting with location validation
    ├── leaderboard_screen.dart       # Community reporting rankings
    ├── profile_screen.dart           # User statistics and preferences
    └── add_space_screen.dart         # Suggest new study spaces
```

## 🏛️ Included Cornell Study Spaces

The app includes comprehensive information about major Cornell University libraries:

- **John M. Olin Library** - Humanities & Social Sciences
- **Harold Uris Library** - Multi-disciplinary
- **Albert R. Mann Library** - Life Sciences & Agriculture  
- **Engineering Library** - Engineering & Technology
- **Carl A. Kroch Library** - Special Collections & Archives
- **Mui Ho Fine Arts Library** - Arts & Architecture
- **Sidney Cox Library of Music and Dance** - Music & Performing Arts
- **Law Library** - Legal Research

Each space includes:
- 📍 **Location & Contact** - Address, phone, and GPS coordinates
- ⏰ **Operating Hours** - Daily schedules with real-time open/closed status
- 🏢 **Physical Details** - Capacity, floors, and accessibility
- ⚡ **Features & Amenities** - WiFi, printing, study rooms, cafes
- 📊 **Live Fullness Data** - Community-reported occupancy levels
- 🎫 **Reservation Links** - Direct integration with Cornell's booking system

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (latest stable version - 3.0+ recommended)
- **Dart SDK** (included with Flutter)
- **IDE** (VS Code with Flutter extension, Android Studio, or IntelliJ)
- **Platform-specific tools**:
  - **Android**: Android Studio & SDK
  - **iOS**: Xcode (macOS only)
  - **Web**: Chrome browser

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/cycle4passion/StudySpacesApp.git
   cd StudySpacesApp
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   # For development (debug mode)
   flutter run
   
   # For web development
   flutter run -d chrome
   
   # For specific device
   flutter devices  # List available devices
   flutter run -d [device_id]
   ```

4. **Build for release**:
   ```bash
   # Android APK
   flutter build apk --release
   
   # iOS (macOS only)
   flutter build ios --release
   
   # Web
   flutter build web --release
   ```

## 🎯 Key Features Deep Dive

### 📊 Reporting System
- **Location Validation**: Geofencing ensures reports are made from actual locations
- **Fullness Scale**: 5-point scale from "Very Empty" to "Very Full"
- **Real-time Updates**: Immediate reflection of reported data
- **User Contribution**: Build community knowledge of space availability

### 🏆 Leaderboard & Gamification
- **Multiple Time Periods**: Daily, Weekly, Monthly, and All-time rankings
- **Clickable Statistics**: Navigate directly from profile stats to leaderboards
- **Personal Tracking**: Monitor your contribution and ranking trends
- **Community Engagement**: See top contributors and encourage participation

### 🎨 User Interface
- **Material Design 3**: Modern, accessible design system
- **Hero Animations**: Smooth image transitions between list and detail views
- **Dark/Light Themes**: Automatic theme switching with user preference storage
- **Responsive Layout**: Optimized for phones, tablets, and web browsers

### 🔧 Technical Features
- **Data Architecture**: Separated static space data from dynamic fullness data
- **Profile Management**: Persistent user preferences and favorites
- **Filter System**: Location-based filter configuration
- **State Management**: Efficient state handling for smooth performance
- **Cross-platform**: Single codebase for iOS, Android, and Web

## 🏗️ Architecture & Data Models

### Data Separation
- **spacesJSON**: Static space information (locations, hours, features)
- **fullnessJSON**: Dynamic occupancy data (community-reported)
- **profileJSON**: User data (preferences, statistics, favorites)

### Key Models
- **Space**: Study space entity with location, hours, and features
- **Profile**: User profile with statistics and preferences
- **Utility Classes**: Helper functions for colors, text, spaces, and profiles

## 🤝 Contributing

This project follows Flutter best practices and includes:
- Proper JSON serialization
- Material Design components
- State management patterns
- Responsive design principles
- Accessibility considerations

### Development Guidelines
- Use `debugPrint()` instead of `print()` for logging
- Implement proper hero animations for transitions
- Follow Material Design 3 guidelines
- Use `withValues(alpha: value)` instead of deprecated `withOpacity()`
- Prefer `surfaceContainerHighest` over deprecated `surfaceVariant`

## 📝 Dependencies

Key Flutter packages used:
- `shared_preferences`: Theme and user preference persistence
- `geolocator`: Location services for reporting validation
- `permission_handler`: Location permission management
- `webview_flutter`: Embedded reservation system
- `url_launcher`: External link handling

## 🐛 Known Issues & Considerations

- Location services required for fullness reporting
- WebView reservation system requires internet connectivity
- Some features optimized for campus network access

## 📱 Platform Support

- ✅ **Android** 5.0+ (API level 21+)
- ✅ **iOS** 12.0+
- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ⚠️ **Desktop** (Limited testing on Windows/macOS/Linux)

---

Built with ❤️ for the Cornell University community using Flutter & Dart.
