// import 'package:flutter_dashboard_2/models/membro.dart';
// import 'package:path/path.dart'; // Para manipulação de caminhos de arquivos
// import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // SQLite para desktop (Windows, Linux, macOS)

// class DB {
//   static final DB _instance = DB._internal();
//   static Database? _database;

//   DB._internal() {
//     // Inicializa o sqflite para desktop
//     sqfliteFfiInit();
//     databaseFactory = databaseFactoryFfi;
//   }

//   factory DB() => _instance;

//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE membros(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         nome TEXT NOT NULL,
//         email TEXT,
//         telefone TEXT,
//         status TEXT NOT NULL DEFAULT 'ativo',
//         observacoes TEXT
//       )
//     ''');
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'compasso_fiscal.db');
//     return await openDatabase(path, version: 1, onCreate: _onCreate);
//   }

//   Future<Database> get database async {
//     _database ??= await _initDatabase();
//     return _database!;
//   }

//   // CRUD Operations para Membros

//   // Inserir um novo membro
//   Future<int> insertMembro(Membro membro) async {
//     final db = await database;
//     return await db.insert('membros', membro.toMap());
//   }
// }
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

  /// Inserir um novo membro
  Future<int> insertMembro(Membro membro) async {
    final db = await database;
    return await db.insert('membros', membro.toMap());
  }

  /// Buscar todos os membros
  Future<List<Membro>> getMembros() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      orderBy: 'nome ASC', // Ordena por nome alfabeticamente
    );

    return List.generate(maps.length, (i) {
      return Membro.fromMap(maps[i]);
    });
  }

  /// Buscar um membro específico por ID
  Future<Membro?> getMembroById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Membro.fromMap(maps.first);
    }
    return null;
  }

  /// Buscar membros por status
  Future<List<Membro>> getMembrosByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) {
      return Membro.fromMap(maps[i]);
    });
  }

  /// Buscar membros por nome (busca parcial)
  Future<List<Membro>> getMembrosByNome(String nome) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      where: 'nome LIKE ?',
      whereArgs: ['%$nome%'],
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) {
      return Membro.fromMap(maps[i]);
    });
  }

  /// Atualizar um membro existente
  Future<int> updateMembro(Membro membro) async {
    final db = await database;

    if (membro.id == null) {
      throw Exception('ID do membro não pode ser nulo para atualização');
    }

    return await db.update(
      'membros',
      membro.toMap(),
      where: 'id = ?',
      whereArgs: [membro.id],
    );
  }

  /// Deletar um membro por ID
  Future<int> deleteMembro(int id) async {
    final db = await database;
    return await db.delete('membros', where: 'id = ?', whereArgs: [id]);
  }

  /// Contar total de membros
  Future<int> contarMembros() async {
    final db = await database;
    var result = await db.rawQuery('SELECT COUNT(*) as count FROM membros');
    return result.first['count'] as int? ?? 0;
  }

  /// Contar membros por status
  Future<Map<String, int>> contarMembrosPorStatus() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM membros 
      GROUP BY status
    ''');

    Map<String, int> contador = {};
    for (var row in result) {
      contador[row['status']] = row['count'];
    }
    return contador;
  }

  /// Verificar se existe algum membro com o email informado (útil para validação)
  Future<bool> existeEmailMembro(String email, {int? excluirId}) async {
    final db = await database;

    String where = 'email = ?';
    List<dynamic> whereArgs = [email];

    // Se estiver editando, excluir o próprio registro da verificação
    if (excluirId != null) {
      where += ' AND id != ?';
      whereArgs.add(excluirId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  /// Limpar todas as tabelas (útil para testes ou reset)
  Future<void> limparDados() async {
    final db = await database;
    await db.delete('membros');
  }

  /// Fechar a conexão com o banco (opcional)
  Future<void> fecharDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
