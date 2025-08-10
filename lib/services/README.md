# API Services Documentation

This directory contains the API service files for making HTTP requests to backend servers.

## 📦 Added Packages

The following packages have been added to `pubspec.yaml` for API functionality:

```yaml
dependencies:
  # API and HTTP packages
  http: ^1.2.0                    # Basic HTTP client for API calls
  dio: ^5.4.0                     # Advanced HTTP client with interceptors, retries, etc.
  connectivity_plus: ^5.0.2       # Check network connectivity
  json_annotation: ^4.8.1         # For JSON serialization annotations

dev_dependencies:
  json_serializable: ^6.7.1       # Code generation for JSON serialization
  build_runner: ^2.4.7            # Required for code generation
```

## 🏗️ Service Files

### 1. `api_service.dart` - Base API Service (Dio)
- **Purpose**: Comprehensive HTTP client using Dio package
- **Features**:
  - Request/response interceptors
  - Authentication handling
  - Network connectivity checks
  - Error handling and user-friendly messages
  - Automatic retries and timeout handling
  - Logging (debug mode only)

### 2. `studyspaces_api_service.dart` - StudySpaces Specific API
- **Purpose**: Application-specific API methods for StudySpaces app
- **Endpoints**:
  - Spaces: Get all spaces, search, get individual space details
  - Fullness: Submit reports, get current data, get history
  - Profile: Get/update user profiles, favorites, filters
  - Leaderboard: Get rankings, user rank
  - Suggestions: Submit new space suggestions
  - Authentication: Login, register, logout
  - Filters: Get available filters by location

### 3. `simple_http_service.dart` - Simple HTTP Service
- **Purpose**: Lightweight HTTP client using basic `http` package
- **Features**:
  - Simple GET, POST, PUT, DELETE methods
  - Basic authentication support
  - Error handling
  - Timeout handling
  - Perfect for simple API needs

## 🚀 Quick Start

### Initialize API Service

```dart
import 'package:your_app/services/studyspaces_api_service.dart';

void main() {
  // Initialize the API service
  StudySpacesApiService().initialize();
  runApp(MyApp());
}
```

### Example Usage

```dart
// Fetch all spaces
final apiService = StudySpacesApiService();
try {
  final spaces = await apiService.getSpaces();
  print('Loaded ${spaces.length} spaces');
} catch (e) {
  print('Error: $e');
}

// Submit fullness report
try {
  final success = await apiService.submitFullnessReport(
    spaceId: 'olin',
    fullness: 3,
    latitude: 42.4477741,
    longitude: -76.4841596,
  );
  print('Report submitted: $success');
} catch (e) {
  print('Error: $e');
}
```

## 🔧 Configuration

### Base URL
Update the base URL in `api_service.dart`:

```dart
static const String baseUrl = 'https://your-api.com'; // Replace with your API URL
```

### Authentication
The services support Bearer token authentication. Set tokens using:

```dart
await apiService.setAuthToken('your-jwt-token');
```

### Timeouts
Configure timeouts in `api_service.dart`:

```dart
static const Duration connectTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
```

## 🌐 API Endpoints Reference

### Spaces
- `GET /api/spaces` - Get all spaces
- `GET /api/spaces/{id}` - Get specific space
- `GET /api/spaces/search?q={query}` - Search spaces

### Fullness
- `POST /api/spaces/{id}/fullness` - Submit fullness report
- `GET /api/fullness` - Get current fullness data
- `GET /api/spaces/{id}/fullness/history` - Get fullness history

### User Profile
- `GET /api/users/{id}/profile` - Get user profile
- `PUT /api/users/{id}/profile` - Update user profile
- `PUT /api/users/{id}/favorites` - Update favorite spaces
- `PUT /api/users/{id}/filters` - Update selected filters

### Leaderboard
- `GET /api/leaderboard?period={period}&limit={limit}` - Get leaderboard
- `GET /api/users/{id}/rank?period={period}` - Get user rank

### Authentication
- `POST /api/auth/login` - Login user
- `POST /api/auth/register` - Register new user
- `POST /api/auth/logout` - Logout user

### Space Suggestions
- `POST /api/spaces/suggestions` - Submit space suggestion

### Filters
- `GET /api/locations/{location}/filters` - Get available filters

## 🛡️ Error Handling

The services include comprehensive error handling:

- **Network errors**: Connectivity checks and user-friendly messages
- **HTTP errors**: Status code specific error messages
- **Timeouts**: Configurable timeout handling
- **Authentication**: Automatic token management
- **Retry logic**: Built-in retry for failed requests

## 📱 Integration Examples

See `examples/api_integration_example.dart` for complete integration examples showing:

- How to fetch data from APIs
- How to submit data to APIs
- How to handle loading states
- How to integrate with existing screens
- Error handling and fallback strategies

## 🔒 Security Considerations

- Tokens are stored securely (implement proper storage)
- HTTPS is enforced for production
- Request/response logging only in debug mode
- Input validation and sanitization
- Rate limiting awareness

## 🧪 Testing

To test the API services:

1. Set up your backend API server
2. Update the base URL in the service files
3. Use the example integration file to test endpoints
4. Implement proper error handling and fallbacks

## 📝 Notes

- The services are designed to work with or without a backend
- Local JSON data can be used as fallback
- All methods are async and return Futures
- Proper null safety is implemented throughout
- Services use singleton pattern for efficiency

## Example
```js
// Initialize the API service
final apiService = StudySpacesApiService();
apiService.initialize();

// Fetch spaces
try {
  final spaces = await apiService.getSpaces();
  print('Loaded ${spaces.length} spaces');
} catch (e) {
  print('Error: $e');
}

// Submit fullness report
try {
  final success = await apiService.submitFullnessReport(
    userId: "j9999",
    spaceId: 'olin',
    fullness: 3,
  );
} catch (e) {
  print('Error submitting report: $e');
}
```