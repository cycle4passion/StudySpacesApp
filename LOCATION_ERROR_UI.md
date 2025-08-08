# Location Error UI Scenarios

## Overview

The StudySpaces app now provides distinct UI feedback for different location-related error scenarios when users attempt to report on study spaces.

## UI Scenarios

### 1. Permission Denied
**Error Type:** `GeofenceErrorType.permissionDenied`
- **Background Color:** Light red (`Colors.red.shade50`)
- **Border Color:** Red (`Colors.red.shade200`)
- **Icon:** `Icons.location_disabled` (red)
- **Title:** "Location Permission Required"
- **Message:** "Location permission is required to verify you are at the study space. Please enable location access in your device settings."
- **Actions:** 
  - "Try Again" button (retries location check)
  - "Settings" button (shows instructions dialog)

### 2. Location Services Disabled
**Error Type:** `GeofenceErrorType.locationServicesDisabled`
- **Background Color:** Light amber (`Colors.amber.shade50`)
- **Border Color:** Amber (`Colors.amber.shade200`)
- **Icon:** `Icons.location_off` (amber)
- **Title:** "Location Services Disabled"
- **Message:** "Location services are disabled. Please enable location services in your device settings to verify your presence at the study space."
- **Actions:** 
  - "Try Again" button (retries location check)
  - "Settings" button (shows instructions dialog)

### 3. Outside Geofence
**Error Type:** `GeofenceErrorType.outsideGeofence`
- **Background Color:** Light orange (`Colors.orange.shade50`)
- **Border Color:** Orange (`Colors.orange.shade200`)
- **Icon:** `Icons.location_searching` (orange)
- **Title:** "Location Verification Required"
- **Message:** "Thank you for supporting StudySpaces. However, you may only report on [Space Name] when you are physically present at that location."
- **Actions:** None (user needs to physically move to the location)

### 4. Location Error
**Error Type:** `GeofenceErrorType.locationError`
- **Background Color:** Light grey (`Colors.grey.shade50`)
- **Border Color:** Grey (`Colors.grey.shade200`)
- **Icon:** `Icons.error_outline` (grey)
- **Title:** "Location Error"
- **Message:** "Unable to determine your location. Please check your internet connection and try again."
- **Actions:** None (system-level error)

## Implementation Details

### Error Type Detection
The `SpacesUtils.geofenceWithDetails()` method returns a `GeofenceResult` object containing:
- `success`: Boolean indicating if user can report
- `errorType`: Specific error type for UI customization

### UI Builder Method
The `_buildLocationErrorWidget()` method in `ReportScreen` handles:
- Dynamic color schemes based on error type
- Appropriate icons for each scenario
- Contextual action buttons where helpful
- Developer mode indicator when `fakeLocation` is enabled

### User Experience Flow
1. User selects a study space
2. App checks location with detailed error reporting
3. If error occurs, shows appropriate UI with:
   - Visual distinction (colors/icons)
   - Helpful messaging
   - Actionable buttons when applicable
   - Clear next steps for resolution

### Action Buttons
- **Try Again:** Available for permission and service errors
  - Retries the location check
  - Useful after user enables permissions/services
- **Settings:** Available for permission and service errors
  - Shows instruction dialog
  - Guides user through settings enablement

### Visual Hierarchy
- **Red (Permission Denied):** Most critical - app can't function
- **Amber (Services Disabled):** Critical - system-level issue
- **Orange (Outside Geofence):** Expected behavior - user education
- **Grey (Location Error):** Technical issue - may be temporary

## Testing Different Scenarios

### Developer Mode
- Set `SpacesUtils.fakeLocation = true` to bypass all checks
- Shows blue developer indicator in all error UIs

### Simulating Errors
1. **Permission Denied:** Deny location permission in browser/device
2. **Services Disabled:** Turn off location services in device settings
3. **Outside Geofence:** Be physically outside the study space range
4. **Location Error:** Disconnect from internet during location check

## Accessibility Features
- High contrast color schemes
- Descriptive icons for screen readers
- Clear, actionable text
- Logical tab order for action buttons

## Future Enhancements
- Platform-specific settings deep links
- Offline location caching
- Progressive location accuracy degradation
- Custom geofence radius per space type
