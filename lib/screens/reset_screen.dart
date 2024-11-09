import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/profile_screen.dart'; // Import the home screen

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _isLoading = false;
  bool _isFormValid = false;
  bool _isPasswordChangeSuccessful = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // Password requirements: at least 8 characters, 1 uppercase, 1 number
      final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');

      bool isNewPasswordValid = passwordRegex.hasMatch(_newPasswordController.text);
      bool doPasswordsMatch = _newPasswordController.text == _confirmPasswordController.text;

      _newPasswordError = !isNewPasswordValid && _newPasswordController.text.isNotEmpty
          ? 'Password must be at least 8 characters with 1 uppercase letter and 1 number'
          : null;

      _confirmPasswordError = !doPasswordsMatch && _confirmPasswordController.text.isNotEmpty
          ? 'Passwords do not match'
          : null;

      _isFormValid = isNewPasswordValid &&
          doPasswordsMatch;
    });
  }

  Widget _buildErrorText(String? error) {
    if (error == null || error.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(left: 12, top: 6),
      child: Text(
        error,
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: errorText != null
                ? Border.all(color: Colors.red.shade300, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(
                icon ?? Icons.lock_outline,
                color: errorText != null ? Colors.red.shade300 : null,
              ),
              labelStyle: TextStyle(
                color: errorText != null ? Colors.red.shade300 : null,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
        _buildErrorText(errorText),
        SizedBox(height: 16),
      ],
    );
  }

  void _handlePasswordChange() async {
    if (_formKey.currentState!.validate() && _isFormValid) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await Provider.of<AuthService>(context, listen: false)
            .resetPassword(_newPasswordController.text);
        if (result['success']) {
          setState(() {
            _isPasswordChangeSuccessful = true;
          });
          // Show success message for 2 seconds and then redirect
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          });
        } else {
          setState(() {
            _newPasswordError = result['error'];
          });
        }
      } catch (error) {
        setState(() {
          _newPasswordError = error.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isPasswordChangeSuccessful)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Password changed successfully!',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      icon: Icons.lock_outline,
                      errorText: _newPasswordError,
                    ),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      icon: Icons.lock_outline,
                      errorText: _confirmPasswordError,
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          disabledBackgroundColor: Colors.grey[400],
                          disabledForegroundColor: Colors.grey[300],
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: (_isLoading || !_isFormValid)
                            ? null
                            : _handlePasswordChange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}