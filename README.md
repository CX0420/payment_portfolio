# payment_portfolio

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Setup

This project supports multiple environments: Development (dev), SIT, and Production.

### Running Different Environments

#### Development

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

#### SIT

```bash
flutter run --flavor sit -t lib/main_sit.dart
```

#### Production

```bash
flutter run
```

### Building for Different Environments

#### Android

```bash
# Development
flutter build apk --flavor dev -t lib/main_dev.dart

# SIT
flutter build apk --flavor sit -t lib/main_sit.dart
```

#### iOS

```bash
# Development
flutter build ios --flavor dev -t lib/main_dev.dart

# SIT
flutter build ios --flavor sit -t lib/main_sit.dart
```

## Configuration

Environment-specific URLs are configured in `lib/config.dart`. Update the `baseUrl` for each environment as needed.

## Setup Commands

```bash
cd android
./gradlew clean
cd ..
flutter clean
rm -rf ~/.gradle/caches/
flutter pub get
flutter gen-l10n
flutter run
```

After making changes, always clear the corrupted cache:

```bash
rm -rf ~/.gradle/caches/
```
