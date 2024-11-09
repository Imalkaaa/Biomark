import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import './mongodb_helper.dart';
import './sqlite_helper.dart';
import './encryption_helper.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> init() async {
    // Initialize MongoDB and SQLite
    await MongoDBHelper.instance.initialize();
    await SQLiteHelper.instance.database;
  }

  String _hashPassword(String password, String salt) {
    var bytes = utf8.encode(password + salt);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateSalt() {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));  // Generates a list of 16 random integers
    return base64Url.encode(salt);  // Encodes the list of bytes into a base64 string
  }

  String generateUniqueId() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}'; // Unique ID based on the current timestamp
  }

  Future<bool> register(User user, String password) async {
    try {
      // Generate a unique salt for the user
      final uniqueId = generateUniqueId();
      final salt = _generateSalt();
      final passwordHash = _hashPassword(password, salt);

      // Encrypt sensitive security data for SQLite storage
      final encryptedSecurityData = {
        'fullName': EncryptionHelper.encryptData(user.fullName),
        'dateOfBirth': EncryptionHelper.encryptData(user.dateOfBirth),
        'mothersMaidenName': EncryptionHelper.encryptData(user.mothersMaidenName),
        'childhoodFriend': EncryptionHelper.encryptData(user.childhoodFriend),
        'childhoodPet': EncryptionHelper.encryptData(user.childhoodPet),
        'ownQuestionAnswer': EncryptionHelper.encryptData(user.securityQuestion),
        'email': EncryptionHelper.encryptData(user.email),
      };

      // Insert minimal personal data into MongoDB
      final mongoResult = await MongoDBHelper.instance.insertOne('users', {
        'dataSampleId': uniqueId,
        'dateOfBirth': user.dateOfBirth,
        'timeOfBirth': user.timeOfBirth,
        'locationOfBirth': user.locationOfBirth,
        'bloodGroup': user.bloodGroup,
        'sex': user.sex,
        'height': user.height,
        'ethnicity': user.ethnicity,
        'eyeColor': user.eyeColor,
      });

      if (mongoResult != null && mongoResult.isSuccess) {
        // Store encrypted data in SQLite
        await SQLiteHelper.instance.insert('Users', {
          'id': EncryptionHelper.encryptData(uniqueId),
          'fullName': encryptedSecurityData['fullName'],
          'dateOfBirth': encryptedSecurityData['dateOfBirth'],
          'mothersMaidenName': encryptedSecurityData['mothersMaidenName'],
          'childhoodFriend': encryptedSecurityData['childhoodFriend'],
          'childhoodPet': encryptedSecurityData['childhoodPet'],
          'securityQuestion': encryptedSecurityData['ownQuestionAnswer'],
          'email': encryptedSecurityData['email'],
          'passwordHash': passwordHash,
          'salt': salt,
        });

        // Fetch and print the registered user data from SQLite
        final userData = await SQLiteHelper.instance.query('Users', where: 'email = ?', whereArgs: [encryptedSecurityData['email']]);
        if (userData.isNotEmpty) {
          final storedUserData = userData.first;

          // Decrypt and print all the user data
          print('Registered User Data:');
          print('Full Name: ${EncryptionHelper.decryptData(storedUserData['fullName'] as String)}');
          print('Date of Birth: ${EncryptionHelper.decryptData(storedUserData['dateOfBirth'] as String)}');
          print('Mother\'s Maiden Name: ${EncryptionHelper.decryptData(storedUserData['mothersMaidenName'] as String)}');
          print('Childhood Friend: ${EncryptionHelper.decryptData(storedUserData['childhoodFriend'] as String)}');
          print('Childhood Pet: ${EncryptionHelper.decryptData(storedUserData['childhoodPet'] as String)}');
          print('Security Question Answer: ${EncryptionHelper.decryptData(storedUserData['securityQuestion'] as String)}');
          print('Email: ${EncryptionHelper.decryptData(storedUserData['email'] as String)}');
        }

        _currentUser = user;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }


  Future<bool> login(String email, String password) async {
    try {
      // Fetch user from SQLite (encrypted email)
      final localUser = await SQLiteHelper.instance.query(
          'Users',
          where: 'email = ?',
          whereArgs: [EncryptionHelper.encryptData(email)] // Encrypt email for lookup
      );

      if (localUser.isNotEmpty) {
        final user = localUser.first;

        // Check if passwordHash and salt are non-null
        final passwordHash = user['passwordHash'] as String?;
        final salt = user['salt'] as String?;
        final encryptedId = user['id'] as String?;

        if (passwordHash != null && salt != null && encryptedId != null) {
          // Hash the entered password with the stored salt
          final hashedInputPassword = _hashPassword(password, salt);


          // Validate the password
          if (passwordHash == hashedInputPassword) {
            final uniqueId = EncryptionHelper.decryptData(encryptedId);
            print(uniqueId);
            // Fetch the minimal user data from MongoDB
            final mongoUser = await MongoDBHelper.instance.findOne(
                'users',
                where.eq('dataSampleId', uniqueId)
            );

            print(mongoUser);

            if (mongoUser != null) {
              _currentUser = User.fromJson({
                ...mongoUser,
                ...{
                  'id': user['id'] != null
                      ? EncryptionHelper.decryptData(user['id'])
                      : 'Unknown',
                  'fullName': user['fullName'] != null
                      ? EncryptionHelper.decryptData(user['fullName'])
                      : 'Unknown', // Default for debugging
                  'email': user['email'] != null
                      ? EncryptionHelper.decryptData(user['email'])
                      : 'Unknown',
                  'mothersMaidenName': user['mothersMaidenName'] != null
                      ? EncryptionHelper.decryptData(user['mothersMaidenName'])
                      : 'Unknown',
                  'childhoodFriend': user['childhoodFriend'] != null
                      ? EncryptionHelper.decryptData(user['childhoodFriend'])
                      : 'Unknown',
                  'childhoodPet': user['childhoodPet'] != null
                      ? EncryptionHelper.decryptData(user['childhoodPet'])
                      : 'Unknown',
                  'securityQuestion': user['ownQuestionAnswer'] != null
                      ? EncryptionHelper.decryptData(user['ownQuestionAnswer'])
                      : 'Unknown',
                }
              });  // Reassemble user data
              print(currentUser);
              notifyListeners();
              return true;
            }
          }
        } else {
          print('Login error: missing passwordHash or salt');
        }
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> unsubscribe() async {
    if (_currentUser == null) return false;

    try {
      final userId = _currentUser?.id;
      print(userId);
      if (userId == null) {
        print('Unsubscribe error: User ID is null');
        return false;
      }

      // Delete from MongoDB (minimal personal data)
      final mongoResult = await MongoDBHelper.instance.deleteOne(
          'users',
          where.eq('dataSampleId', userId) // Use MongoDB-stored field for deletion
      );
      print(mongoResult != null && mongoResult.isSuccess);
      if (mongoResult != null && mongoResult.isSuccess) {
        // Delete from SQLite (encrypted email)
        await SQLiteHelper.instance.delete(
            'Users',
            'id = ?',
            [EncryptionHelper.encryptData(userId)]
        );

        _currentUser = null;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Unsubscribe error: $e');
      return false;
    }
  }




  Future<bool> recoverAccount(String fullName, String dateOfBirth, List<String> securityAnswers) async {
    try {
      final user = await MongoDBHelper.instance.findOne('users',
          where.eq('fullName', fullName).eq('dateOfBirth', dateOfBirth));

      if (user != null) {
        final localUser = await SQLiteHelper.instance.query('Users', where: 'id = ?', whereArgs: [user['_id'].toString()]);

        if (localUser.isNotEmpty) {
          final securityData = jsonDecode(localUser.first['securityData'] as String);

          int correctAnswers = 0;
          if (securityAnswers[0] == EncryptionHelper.decryptData(securityData['mothersMaidenName'])) correctAnswers++;
          if (securityAnswers[1] == EncryptionHelper.decryptData(securityData['childhoodFriend'])) correctAnswers++;
          if (securityAnswers[2] == EncryptionHelper.decryptData(securityData['childhoodPet'])) correctAnswers++;
          if (securityAnswers[3] == EncryptionHelper.decryptData(securityData['securityQuestion'])) correctAnswers++;

          if (correctAnswers >= 2) {
            _currentUser = User.fromJson(user);
            notifyListeners();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('Account recovery error: $e');
      return false;
    }
  }




  Future<bool> changeEmail(String newEmail, String password) async {
    try {
      // Validate the new email format
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(newEmail)) {
        print('Invalid email format');
        return false;
      }

      // Check if the current user is logged in
      if (_currentUser == null) {
        print('User is not logged in');
        return false;
      }

      // Encrypt the new email for storage in SQLite
      final encryptedEmail = EncryptionHelper.encryptData(newEmail);

      // Update the SQLite record - Ensure your SQLiteHelper method supports 'where' and 'whereArgs'
      final userId = _currentUser!.id; // Get the user ID
      if (userId != null) { // Ensure user ID is not null
        await SQLiteHelper.instance.update1(
          'Users',
          {'email': encryptedEmail}, // Update the encrypted email
          'id = ?',                  // Where clause
          [EncryptionHelper.encryptData(userId)], // Arguments for the where clause
        );

        // Update the MongoDB record if needed
        await MongoDBHelper.instance.updateOne(
          'users',
          where.eq('dataSampleId', userId), // Locate user by ID in MongoDB
          {'email': newEmail},              // Store plaintext email in MongoDB
        );

        // Update the local instance of the user and notify listeners
        _currentUser!.email = newEmail;
        notifyListeners();

        print('Email changed successfully');
        return true;
      } else {
        print('User ID is null');
        return false;
      }
    } catch (e) {
      print('Error changing email: $e');
      return false;
    }
  }


  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      // Check if the current user is logged in
      if (_currentUser == null) {
        print('User is not logged in');
        return false;
      }

      // Verify the current password
      final isValidPassword = await login(_currentUser!.email, currentPassword);
      if (!isValidPassword) {
        print('Current password is invalid');
        return false;
      }

      // Generate new salt and hash for the new password
      final newSalt = _generateSalt();
      final newPasswordHash = _hashPassword(newPassword, newSalt);

      // Update the SQLite record
      final userId = _currentUser!.id;
      if (userId != null) {
        await SQLiteHelper.instance.update(
          'Users',
          {
            'passwordHash': newPasswordHash,
            'salt': newSalt,
          },
          where: 'id = ?',
          whereArgs: [EncryptionHelper.encryptData(userId)],
        );

        print('Password changed successfully');
        return true;
      } else {
        print('User ID is null');
        return false;
      }
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }


  Future<Map<String, dynamic>> resetPassword(String newPassword) async {
    try {
      // Ensure the user is logged in
      if (_currentUser == null) {
        return {
          'success': false,
          'error': 'No current user exist.'
        };
      }

      // Generate a new salt and hash the new password
      final newSalt = _generateSalt();
      final newHashedPassword = _hashPassword(newPassword, newSalt);

      // Update password in SQLite
      await SQLiteHelper.instance.update1(
          'Users',
          {
            'passwordHash': newHashedPassword,
            'salt': newSalt
          },
          'id = ?',
          [_currentUser!.id != null ? EncryptionHelper.encryptData(_currentUser!.id!) : '']
      );

      // final islogin=login(_currentUser!.email, newPassword);

      // if (islogin == true) {
      //   print("login successful!");
      // }

      return {
        'success': true,
        'error': null
      };
    } catch (e) {
      print('Reset password error: $e');
      return {
        'success': false,
        'error': 'Failed to reset password: ${e.toString()}'
      };
    }
  }


  Future<Map<String, dynamic>> verifySecurityQuestions({
    required String email,
    required String mothersMaidenName,
    required String childhoodFriend,
    required String childhoodPet,
    required String securityQuestion,
  }) async {
    try {
      // First, find the user by encrypted email
      final encryptedEmail = EncryptionHelper.encryptData(email);
      final localUser = await SQLiteHelper.instance.query(
        'Users',
        where: 'email = ?',
        whereArgs: [encryptedEmail],
      );

      if (localUser.isEmpty) {
        return {
          'success': false,
          'errors': {
            'email': 'No account found with this email address'
          }
        };
      }

      final userData = localUser.first;

      // Debugging: print userData to check if anything is missing or null
      print('User Data: $userData');

      // Decrypt stored security answers for comparison
      final storedMothersMaidenName = EncryptionHelper.decryptData(userData['mothersMaidenName'] as String);
      final storedChildhoodFriend = EncryptionHelper.decryptData(userData['childhoodFriend'] as String);
      final storedChildhoodPet = EncryptionHelper.decryptData(userData['childhoodPet'] as String);
      final storedSecurityQuestion = EncryptionHelper.decryptData(userData['securityQuestion'] as String);

      // Debugging: print decrypted answers to check if any are null
      print('Decrypted Mothers Maiden Name: $storedMothersMaidenName');
      print('Decrypted Childhood Friend: $storedChildhoodFriend');
      print('Decrypted Childhood Pet: $storedChildhoodPet');
      print('Decrypted Security Question: $storedSecurityQuestion');

      // Convert all answers to lowercase for case-insensitive comparison
      final normalizedInput = {
        'mothersMaidenName': mothersMaidenName.trim().toLowerCase(),
        'childhoodFriend': childhoodFriend.trim().toLowerCase(),
        'childhoodPet': childhoodPet.trim().toLowerCase(),
        'securityQuestion': securityQuestion.trim().toLowerCase(),
      };

      // Debugging: print normalized input to check if any value is null or empty
      print('Normalized Input: $normalizedInput');

      final normalizedStored = {
        'mothersMaidenName': storedMothersMaidenName.trim().toLowerCase(),
        'childhoodFriend': storedChildhoodFriend.trim().toLowerCase(),
        'childhoodPet': storedChildhoodPet.trim().toLowerCase(),
        'securityQuestion': storedSecurityQuestion.trim().toLowerCase(),
      };

      // Debugging: print normalized stored answers to check if any are null or empty
      print('Normalized Stored: $normalizedStored');

      // Track individual field errors
      Map<String, String> fieldErrors = {};
      int correctAnswers = 0;

      // Check each field individually
      if (normalizedInput['mothersMaidenName'] == normalizedStored['mothersMaidenName']) {
        correctAnswers++;
      } else {
        fieldErrors['mothersMaidenName'] = 'Incorrect answer';
      }

      if (normalizedInput['childhoodFriend'] == normalizedStored['childhoodFriend']) {
        correctAnswers++;
      } else {
        fieldErrors['childhoodFriend'] = 'Incorrect answer';
      }

      if (normalizedInput['childhoodPet'] == normalizedStored['childhoodPet']) {
        correctAnswers++;
      } else {
        fieldErrors['childhoodPet'] = 'Incorrect answer';
      }

      if (normalizedInput['securityQuestion'] == normalizedStored['securityQuestion']) {
        correctAnswers++;
      } else {
        fieldErrors['securityQuestion'] = 'Incorrect answer';
      }

      if (correctAnswers == 4) {
        // Set the current user for the session
        final decryptedId = EncryptionHelper.decryptData(userData['id'] as String);

        // Debugging: check if decryptedId is null
        print('Decrypted ID: $decryptedId');

        // Fetch additional user data from MongoDB
        final mongoUser = await MongoDBHelper.instance.findOne(
            'users',
            where.eq('dataSampleId', decryptedId)
        );

        if (mongoUser != null) {
          _currentUser = User.fromJson({
            ...mongoUser,
            'id': decryptedId,
            'email': email,
            'fullName': EncryptionHelper.decryptData(userData['fullName'] as String),
            'mothersMaidenName': storedMothersMaidenName,
            'childhoodFriend': storedChildhoodFriend,
            'childhoodPet': storedChildhoodPet,
            'securityQuestion': storedSecurityQuestion,
          });

          notifyListeners();
          return {
            'success': true,
            'errors': null
          };
        }
      }

      // Return specific field errors
      return {
        'success': false,
        'errors': fieldErrors.isEmpty ? {
          'general': 'The provided answers do not match our records. Please try again.'
        } : fieldErrors
      };

    } catch (e) {
      print('Security questions verification error: $e');
      return {
        'success': false,
        'errors': {
          'general': 'An error occurred while verifying security questions. Please try again later.'
        }
      };
    }
  }




}
