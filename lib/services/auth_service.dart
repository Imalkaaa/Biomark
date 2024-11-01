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
      print('1');
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
      print('2');
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
      print('3');
      print(mongoResult != null);
      print(mongoResult?.isSuccess);
      print(mongoResult?.id.toString());

      // Store encrypted data in SQLite
      if (mongoResult != null && mongoResult.isSuccess) {
        await SQLiteHelper.instance.insert('Users', {
          'id': EncryptionHelper.encryptData(uniqueId),
          'fullName': encryptedSecurityData['fullName'],
          'dateOfBirth': encryptedSecurityData['dateOfBirth'],
          'mothersMaidenName': encryptedSecurityData['mothersMaidenName'],
          'childhoodFriend': encryptedSecurityData['childhoodFriend'],
          'childhoodPet': encryptedSecurityData['childhoodPet'],
          'securityQuestion': encryptedSecurityData['securityQuestion'],
          'email': encryptedSecurityData['email'],
          'passwordHash': passwordHash,
          'salt': salt,
        });
        print('4');
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

}
