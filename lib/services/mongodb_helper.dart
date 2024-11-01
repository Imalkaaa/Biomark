import 'package:mongo_dart/mongo_dart.dart';

class MongoDBHelper {
  static final MongoDBHelper instance = MongoDBHelper._init();
  Db? _db;
  bool _isInitialized = false;

  MongoDBHelper._init();

  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        // MongoDB URI with TLS/SSL enabled
        final uri = 'mongodb+srv://sankalpa5285:m2bhv447MvO8b05L@sricare.nwmoh.mongodb.net/Biomark';

        _db = await Db.create(uri);

        await _db!.open();
        _isInitialized = true;
        print("MongoDB connection initialized");
      } catch (e) {
        print('MongoDB initialization error: $e');
        _db = null;
      }
    }
  }

  Future<Db?> get database async {
    if (!_isInitialized) {
      await initialize();
    }
    return _db;
  }

  Future<WriteResult?> insertOne(String collection, Map<String, dynamic> document) async {
    try {
      final db = await database;
      if (db == null) return null;
      final result = await db.collection(collection).insertOne(document);
      print('Insert result: $result');
      print('Insert success: ${result.isSuccess}');
      print('Insert document: ${result.document}');
      print('Insert error: ${result.writeError}');
      print('Insert error: ${result.writeError?.code}, ${result.writeError?.errmsg}');
      return result;
    } catch (e, stackTrace) {
      print('MongoDB insertOne error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }


  Future<Map<String, dynamic>?> findOne(String collection, SelectorBuilder selector) async {
    final db = await database;
    if (db == null) return null;
    return await db.collection(collection).findOne(selector);
  }

  Future<WriteResult?> deleteOne(String collection, SelectorBuilder selector) async {
    final db = await database;
    if (db == null) return null;
    return await db.collection(collection).deleteOne(selector);
  }
}