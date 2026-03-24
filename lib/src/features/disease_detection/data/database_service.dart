import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:krishi_sahayak/src/features/disease_detection/domain/disease_report.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('krishi_sahayak.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Incremented version to handle schema change
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE reports ADD COLUMN pesticide TEXT');
          await db.execute('ALTER TABLE reports ADD COLUMN shopUrl TEXT');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        diseaseName TEXT,
        confidence TEXT,
        treatment TEXT,
        pesticide TEXT,
        shopUrl TEXT,
        date TEXT,
        imageUrl TEXT
      )
    ''');
  }

  Future<void> saveReport(DiseaseReport report) async {
    final db = await database;
    await db.insert('reports', report.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DiseaseReport>> getReports() async {
    final db = await database;
    final result = await db.query('reports', orderBy: 'date DESC');

    return result.map((json) => DiseaseReport(
      id: json['id'] as String,
      diseaseName: json['diseaseName'] as String,
      confidence: json['confidence'] as String,
      treatment: json['treatment'] as String,
      pesticide: json['pesticide'] as String?,
      shopUrl: json['shopUrl'] as String?,
      date: json['date'] as String,
      imageUrl: json['imageUrl'] as String?,
    )).toList();
  }
}
