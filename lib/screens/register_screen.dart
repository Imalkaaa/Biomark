import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class RegisterScreen extends StatelessWidget {
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
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: dobController,
              decoration: InputDecoration(labelText: 'Date of Birth'),
            ),
            TextField(
              controller: birthTimeController,
              decoration: InputDecoration(labelText: 'Time of Birth'),
            ),
            TextField(
              controller: birthLocationController,
              decoration: InputDecoration(labelText: 'Location of Birth'),
            ),
            TextField(
              controller: bloodGroupController,
              decoration: InputDecoration(labelText: 'Blood Group'),
            ),
            TextField(
              controller: sexController,
              decoration: InputDecoration(labelText: 'Sex'),
            ),
            TextField(
              controller: heightController,
              decoration: InputDecoration(labelText: 'Height'),
            ),
            TextField(
              controller: ethnicityController,
              decoration: InputDecoration(labelText: 'Ethnicity'),
            ),
            TextField(
              controller: eyeColorController,
              decoration: InputDecoration(labelText: 'Eye Color'),
            ),
            TextField(
              controller: mothersMaidenNameController,
              decoration: InputDecoration(labelText: "Mother's Maiden Name"),
            ),
            TextField(
              controller: childhoodFriendController,
              decoration: InputDecoration(labelText: "Childhood Best Friend's Name"),
            ),
            TextField(
              controller: childhoodPetController,
              decoration: InputDecoration(labelText: "Childhood Pet's Name"),
            ),
            TextField(
              controller: securityQuestionController,
              decoration: InputDecoration(labelText: 'Your Own Security Question'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('Register'),
              onPressed: () async {
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
              },
            ),
          ],
        ),
      ),
    );
  }
}