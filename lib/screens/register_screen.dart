import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController birthTimeController = TextEditingController();
  final TextEditingController birthLocationController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ethnicityController = TextEditingController();
  final TextEditingController eyeColorController = TextEditingController();
  final TextEditingController mothersMaidenNameController = TextEditingController();
  final TextEditingController childhoodFriendController = TextEditingController();
  final TextEditingController childhoodPetController = TextEditingController();
  final TextEditingController securityQuestionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Register', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Full Name', fullNameController, validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your full name';
                return null;
              }),
              _buildTextField('Email', emailController, keyboardType: TextInputType.emailAddress, validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                return null;
              }),
              _buildTextField('Password', passwordController, obscureText: true, validator: (value) {
                if (value == null || value.length < 6) return 'Password must be at least 6 characters';
                return null;
              }),
              _buildTextField('Date of Birth', dobController),
              _buildTextField('Time of Birth', birthTimeController),
              _buildTextField('Location of Birth', birthLocationController),
              _buildTextField('Blood Group', bloodGroupController),
              _buildTextField('Sex', sexController),
              _buildTextField('Height', heightController, keyboardType: TextInputType.number),
              _buildTextField('Ethnicity', ethnicityController),
              _buildTextField('Eye Color', eyeColorController),
              _buildTextField("Mother's Maiden Name", mothersMaidenNameController),
              _buildTextField("Childhood Best Friend's Name", childhoodFriendController),
              _buildTextField("Childhood Pet's Name", childhoodPetController),
              _buildTextField('Your Own Security Question', securityQuestionController),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final user = User(
                      fullName: fullNameController.text,
                      email: emailController.text,
                      dateOfBirth: dobController.text,
                      timeOfBirth: birthTimeController.text,
                      locationOfBirth: birthLocationController.text,
                      bloodGroup: bloodGroupController.text,
                      sex: sexController.text,
                      height: heightController.text,
                      ethnicity: ethnicityController.text,
                      eyeColor: eyeColorController.text,
                      mothersMaidenName: mothersMaidenNameController.text,
                      childhoodFriend: childhoodFriendController.text,
                      childhoodPet: childhoodPetController.text,
                      securityQuestion: securityQuestionController.text,
                    );

                    final success = await authService.register(user, passwordController.text);
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/profile');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registration failed')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
