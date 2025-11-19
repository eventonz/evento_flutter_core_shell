# Event Configuration Files

This folder contains YAML configuration files for each white-label event app.

## Structure

Each event has its own YAML file (e.g., `melb2026.yaml`, `gc2026.yaml`) that defines:

- **App Name** - Display name shown in app stores and on device
- **Bundle Name** - Short name used internally (for notifications, system settings)
- **Bundle IDs** - Unique identifiers for Android and iOS
- **OneSignal ID** - Push notification service identifier
- **Event Configuration** - API endpoints and event IDs
- **App Icon** - Cloud URL for app icon (downloaded during build)
- **Splash Image** - Cloud URL for splash screen (downloaded during build)
- **Firebase Config** - Cloud URLs for Firebase Analytics config files (Android & iOS)
- **Optional Settings** - Search bar color, timer features, etc.

## Required Fields

All config files must include:

```yaml
app_name: "Your Event Name"
bundle_name: "YourEventName"
app_id: 100
onesignal_id: "your-onesignal-app-id"
android_bundle_id: "com.yourcompany.eventname"
ios_bundle_id: "com.yourcompany.eventname"
icon_url: "https://your-cdn.com/icon.png"
splash_url: "https://your-cdn.com/splash.png"
firebase_android_url: "https://your-cdn.com/google-services.json"
firebase_ios_url: "https://your-cdn.com/GoogleService-Info.plist"
```

Plus either:
- `single_event_url` and `single_event_id` (for single event apps)
- OR `multi_event_list_url` and `multi_event_list_id` (for multi-event apps)

## Creating a New Event Config

1. Copy the template:
   ```bash
   cp config.template.yaml myevent2026.yaml
   ```

2. Edit the file with your event details

3. **Register iOS Bundle ID** (required before building for device):
   - Go to https://developer.apple.com/account/resources/identifiers/list
   - Create new App ID with your `ios_bundle_id`
   - Enable capabilities: Push Notifications, Associated Domains
   - Register your test device UDID if needed
   - Or let Xcode auto-register: `open ios/Runner.xcworkspace`

4. Ensure your assets (icon, splash, Firebase configs) are accessible via the URLs you provide

4. Build using:
   ```bash
   # From shell directory
   ./scripts/build.sh configs/myevent2026.yaml --dev      # For testing
   ./scripts/build.sh configs/myevent2026.yaml --release  # For release
   
   # Or directly with Dart
   dart run tool/build_app.dart configs/myevent2026.yaml --release
   ```

## Asset Requirements

### App Icon
- **Format**: PNG
- **Size**: 1024x1024 pixels (recommended)
- **Location**: Cloud URL accessible during build
- **Usage**: 
  - Downloaded to `assets/generated/icon.png` during build
  - Automatically processed by `flutter_launcher_icons` to generate all required icon sizes for Android and iOS
  - Icons are generated for both platforms automatically

### Splash Image
- **Format**: PNG
- **Size**: 2048x2048 pixels (recommended) or match app aspect ratio
- **Location**: Cloud URL accessible during build
- **Usage**: 
  - Downloaded to `assets/generated/splash.png` during build
  - Automatically processed by `flutter_native_splash` to generate splash screens for Android and iOS
  - Supports Android 12+ splash screens automatically

### Firebase Configuration Files

#### Android: google-services.json
- **Format**: JSON
- **Location**: Cloud URL accessible during build
- **Usage**: Downloaded to `android/app/google-services.json` during build
- **Source**: Download from Firebase Console → Project Settings → Your Android app

#### iOS: GoogleService-Info.plist
- **Format**: XML/PLIST
- **Location**: Cloud URL accessible during build
- **Usage**: Downloaded to `ios/Runner/GoogleService-Info.plist` during build
- **Source**: Download from Firebase Console → Project Settings → Your iOS app

**Note**: These files are per-app and contain sensitive configuration. They are gitignored and downloaded during each build.

### Android Signing Configuration

#### Option 1: Download key.properties from URL
- **Format**: Properties file
- **Location**: Cloud URL accessible during build
- **Usage**: Downloaded to `android/key.properties` during build
- **Contents**: Should contain `storePassword`, `keyPassword`, `keyAlias`, and `storeFile` path

#### Option 2: Provide Individual Fields
- **Fields**: `key_store_password`, `key_password`, `key_alias`, `keystore_file_url`
- **Usage**: Build script will generate `key.properties` from these fields
- **Keystore File**:
  - **Local Path (RECOMMENDED)**: Use absolute local file path
    ```yaml
    keystore_file_url: "/Users/yourname/path/to/keystore.jks"
    ```
  - **Cloud URL (NOT RECOMMENDED)**: Only for testing, never for production
    ```yaml
    keystore_file_url: "https://your-cdn.com/keystore.jks"  # INSECURE
    ```

**⚠️ SECURITY WARNING**: 
- **NEVER** store keystore files in cloud storage or commit them to git
- **NEVER** share keystore files or passwords
- Use local file paths only for production builds
- Keystore files contain sensitive signing keys that cannot be recovered if lost

**Note**: Signing configuration is required for release builds. For dev builds, it's optional and debug signing will be used.

## Example Config Files

- `melb2026.yaml` - Melbourne Marathon 2026 (single event)
- `gc2026.yaml` - Gold Coast Marathon 2026 (multi-event)
- `config.template.yaml` - Template with all available options

