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
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(salt);
  }

  String generateUniqueId() {
    final now = DateTime.now();  return '${now.millisecondsSinceEpoch}';
  }



  Future<bool> register(User user, String password) async {
    try {



      final uniqueId = generateUniqueId();
      final salt = _generateSalt();
      final passwordHash = _hashPassword(password, salt);



      final encryptedSecurityData = {
        'fullName': EncryptionHelper.encryptData(user.fullName),
        'dateOfBirth': EncryptionHelper.encryptData(user.dateOfBirth),
        'mothersMaidenName': EncryptionHelper.encryptData(user.mothersMaidenName),
        'childhoodFriend': EncryptionHelper.encryptData(user.childhoodFriend),
        'childhoodPet': EncryptionHelper.encryptData(user.childhoodPet),
        'ownQuestionAnswer': EncryptionHelper.encryptData(user.securityQuestion),
        'email': EncryptionHelper.encryptData(user.email),
      };



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




        final userData = await SQLiteHelper.instance.query('Users', where: 'email = ?', whereArgs: [encryptedSecurityData['email']]);
        if (userData.isNotEmpty) {
          final storedUserData = userData.first;




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



      final localUser = await SQLiteHelper.instance.query(
          'Users',
          where: 'email = ?',
          whereArgs: [EncryptionHelper.encryptData(email)] // Encrypt email for lookup
      );

      if (localUser.isNotEmpty) {
        final user = localUser.first;



        final passwordHash = user['passwordHash'] as String?;
        final salt = user['salt'] as String?;
        final encryptedId = user['id'] as String?;

        if (passwordHash != null && salt != null && encryptedId != null) {


          final hashedInputPassword = _hashPassword(password, salt);


          if (passwordHash == hashedInputPassword) {
            final uniqueId = EncryptionHelper.decryptData(encryptedId);
            print(uniqueId);


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
              });


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



      final mongoResult = await MongoDBHelper.instance.deleteOne(
          'users',
          where.eq('dataSampleId', userId)
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




  Future<bool> changeEmail(String newEmail) async {
    try {


      print('Current user ID: ${_currentUser?.id}');



      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(newEmail)) {
        print('Invalid email format');
        return false;
      }



      if (_currentUser?.id == null) {
        print('User is not logged in or has invalid ID');
        return false;
      }


      final String userId = _currentUser!.id!;



      final encryptedEmail = EncryptionHelper.encryptData(newEmail);
      final encryptedUserId = EncryptionHelper.encryptData(userId);



      await SQLiteHelper.instance.update1(
        'Users',
        {'email': encryptedEmail},
        'id = ?',
        [encryptedUserId],
      );



      await MongoDBHelper.instance.updateOne(
        'users',
        where.eq('dataSampleId', userId),
        {'\$set': {'email': newEmail}},
      );



      _currentUser!.email = newEmail;
      notifyListeners();

      print('Email changed successfully');
      return true;

    } catch (e) {
      print('Error changing email: $e');
      return false;
    }
  }




  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {


      if (_currentUser == null) {
        print('User is not logged in');
        return false;
      }



      final isValidPassword = await login(_currentUser!.email, currentPassword);
      if (!isValidPassword) {
        print('Current password is invalid');
        return false;
      }



      final newSalt = _generateSalt();
      final newPasswordHash = _hashPassword(newPassword, newSalt);



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


      if (_currentUser == null) {
        return {
          'success': false,
          'error': 'No current user exist.'
        };
      }



      final newSalt = _generateSalt();
      final newHashedPassword = _hashPassword(newPassword, newSalt);



      await SQLiteHelper.instance.update1(
          'Users',
          {
            'passwordHash': newHashedPassword,
            'salt': newSalt
          },
          'id = ?',
          [_currentUser!.id != null ? EncryptionHelper.encryptData(_currentUser!.id!) : '']
      );



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
    required String fullName,
    required String mothersMaidenName,
    required String childhoodFriend,
    required String childhoodPet,
    required String securityQuestion,
  }) async {
    try {


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


      print('User Data: $userData');




      final storedFullName = EncryptionHelper.decryptData(userData['fullName'] as String);
      final storedMothersMaidenName = EncryptionHelper.decryptData(userData['mothersMaidenName'] as String);
      final storedChildhoodFriend = EncryptionHelper.decryptData(userData['childhoodFriend'] as String);
      final storedChildhoodPet = EncryptionHelper.decryptData(userData['childhoodPet'] as String);
      final storedSecurityQuestion = EncryptionHelper.decryptData(userData['securityQuestion'] as String);



      print('Decrypted Full Name: $storedFullName');
      print('Decrypted Mothers Maiden Name: $storedMothersMaidenName');
      print('Decrypted Childhood Friend: $storedChildhoodFriend');
      print('Decrypted Childhood Pet: $storedChildhoodPet');
      print('Decrypted Security Question: $storedSecurityQuestion');




      final normalizedInput = {
        'fullName': fullName.trim().toLowerCase(),
        'mothersMaidenName': mothersMaidenName.trim().toLowerCase(),
        'childhoodFriend': childhoodFriend.trim().toLowerCase(),
        'childhoodPet': childhoodPet.trim().toLowerCase(),
        'securityQuestion': securityQuestion.trim().toLowerCase(),
      };




      print('Normalized Input: $normalizedInput');

      final normalizedStored = {
        'fullName': storedFullName.trim().toLowerCase(),
        'mothersMaidenName': storedMothersMaidenName.trim().toLowerCase(),
        'childhoodFriend': storedChildhoodFriend.trim().toLowerCase(),
        'childhoodPet': storedChildhoodPet.trim().toLowerCase(),
        'securityQuestion': storedSecurityQuestion.trim().toLowerCase(),
      };



      print('Normalized Stored: $normalizedStored');



      Map<String, String> fieldErrors = {};
      int correctAnswers = 0;


      if (normalizedInput['fullName'] == normalizedStored['fullName']) {
        correctAnswers++;
      } else {
        fieldErrors['fullName'] = 'Incorrect full name';
      }

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

      if (correctAnswers == 5) {


        final decryptedId = EncryptionHelper.decryptData(userData['id'] as String);


        print('Decrypted ID: $decryptedId');


        final mongoUser = await MongoDBHelper.instance.findOne(
            'users',
            where.eq('dataSampleId', decryptedId)
        );

        if (mongoUser != null) {
          _currentUser = User.fromJson({
            ...mongoUser,
            'id': decryptedId,
            'email': email,
            'fullName': storedFullName,
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
