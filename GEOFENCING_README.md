# Geofencing Implementation for StudySpaces

## Overview

The StudySpaces app now includes geofencing functionality that restricts users from submitting reports unless they are physically present at the study space location.

## Implementation Details

### Files Modified

1. **`lib/utils/spaces_utils.dart`** - Added geofencing functionality
2. **`lib/screens/report_screen.dart`** - Added location checking UI and logic
3. **`pubspec.yaml`** - Added required dependencies
4. **`android/app/src/main/AndroidManifest.xml`** - Added location permissions
5. **`ios/Runner/Info.plist`** - Added location permission descriptions

### Dependencies Added

- `geolocator: ^11.0.0` - For location services and distance calculations
- `permission_handler: ^11.3.1` - For requesting location permissions

### Key Functions

#### `SpacesUtils.geofence()`
```dart
static Future<bool> geofence({
  required double centerLat,
  required double centerLon, 
  required double radiusMeters,
}) async
```
Checks if the user is within the specified radius of a location using the Haversine formula.

#### `SpacesUtils.canReportAtSpace()`
```dart
static Future<bool> canReportAtSpace({
  required double spaceLat,
  required double spaceLon,
  required double spaceRange,
}) async
```
Convenience method that uses the space's latitude, longitude, and range from the JSON data.

## Developer Features

### Fake Location Toggle

For testing purposes, there's a developer flag that can bypass location checking:

```dart
SpacesUtils.fakeLocation = true; // Default: false
```

When set to `true`, the geofence check will always return `true`, allowing developers to test the reporting functionality without being physically present at a study space.

### How to Enable Developer Mode

1. Set `SpacesUtils.fakeLocation = true` in your code (currently in `spaces_utils.dart`)
2. The UI will show a blue developer mode indicator when location restrictions are bypassed
3. Remember to set it back to `false` for production

## User Experience

### Location Check Flow

1. User selects a study space from the dropdown
2. App automatically checks user's location against the space's geofence
3. Shows loading indicator while checking location
4. If user is outside the geofence:
   - Shows restriction message: "Thank you for supporting StudySpaces. However, you may only report on [Space Name] when you are physically present at that location."
   - Disables the submit button
   - Hides the fullness slider
5. If user is within the geofence:
   - Shows normal report form
   - Enables submit functionality

### Permission Handling

- App requests location permission when first checking location
- If permission is denied, shows error message
- If location services are disabled, shows appropriate error

## Technical Details

### Location Accuracy

- Uses `LocationAccuracy.high` for precise location checking
- Calculates distance using the Haversine formula for accuracy
- Each study space has its own `range` value (in meters) defining the geofence radius

### Platform Support

- **Android**: Requires `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` permissions
- **iOS**: Requires `NSLocationWhenInUseUsageDescription` permission
- **Web**: Uses browser's geolocation API (may have different accuracy)

### Error Handling

- Network/GPS unavailable
- Permission denied
- Location services disabled
- Invalid coordinates

## Data Structure

Each study space in `spaces_data.dart` includes:
```json
{
  "latitude": 42.4477741,
  "longitude": -76.4841596,
  "range": 50.0
}
```

Where `range` is the geofence radius in meters.

## Future Enhancements

1. **Caching**: Store location permissions to avoid repeated requests
2. **Offline Mode**: Allow cached location for brief offline periods
3. **Accuracy Tuning**: Adjust location accuracy requirements based on testing
4. **Analytics**: Track location check success/failure rates
5. **Custom Ranges**: Allow different geofence sizes for different space types

## Testing

### Manual Testing Steps

1. Enable developer mode: `SpacesUtils.fakeLocation = true`
2. Test report submission (should work from anywhere)
3. Disable developer mode: `SpacesUtils.fakeLocation = false`
4. Try reporting from different locations
5. Test permission denied scenarios
6. Test location services disabled scenarios

### Automated Testing

Consider adding unit tests for:
- Haversine distance calculations
- Permission handling edge cases
- UI state changes based on location
