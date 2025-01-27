# TeaServe

A Flutter-based tea service management application with Firebase integration.

## Project Description

TeaServe is an open-source project that helps manage tea service operations efficiently. The project uses Flutter for the frontend and Firebase for backend services, including real-time push notifications functionality.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Firebase Project Setup
- VS Code or Android Studio
- Git

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/tea_serve.git
   cd tea_serve
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Set up a Firebase project in the Firebase Console
   - Download and add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update the Firebase configuration in `lib/firebase_options.dart`
   - Enable Firebase Cloud Messaging in your Firebase Console

4. **Run the application**
   ```bash
   flutter run
   ```

## Features

- Real-time push notifications using Firebase Cloud Messaging (FCM)
- Cross-platform support (Web, Android, iOS)
- Employee management interface
- Tea order tracking system
- Dynamic drink selection system

## Project Structure

```
tea_serve/
├── lib/
│   ├── screens/          # UI screens
│   ├── models/           # Data models
│   ├── services/         # Service layer (Firebase, Auth, Notifications)
│   ├── utils/           # Utility functions
│   ├── widgets/         # Reusable widgets
│   └── providers/       # State management
└── ...
```

## Development Setup

1. **Environment Setup**
   - Install Flutter and Dart
   - Set up your preferred IDE
   - Configure Firebase project
   - Set up FCM for push notifications

2. **Code Style**
   - Follow Flutter's official style guide
   - Use meaningful variable and function names
   - Comment your code when necessary

## Contributing

We welcome contributions! Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
