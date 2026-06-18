# Changelog

## 1.0.4 - 2024-01-18

### Fixed
- **Android Build Issues**
  - Fixed `Registrar` class deprecation by removing `PluginRegistry.Registrar` imports
  - Updated plugin to use only `FlutterPlugin` and `MethodCallHandler` interfaces
  - Fixed Java compilation errors with proper method channel handling
  - Added proper null safety checks for method arguments
  - Fixed `TrafficStats.UNSUPPORTED` handling on Android devices

- **Gradle Configuration**
  - Removed Kotlin dependencies (pure Java now)
  - Updated Android Gradle Plugin to 8.2.2
  - Updated Gradle wrapper to 8.3
  - Fixed Gradle build issues with Java 11+ compatibility
  - Fixed `No space left on device` errors with better cache management

- **Native Library Issues**
  - Added `packagingOptions` to handle problematic `.so` files
  - Fixed NDK stripping errors with `doNotStrip` configuration
  - Added support for older NDK versions (26.1.10909125)
  - Fixed library validation errors for hardware SDKs

### Changed
- **Java Version**
  - Updated `sourceCompatibility` and `targetCompatibility` to Java 11
  - Improved compatibility with modern Android development environments

- **Channel Names**
  - Updated event and method channel names to match package structure
  - Using `com.vinay.network_speed_plus/events` and `com.vinay.network_speed_plus/methods`

- **Error Handling**
  - Improved error handling for missing method arguments
  - Added better error messages for troubleshooting
  - Enhanced logging for debugging

### Added
- **Documentation**
  - Updated README with detailed installation instructions
  - Added comprehensive API documentation
  - Added example usage for all widgets
  - Improved troubleshooting section

- **Testing**
  - Added unit tests for core functionality
  - Added integration tests for plugin features
  - Added test coverage for SpeedData model

- **Widgets**
  - All widgets now use ValueNotifier for reactive updates
  - No external dependencies required (pure Flutter)
  - Improved widget performance with better state management

---

## 1.0.3 - 2024-01-18

### Fixed
- Fixed package naming conflicts
- Updated dependencies to latest versions

---

## 1.0.2 - 2024-01-18

### Fixed
- Minor bug fixes
- Performance improvements

---

## 1.0.1 - 2024-01-18

### Fixed
- Initial release fixes

---

## 1.0.0 - 2024-01-18

### Added
- Initial release with Android and iOS support
- Total device traffic monitoring
- App-specific traffic monitoring (Android only)
- Configurable update intervals
- Built-in widgets: SpeedDisplay, SpeedControls, SpeedOverlay, SpeedStatus
- ValueNotifier-based reactive updates
- MIT License
All notable changes to this project will be documented in this file.

## 1.0.0

* Initial release of `network_speed_plus`
* Real-time network speed monitoring
* Download and upload speed tracking
* Total device traffic monitoring
* App-specific traffic monitoring
* Configurable update intervals
* Stream-based API support
* Android support using TrafficStats
* Example application included
* MIT License 
