# 🚀 Veltrix Sports: Production Release Guide

This document provides step-by-step instructions for compiling and submitting release builds of **Veltrix Sports** to the **Google Play Console** and **Apple App Store Connect**.

---

## 🤖 1. Android Release Build (Google Play Console)

### Step 1: Create Production Keystore
Run the following command in your terminal to generate a production signing key:
```bash
keytool -genkey -v -keystore android/veltrix_release_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias veltrix_key_alias
```

### Step 2: Configure `key.properties`
Copy `android/key.properties.example` to `android/key.properties`:
```properties
storePassword=YourKeystorePassword
keyPassword=YourKeyAliasPassword
keyAlias=veltrix_key_alias
storeFile=../veltrix_release_key.jks
```

### Step 3: Build Android App Bundle (`.aab`)
```bash
flutter build appbundle --release
```
- **Output Artifact:** `build/app/outputs/bundle/release/app-release.aab`
- Upload this `.aab` file directly to Google Play Console under **Production > Release Tracks**.

---

## 🍏 2. iOS Release Build (Apple App Store Connect)

### Step 1: Xcode Signing Setup
1. Open the iOS module in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Under **Signing & Capabilities**:
   - Select your **Apple Developer Team**.
   - Enable **HealthKit** capability (`com.apple.developer.healthkit`).
   - Enable **Background Modes** (Remote notifications).

### Step 2: Build iOS Archive (`.ipa`)
```bash
flutter build ipa --release
```
- **Output Artifact:** `build/ios/archive/Runner.xcarchive`
- Distribute via Xcode Organizer to **App Store Connect / TestFlight**.

---

## 🌐 3. Web Production Build

```bash
flutter build web --release
```
- **Output Artifact:** `build/web/`
- Deploy to Firebase Hosting, Vercel, or AWS CloudFront.

---

## 🛡️ Production Verification Checklist
- [x] `flutter analyze` returns **0 errors, 0 warnings**.
- [x] `flutter test` executes **30/30 passing unit & widget test suites**.
- [x] Firestore security rules deployed (`firestore.rules`).
- [x] Razorpay Test Keys replaced with Live Merchant Key (`rzp_live_...`).
