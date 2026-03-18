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

## NFC & EMV Card Reading

This app supports NFC tag reading and EMV credit/debit card scanning:

### Features

- **NFC Tag Reading**: Read standard NFC tags and NDEF data
- **EMV Card Support**: Read credit/debit card information including:
  - Card number (PAN) - masked for security
  - Cardholder name
  - Expiry date
  - Card type detection (Visa, Mastercard, Amex, Discover)

### Supported Card Types

- Visa
- Mastercard
- American Express
- Discover

### Usage

1. Navigate to the scanning page
2. Bring NFC tag or EMV card close to device
3. App will automatically detect and read card information
4. Card details are displayed on the payment result screen

### Security Note

Card numbers are automatically masked (showing only last 4 digits) for security purposes.

### Troubleshooting EMV Card Detection

If your EMV card is not being detected:

1. **Check NFC Settings**: Ensure NFC is enabled on your device
2. **Card Compatibility**: Not all EMV cards support contactless reading
3. **Card Position**: Try different positions and orientations of the card
4. **Debug Information**: Check device logs for detailed tag information
5. **Card Type**: Some older cards may not support the required EMV applications

The app will automatically detect and read from Visa, Mastercard, American Express, and Discover cards.

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
