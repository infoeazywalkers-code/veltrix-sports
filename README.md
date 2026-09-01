# Veltrix Sports

A modern, cross-platform sports and fitness tracking application built with Flutter and Firebase.

## Features

- **Cross-Platform** -- Runs on Web, Android, and iOS from a single codebase
- **Firebase Integration** -- Authentication, Analytics, Cloud Messaging, and Dynamic Links
- **Responsive Design** -- Adaptive layouts for mobile and desktop/web
- **Workout Tracking** -- Log, view, and track workout sessions with detailed metrics
- **Progress Monitoring** -- Visual progress dashboards with rings, charts, and insights
- **Calendar View** -- Schedule and manage training sessions
- **Coach Matching** -- Connect with coaches and trainers
- **Device Integration** -- Sync with wearables and fitness devices
- **Premium Features** -- Tiered access with premium content

## Tech Stack

| Layer          | Technology                      |
| -------------- | ------------------------------- |
| Framework      | Flutter (Dart)                  |
| Backend        | Firebase (Auth, Firestore, FCM) |
| State Mgmt     | Widgets + Services              |
| Analytics      | Firebase Analytics              |
| Platform       | Web, Android, iOS               |
| Min SDK        | Dart ^3.7.0                     |

## Project Structure

```
lib/
  main.dart              # App entry point with Firebase init
  constants.dart         # Theme colors, styles, shared constants
  shell.dart             # Web/desktop responsive shell
  auth_service.dart      # Firebase Authentication service
  firebase_options.dart  # Firebase config (auto-generated, gitignored)
  screens/               # Web/desktop screen views
    home_screen.dart
    explore_screen.dart
    progress_screen.dart
    profile_screen.dart
    workout_details.dart
    calendar_screen.dart
    coach_match_screen.dart
    devices_screen.dart
    premium_screen.dart
    strength_screen.dart
  widgets/               # Shared reusable widgets
  mobile/                # Mobile-specific UI
    app.dart             # Mobile app entry
    shell.dart           # Mobile navigation shell
    theme.dart           # Mobile theme
    screens/             # Mobile screen views
    widgets/             # Mobile-specific widgets
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.7+)
- [Dart SDK](https://dart.dev/get-dart)
- A [Firebase](https://console.firebase.google.com/) project

### Setup

```bash
# Clone the repository
git clone https://github.com/infoeazywalkers-code/veltrix-sports.git
cd veltrix-sports

# Install dependencies
flutter pub get

# Configure Firebase (create your own firebase_options.dart)
flutterfire configure

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS (macOS only)
flutter run -d ios
```

### Build

```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## Configuration

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)
2. Enable Authentication, Cloud Firestore, and Cloud Messaging
3. Run `flutterfire configure` to generate `firebase_options.dart`
4. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is private and proprietary.

---

Built with Flutter and Firebase
