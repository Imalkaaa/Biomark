import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Full Name: ${user.fullName}'),
            Text('Email: ${user.email}'),
            Text('Date of Birth: ${user.dateOfBirth}'),
            Text('Time of Birth: ${user.timeOfBirth}'),
            Text('Location of Birth: ${user.locationOfBirth}'),
            Text('Blood Group: ${user.bloodGroup}'),
            Text('Sex: ${user.sex}'),
            Text('Height: ${user.height}'),
            Text('Ethnicity: ${user.ethnicity}'),
            Text('Eye Color: ${user.eyeColor}'),
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('Update Profile'),
              onPressed: () {
                // Implement profile update functionality
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Unsubscribe'),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirm Unsubscribe'),
                    content: Text('Are you sure you want to unsubscribe? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: Text('Unsubscribe'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await authService.unsubscribe();
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}