import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/qr_item.dart';

class DBService {
  static final DBService _instance = DBService._();
  static Database? _database;

  DBService._();

  factory DBService() => _instance;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'qr_history.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
  CREATE TABLE qr_items(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT,
    type TEXT,
    folder TEXT,
    createdAt TEXT
  )
''');

      },
    );
  }

  Future<void> insertQR(QRItem item) async {
    final db = await database;
    await db.insert('qr_items', item.toMap());
  }

  Future<List<QRItem>> getAllQR() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('qr_items', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => QRItem.fromMap(maps[i]));
  }

  Future<void> deleteAllQR() async {
    final db = await database;
    await db.delete('qr_items');
  }
  Future<List<QRItem>> getQRByFolder(String folder) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'qr_items',
      where: 'folder = ?',
      whereArgs: [folder],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => QRItem.fromMap(maps[i]));
  }
}
