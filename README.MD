# FlutterForDeepLearning

A Flutter application that allows users to take pictures and send them to a specified endpoint.

## Getting Started

1. Ensure you have Flutter installed on your machine.
2. Clone this repository.
3. Run `flutter pub get` to install dependencies.
4. Update the `YOUR_API_ENDPOINT_HERE` in `lib/main.dart` with your actual API endpoint.
5. Run the app using `flutter run`.

## Features

- Take pictures using the device camera
- Send captured pictures to a specified API endpoint

## Dependencies

- camera: ^0.10.5+2
- path_provider: ^2.0.15
- http: ^1.1.0
- path: ^1.8.3

## Note

Ensure you have the necessary permissions set up in your `AndroidManifest.xml` (for Android) and `Info.plist` (for iOS) files as described in the respective files.
