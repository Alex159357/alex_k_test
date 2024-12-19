# Flutter Map Pin Sync App

## Test Apk Link
https://drive.google.com/file/d/17T71rQRghh92pxJH1zmp2zUovHpla1_r/view?usp=sharing

## Running the App with Environment Variables

To run the app with the required API keys, use the following command:

```bash
flutter run --dart-define=map_box_api_key=your_api_key_here
```

For example:
```bash
flutter run --dart-define=map_box_api_key=pk....
```

This will provide the API key to the app at runtime through the String.fromEnvironment method:
```dart
class ApiKeys {
  static const String mapboxAccessToken =
      String.fromEnvironment("map_box_api_key");
}
```

You can also add multiple environment variables:
```bash
flutter run --dart-define=map_box_api_key=your_key --dart-define=other_api_key=another_key
```

## Features

- **Offline-First Architecture**: Work seamlessly with or without internet connection
- **Real-time Map Interaction**: Add and update map pins with local storage
- **Efficient Sync Mechanism**: Background synchronization with Firebase using isolates
- **Clean Architecture**: Organized codebase following SOLID principles
- **Dependency Injection**: Modular and testable code structure

[Rest of README content...]
