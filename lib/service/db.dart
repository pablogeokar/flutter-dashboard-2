import 'package:flutter_dashboard_2/models/membro.dart';
import 'package:path/path.dart'; // Para manipulação de caminhos de arquivos
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // SQLite para desktop (Windows, Linux, macOS)

class DB {
  static final DB _instance = DB._internal();
  static Database? _database;

  DB._internal() {
    // Inicializa o sqflite para desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  factory DB() => _instance;

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE membros(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT,
        telefone TEXT,        
        grau TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'ativo',
        observacoes TEXT
      )
    ''');
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'compasso_fiscal.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // CRUD Operations para Membros

  // Inserir um novo membro
  Future<int> insertMembro(Membro membro) async {
    final db = await database;
    return await db.insert('membros', membro.toMap());
  }
}
