import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // calendar text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // dial text color
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.blue[700],
              dialHandColor: Colors.blue[700],
              dialBackgroundColor: Colors.blue[50],
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format the time as HH:mm
        birthTimeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Previous build method remains the same until the form fields
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Register', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.app_registration, color: Colors.blue[700], size: 80),
              SizedBox(height: 20),
              _buildTextField('Full Name', fullNameController, Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your full name';
                    return null;
                  }),
              _buildTextField('Email', emailController, Icons.email,
                  keyboardType: TextInputType.emailAddress, validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                      return 'Enter a valid email';
                    return null;
                  }),
              _buildTextField('Password', passwordController, Icons.lock,
                  obscureText: true, validator: (value) {
                    if (value == null || value.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  }),
              _buildDateField(context),
              _buildTimeField(context),
              // Rest of the form fields remain the same
              _buildTextField('Location of Birth', birthLocationController,
                  Icons.location_on),
              _buildTextField(
                  'Blood Group', bloodGroupController, Icons.bloodtype),
              _buildTextField('Sex', sexController, Icons.person_outline),
              _buildTextField('Height', heightController, Icons.height,
                  keyboardType: TextInputType.number),
              _buildTextField(
                  'Ethnicity', ethnicityController, Icons.diversity_3),
              _buildTextField('Eye Color', eyeColorController, Icons.remove_red_eye),
              _buildTextField("Mother's Maiden Name", mothersMaidenNameController,
                  Icons.family_restroom),
              _buildTextField("Childhood Best Friend's Name",
                  childhoodFriendController, Icons.people),
              _buildTextField("Childhood Pet's Name", childhoodPetController,
                  Icons.pets),
              _buildTextField('Your Own Security Question',
                  securityQuestionController, Icons.security),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child:
                Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
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

                    final success =
                    await authService.register(user, passwordController.text);
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

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: dobController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          labelStyle: TextStyle(color: Colors.blue[700]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.calendar_today, color: Colors.blue[700]),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_month, color: Colors.blue[700]),
            onPressed: () => _selectDate(context),
          ),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: birthTimeController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Time of Birth',
          labelStyle: TextStyle(color: Colors.blue[700]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.access_time, color: Colors.blue[700]),
          suffixIcon: IconButton(
            icon: Icon(Icons.schedule, color: Colors.blue[700]),
            onPressed: () => _selectTime(context),
          ),
        ),
        onTap: () => _selectTime(context),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool obscureText = false,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue[700]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: Colors.blue[700]),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}