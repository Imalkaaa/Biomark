import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.blue[50], // Changed to light blue background
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700], // Darker blue for app bar
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, color: Colors.blue[700], size: 100), // Darker blue icon
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.blue[700]), // Darker blue label
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.blue[700]), // Darker blue icon
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.blue[700]), // Darker blue label
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.blue[700]), // Darker blue icon
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700], // Darker blue button
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                onPressed: () async {
                  final success = await authService.login(
                    emailController.text,
                    passwordController.text,
                  );
                  if (success) {
                    Navigator.pushReplacementNamed(context, '/profile');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login failed')),
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              TextButton(
                child: Text('Register', style: TextStyle(color: Colors.blue[700])), // Darker blue text
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
              TextButton(
                child: Text('Forgot Password?', style: TextStyle(color: Colors.blue[700])), // Darker blue text
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}