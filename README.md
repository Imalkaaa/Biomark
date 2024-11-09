# Biomark Flutter Registration Screen

The **Biomark** Flutter project is a registration screen that collects personal and security-related information from users. The form includes various fields for user data, including full name, email, birth details, blood group, and more. It also includes fields for security questions to enhance account recovery and security.

This project uses Flutter and provides a clean, simple interface for users to enter their information and register. Validation checks are performed on the input fields to ensure that all required data is provided in the correct format.

## Features

- **User Registration**: Users can fill in their full name, email, birth details, blood group, sex, ethnicity, and other personal information.
- **Security Questions**: Users can set up answers to security questions to help with account recovery.
- **Form Validation**: Ensures that all necessary fields are filled out before the user can proceed.
- **Responsive Design**: The app adapts to various screen sizes and provides a user-friendly interface.

## Technologies Used

- **Flutter**: A framework for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **Provider**: A state management solution for Flutter that helps with managing app data and dependencies.
- **Dart**: The programming language used to write Flutter apps.
- **Material Design**: Flutter's design system, providing UI components like text fields, buttons, and forms.

## Project Structure

biomark_flutter/
├── android/
├── ios/
├── lib/
│   ├── models/
│   │   └── user.dart
│   ├── screens/
│   │   └── register_screen.dart
│   ├── services/
│   │   └── auth_service.dart
│   ├── main.dart
├── pubspec.yaml
├── README.md
└── .gitignore



## Installation

To get started with the Biomark registration screen, follow these steps:

### Prerequisites
1. Ensure that you have [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.
2. Set up your IDE to support Flutter development (e.g., VS Code or Android Studio).

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/biomark_flutter.git


2.Navigate to the project directory:

cd biomark_flutter


2.Install dependencies:

flutter pub get

3.Run the app:

flutter run
