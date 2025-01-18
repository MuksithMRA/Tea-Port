# TeaPort

A Flutter-based tea service management application with Appwrite backend integration.

## Project Description

TeaPort is an open-source project that helps manage tea service operations efficiently. The project uses Flutter for the frontend and Appwrite for backend services, including push notifications functionality.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Appwrite Instance
- VS Code or Android Studio
- Git

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/tea_port.git
   cd tea_port
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Appwrite**
   - Set up an Appwrite project
   - Copy `functions/sendPushNotification/src/config.template.json` to `config.json`
   - Update the configuration with your Appwrite credentials

4. **Run the application**
   ```bash
   flutter run
   ```

## Contributing

We welcome contributions from the community! Here's how you can contribute:

1. **Fork the Repository**
   - Create a personal fork of the project
   - Clone your fork locally

2. **Create a Branch**
   ```bash
   git checkout -b feature/YourFeatureName
   ```

3. **Make Your Changes**
   - Write clean, maintainable code
   - Follow the existing code style
   - Add comments where necessary
   - Update documentation if needed

4. **Test Your Changes**
   - Ensure all existing tests pass
   - Add new tests if needed
   - Test on multiple devices if possible

5. **Submit a Pull Request**
   - Push your changes to your fork
   - Create a Pull Request with a clear description
   - Reference any related issues

## Project Structure

```
tea_port/
├── lib/                    # Main application code
│   ├── services/          # Service layer (Appwrite, etc.)
│   └── ...
├── functions/             # Backend functions
│   └── sendPushNotification/  # Push notification function
└── ...
```

## Development Setup

1. **Environment Setup**
   - Install Flutter and Dart
   - Set up your preferred IDE
   - Configure Appwrite locally (optional)

2. **Code Style**
   - Follow Flutter's official style guide
   - Use meaningful variable and function names
   - Comment your code when necessary

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Code of Conduct

Please read our Code of Conduct before contributing. We expect all contributors to adhere to it.

## Need Help?

- Create an issue for bug reports or feature requests
- Join our community discussions
- Check existing documentation and issues

## Contributors

Thanks to all our contributors who make this project possible!
