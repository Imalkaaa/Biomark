import 'package:biomark/screens/reset_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class forgotScreen extends StatefulWidget {
  @override
  _AccountRecoveryScreenState createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends State<forgotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController(); // Added full name controller
  final _mothersMaidenNameController = TextEditingController();
  final _childhoodFriendController = TextEditingController();
  final _childhoodPetController = TextEditingController();
  final _securityQuestionController = TextEditingController();

  String? _emailError;
  String? _fullNameError; // Added full name error
  String? _mothersMaidenNameError;
  String? _childhoodFriendError;
  String? _childhoodPetError;
  String? _securityQuestionError;

  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _fullNameController.addListener(_validateForm); // Added full name listener
    _mothersMaidenNameController.addListener(_validateForm);
    _childhoodFriendController.addListener(_validateForm);
    _childhoodPetController.addListener(_validateForm);
    _securityQuestionController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _fullNameController.removeListener(_validateForm); // Added full name dispose
    _mothersMaidenNameController.removeListener(_validateForm);
    _childhoodFriendController.removeListener(_validateForm);
    _childhoodPetController.removeListener(_validateForm);
    _securityQuestionController.removeListener(_validateForm);

    _emailController.dispose();
    _fullNameController.dispose(); // Added full name dispose
    _mothersMaidenNameController.dispose();
    _childhoodFriendController.dispose();
    _childhoodPetController.dispose();
    _securityQuestionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // Email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      bool isEmailValid = emailRegex.hasMatch(_emailController.text);

      _emailError = !isEmailValid && _emailController.text.isNotEmpty
          ? 'Please enter a valid email address'
          : null;

      // Full name validation
      bool isFullNameValid = _fullNameController.text.trim().split(' ').length >= 2;
      _fullNameError = !isFullNameValid && _fullNameController.text.isNotEmpty
          ? 'Please enter your full name (first & last name)'
          : null;

      // All fields should be non-empty for the form to be valid
      _isFormValid = isEmailValid &&
          isFullNameValid &&
          _mothersMaidenNameController.text.isNotEmpty &&
          _childhoodFriendController.text.isNotEmpty &&
          _childhoodPetController.text.isNotEmpty &&
          _securityQuestionController.text.isNotEmpty;
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? errorText,
    TextInputType? keyboardType,
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
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(
                icon ?? Icons.lock_outline,
                color: errorText != null ? Colors.red.shade300 : Colors.blue,
              ),
              labelStyle: TextStyle(
                color: errorText != null ? Colors.red.shade300 : Colors.blue,
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

  void _handleRecovery() async {
    if (_formKey.currentState!.validate() && _isFormValid) {
      setState(() {
        _isLoading = true;
        // Reset all error states
        _emailError = null;
        _fullNameError = null; // Added full name error reset
        _mothersMaidenNameError = null;
        _childhoodFriendError = null;
        _childhoodPetError = null;
        _securityQuestionError = null;
      });

      try {
        final result = await Provider.of<AuthService>(context, listen: false)
            .verifySecurityQuestions(
          email: _emailController.text,
          fullName: _fullNameController.text, // Added full name to verification
          mothersMaidenName: _mothersMaidenNameController.text,
          childhoodFriend: _childhoodFriendController.text,
          childhoodPet: _childhoodPetController.text,
          securityQuestion: _securityQuestionController.text,
        );

        if (result['success']) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
          );
        } else {
          setState(() {
            if (result['errors'] != null) {
              final errors = result['errors'] as Map<String, dynamic>;

              _emailError = errors['email'];
              _fullNameError = errors['fullName']; // Added full name error handling
              _mothersMaidenNameError = errors['mothersMaidenName'];
              _childhoodFriendError = errors['childhoodFriend'];
              _childhoodPetError = errors['childhoodPet'];
              _securityQuestionError = errors['securityQuestion'];

              if (errors['general'] != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errors['general']),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          });
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account Recovery',
          style: TextStyle(
            color: Colors.blue[800],
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
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Recovery Steps:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '1. Enter your email address and full name\n'
                                '2. Answer all security questions\n'
                                '3. If answers match, you\'ll be redirected to reset your password',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    _buildInputField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    _buildInputField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      errorText: _fullNameError,
                      keyboardType: TextInputType.name,
                    ),

                    Text(
                      'Security Questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildInputField(
                      controller: _mothersMaidenNameController,
                      label: "Mother's Maiden Name",
                      icon: Icons.family_restroom,
                      errorText: _mothersMaidenNameError,
                    ),

                    _buildInputField(
                      controller: _childhoodFriendController,
                      label: "Childhood Best Friend's Name",
                      icon: Icons.group_outlined,
                      errorText: _childhoodFriendError,
                    ),

                    _buildInputField(
                      controller: _childhoodPetController,
                      label: "Childhood Pet's Name",
                      icon: Icons.pets,
                      errorText: _childhoodPetError,
                    ),

                    _buildInputField(
                      controller: _securityQuestionController,
                      label: 'What is your favourite car',
                      icon: Icons.directions_car,
                      errorText: _securityQuestionError,
                    ),

                    SizedBox(height: 32),

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          disabledBackgroundColor: Colors.blue[200],
                          disabledForegroundColor: Colors.blue[100],
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Verify & Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: (_isLoading || !_isFormValid)
                            ? null
                            : _handleRecovery,
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