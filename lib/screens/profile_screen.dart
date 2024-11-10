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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),



      body: user == null
          ? Center(child: CircularProgressIndicator(color: Colors.blue[700]))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[700],
                    child: Text(
                      user.fullName[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue[700]!, width: 2),
                      ),
                      child: Icon(Icons.camera_alt,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
              textAlign: TextAlign.center,
            ),


            SizedBox(height: 16),
            _buildInfoCard('Full Name', user.fullName, Icons.person),
            _buildInfoCard('Email', user.email, Icons.email),
            _buildInfoCard('Date of Birth', user.dateOfBirth, Icons.calendar_today),
            _buildInfoCard('Time of Birth', user.timeOfBirth, Icons.access_time),
            _buildInfoCard('Location of Birth', user.locationOfBirth, Icons.location_on),
            _buildInfoCard('Blood Group', user.bloodGroup, Icons.bloodtype),
            _buildInfoCard('Sex', user.sex, Icons.person_outline),
            _buildInfoCard('Height', user.height, Icons.height),
            _buildInfoCard('Ethnicity', user.ethnicity, Icons.diversity_3),
            _buildInfoCard('Eye Color', user.eyeColor, Icons.remove_red_eye),


            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.email, color: Colors.white),
              label: Text('Change Email',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/change-email');
              },
            ),


            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.lock, color: Colors.white),
              label: Text('Change Password',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),



              onPressed: () {
                Navigator.pushNamed(context, '/change-password');
              },
            ),


            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.no_accounts, color: Colors.white),
              label: Text('Unsubscribe',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),



              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirm Unsubscribe'),
                    content: Text(
                        'Are you sure you want to unsubscribe? This action cannot be undone.'),
                    actions: [
                      TextButton.icon(
                        icon: Icon(Icons.cancel, color: Colors.grey),
                        label: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.delete_forever, color: Colors.red[600]),
                        label: Text('Unsubscribe',
                            style: TextStyle(color: Colors.red[600])),
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




  Widget _buildInfoCard(String title, String content, IconData icon) {


    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),


      child: ListTile(
        leading: Icon(icon, color: Colors.blue[700], size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),


        subtitle: Text(
          content,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}