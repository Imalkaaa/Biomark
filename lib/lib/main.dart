import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/password_screen.dart';
import 'screens/email_screen.dart';
import 'screens/forgot_screen.dart';
import 'screens/reset_screen.dart';


import 'services/auth_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biomark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/profile': (context) => ProfileScreen(),
        '/change-email' : (context) => ChangeEmailScreen(),
        '/change-password' : (context) => ChangePasswordScreen(),
        '/forgot' : (context) => forgotScreen(),
        '/reset-password': (context) => ResetPasswordScreen(),
      },
    );
  }
}