import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              TweenAnimationBuilder(
                duration: Duration(seconds: 1),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.biotech,  // Changed to biotech icon to match Biomark theme
                      color: Colors.blue[700],
                      size: 80,
                    ),
                    SizedBox(height: 10),
                    AnimatedTextKit(
                      animatedTexts: [
                        FadeAnimatedText(
                          'BIOMARK',
                          textStyle: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      ],
                      isRepeatingAnimation: false,
                    ),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),



              TweenAnimationBuilder(
                duration: Duration(milliseconds: 800),
                tween: Tween<Offset>(begin: Offset(-30, 0), end: Offset(0, 0)),
                builder: (context, Offset offset, child) {
                  return Transform.translate(
                    offset: offset,
                    child: child,
                  );
                },
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.blue[700]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.blue[700]),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              SizedBox(height: 16),


              TweenAnimationBuilder(
                duration: Duration(milliseconds: 800),
                tween: Tween<Offset>(begin: Offset(30, 0), end: Offset(0, 0)),
                builder: (context, Offset offset, child) {
                  return Transform.translate(
                    offset: offset,
                    child: child,
                  );
                },
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.blue[700]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
                  ),
                  obscureText: true,
                ),
              ),

              SizedBox(height: 24),

              // Animated Login Button
              TweenAnimationBuilder(
                duration: Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                  onPressed: () async {
                    setState(() => isLoading = true);
                    try {
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
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
                ),
              ),

              SizedBox(height: 16),


              TweenAnimationBuilder(
                duration: Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    TextButton(
                      child: Text('Register', style: TextStyle(color: Colors.blue[700])),
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                    ),
                    TextButton(
                      child: Text('Forgot Password?', style: TextStyle(color: Colors.blue[700])),
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}