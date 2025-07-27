# StudySpaces

A Flutter application for discovering study spaces at Cornell University libraries.

## Features

- 📚 Browse Cornell University libraries
- 🏛️ View detailed information about each library
- 🎨 Beautiful Material Design UI
- ✨ Hero animations for smooth transitions
- 📱 Responsive design for all screen sizes

## Library Information Includes

- Library name and category
- Detailed descriptions
- Operating hours
- Capacity and floor information
- Available features and amenities

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone this repository:
   ```bash
   git clone <your-repo-url>
   cd StudySpacesApp
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## App Structure

```
lib/
├── main.dart                    # App entry point
├── data/
│   └── libraries_data.dart      # JSON data for Cornell libraries
├── models/
│   └── library.dart             # Library data model
└── screens/
    ├── library_list_screen.dart # Main list view
    └── library_detail_screen.dart # Detailed library view
```

## Libraries Included

The app includes information about major Cornell University libraries:

- John M. Olin Library (Humanities & Social Sciences)
- Harold Uris Library (Multi-disciplinary)
- Albert R. Mann Library (Life Sciences & Agriculture)
- Engineering Library
- Carl A. Kroch Library (Special Collections)
- Mui Ho Fine Arts Library
- Sidney Cox Library of Music and Dance
- Law Library
