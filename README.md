# EnvFriendly: Smart Refills App

## Table of Contents
1. [Introduction](#introduction)
2. [Features](#features)
3. [Technologies Used](#technologies-used)
4. [Getting Started](#getting-started)
5. [Installation](#installation)
6. [Usage](#usage)
7. [Localization](#localization)
8. [Theme](#theme)
9. [Admin Features](#admin-features)
10. [Contributing](#contributing)
11. [License](#license)

## Introduction

EnvFriendly is a Flutter-based mobile application designed to promote sustainable living by facilitating easy access to refill stations for various products. This app aims to reduce single-use container waste by connecting users with nearby refill kiosks.

## Features

- **User Authentication**: Secure login and registration system.
- **Kiosk Locator**: Find nearby refill kiosks using geolocation.
- **Product Browsing**: View and search available products for refill.
- **Order Placement**: Easy-to-use interface for placing refill orders.
- **Order History**: Track past orders and refill habits.
- **Multi-language Support**: Available in English and Kannada.
- **Dark Mode**: Toggle between light and dark themes for comfortable viewing.
- **Admin Panel**: Special features for kiosk managers and administrators.
- **Notifications**: Receive updates about orders and nearby kiosks.

## Technologies Used

- Flutter: Cross-platform UI toolkit
- Dart: Programming language
- Firebase: Backend services (Authentication, Firestore, Cloud Functions)
- Provider: State management
- Google Maps API: For kiosk location services
- Flutter Localizations: For multi-language support

## Getting Started

To get started with EnvFriendly, ensure you have the following prerequisites:

- Flutter SDK (latest version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Firebase account for backend services

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/envfriendly.git
   ```

2. Navigate to the project directory:
   ```
   cd envfriendly
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Set up Firebase:
   - Create a new Firebase project
   - Add your Android and iOS apps to the Firebase project
   - Download and place the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) in the respective directories

5. Run the app:
   ```
   flutter run
   ```

## Usage

After installing the app, users can:

1. Register or log in to their account
2. Allow location permissions to find nearby kiosks
3. Browse available products
4. Select a product and specify the refill amount
5. Place an order and receive confirmation
6. View order history and track refill habits
7. Adjust app settings including language and theme

## Localization

EnvFriendly supports English and Kannada. To change the language:

1. Go to the app settings
2. Select 'Language'
3. Choose your preferred language

## Theme

The app supports both light and dark modes. To toggle between themes:

1. Go to the app settings
2. Find the 'Dark Mode' toggle
3. Switch it on or off as per your preference

## Admin Features

For kiosk managers and administrators:

1. Log in with admin credentials
2. Access the Admin Panel
3. Manage kiosk inventory
4. View and process orders
5. Generate reports and analytics

## Contributing

We welcome contributions to EnvFriendly! Please follow these steps:

1. Fork the repository
2. Create a new branch 
3. Commit your changes 
4. Push to the branch 
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

For more information or support, please contact [pbrathmesh@gmail.com].
