# Alex Karpov Test App With map and Sync

A Flutter application demonstrating offline-first architecture with Firebase integration and efficient data synchronization.

## Features

- **Offline-First Architecture**: Work seamlessly with or without internet connection
- **Real-time Map Interaction**: Add and update map pins with local storage
- **Efficient Sync Mechanism**: Background synchronization with Firebase using isolates
- **Clean Architecture**: Organized codebase following SOLID principles
- **Dependency Injection**: Modular and testable code structure

## Architecture

The project follows Clean Architecture principles with the following layers:

```
lib/
  ├── src/
      ├── core/              # Core functionality and utilities
      │   ├── database/      # Local database implementation
      │   ├── exceptions/    # Custom exceptions
      │   ├── network/       # Network related code
      │   └── utils/         # Utility classes and functions
      │
      └── features/          # Feature modules
          ├── data/          # Data layer (repositories, data sources)
          ├── domain/        # Business logic and entities
          └── presentation/  # UI layer (screens, widgets, blocs)
```

### Key Components

- **Sync Queue**: Manages offline data synchronization
  - Queues local changes when offline
  - Processes queue in background using isolates
  - Maintains data consistency between local and remote storage

- **Data Flow**:
  1. Local changes are saved immediately
  2. Changes are queued for sync
  3. Queue processor uploads pending changes
  4. Latest data is fetched from Firebase
  5. Local database is updated with remote changes

## Setup

1. Clone the repository
```bash
git clone [repository-url]
cd [project-name]
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Create a new Firebase project
- Add Android/iOS apps in Firebase console
- Download and add configuration files:
  - Android: `google-services.json`
  - iOS: `GoogleService-Info.plist`

4. Run the app
```bash
flutter run
```

## Dependencies

- **Firebase**
  - `firebase_core`: Firebase initialization
  - `firebase_auth`: Authentication
  - `cloud_firestore`: Cloud database

- **State Management**
  - `flutter_bloc`: BLoC pattern implementation

- **Local Storage**
  - `sqflite`: SQLite database
  - `shared_preferences`: Key-value storage

- **Utils**
  - `get_it`: Dependency injection
  - `logger`: Logging utility

## Sync Implementation

The sync mechanism is implemented in `SyncQueueRepositoryImpl` with the following key features:

### Queue Processing
```dart
Future<void> processQueueItems({...}) async {
  // 1. Process pending uploads
  final items = await getAllQueueItems();
  if (items.isNotEmpty) {
    await _processQueueItems(...);
  }

  // 2. Download latest data
  final remotePins = await _downloadPinsFromFirebase();
  await _updateLocalPinsWithRemote(remotePins, onError);
}
```

### Background Processing
- Uses Dart isolates for efficient queue processing
- Prevents UI blocking during sync operations
- Handles errors gracefully with proper logging

### Data Consistency
- Maintains Firebase IDs for synchronized items
- Updates local database with latest remote data
- Handles conflicts between local and remote changes

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
