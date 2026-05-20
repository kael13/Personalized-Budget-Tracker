# Bloom Budget - Flutter (iOS)

This is the Flutter refactor of the Bloom Budget app, optimized for iOS with native SQLite storage.

## Project Structure
- `lib/models/`: Data models for Budget, Category, and Sub-category.
- `lib/services/`: SQLite integration via `sqflite`.
- `lib/screens/`: UI screens (Home, Detail, etc.).
- `pubspec.yaml`: Project dependencies.

## Key Features
- **SQLite Storage**: Persistent local storage using the `sqflite` plugin.
- **Pastel UI**: Custom themed Material 3 widgets with a pastel pink aesthetic.
- **Animations**: Fluid transitions using `flutter_animate`.
- **Charts**: Data visualization ready via `fl_chart`.

## How to Run Locally
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Clone/Copy this `/flutter` directory to your machine.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` on an iOS Simulator or connected device.

## Why Flutter?
Refactoring to Flutter provides:
1. **Performance**: Native performance on iOS.
2. **Persistence**: True SQLite integration which is more robust than browser local storage for mobile apps.
3. **Consistency**: Pixel-perfect UI across iOS devices.

---
*Note: The AI Studio live preview continues to run the React version for development convenience. This directory contains the source-of-truth for your native iOS app.*
