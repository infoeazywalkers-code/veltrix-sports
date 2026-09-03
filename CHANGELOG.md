# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions CI/CD workflows (analyze, test, build-web, build-android, build-android-bundle, check-formatting)
- Dependabot configuration for automated dependency updates
- CODEOWNERS file for review assignments
- Issue templates (bug_report, feature_request)
- Pull request template
- Professional .gitignore with comprehensive Flutter/Dart/Android/iOS rules

### Fixed
- Google Sign-In v7.2.0 API compatibility in `auth_service.dart`
- Android Gradle KTS build configuration for AGP 9.0+
- ProGuard/R8 rules for modern Android builds
- AndroidManifest.xml typo (`usesCleartextTraffic`)
- Firebase Analytics dependency version pinning

## [1.0.0] - 2026-09-03

### Added
- Initial project structure with Flutter + Firebase
- Cross-platform support (Web, Android, iOS)
- Google Sign-In authentication
- Workout tracking and calendar
- Coach matching questionnaire
- Premium subscription UI
- Device integration screens
- Strength training module
- Progress tracking dashboard
- Responsive web/desktop shell
- Video player with autoplay/loop
- Comprehensive widget test suite

### Changed
- Migrated from google_sign_in v6 to v7
- Updated Firebase dependencies to latest compatible versions
- Improved responsive layouts for tablet/desktop

### Fixed
- Flutter analyzer errors
- Widget test viewport issues
- Web build configuration

---

## Release Process

1. Create a release tag: `git tag v1.0.0 && git push origin v1.0.0`
2. GitHub Actions will automatically:
   - Build Web, Android APK, and Android App Bundle
   - Create a GitHub Release with artifacts
   - Generate release notes from PRs

## Versioning

This project follows Semantic Versioning:
- MAJOR version for incompatible API changes
- MINOR version for backward-compatible functionality
- PATCH version for backward-compatible bug fixes