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

//   /// Inserir um novo membro
//   Future<int> insertMembro(Membro membro) async {
//     final db = await database;
//     return await db.insert('membros', membro.toMap());
//   }

//   /// Buscar todos os membros
//   Future<List<Membro>> getMembros() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'membros',
//       orderBy: 'nome ASC', // Ordena por nome alfabeticamente
//     );

//     return List.generate(maps.length, (i) {
//       return Membro.fromMap(maps[i]);
//     });
//   }

//   /// Buscar um membro específico por ID
//   Future<Membro?> getMembroById(int id) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'membros',
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (maps.isNotEmpty) {
//       return Membro.fromMap(maps.first);
//     }
//     return null;
//   }

//   /// Buscar membros por status
//   Future<List<Membro>> getMembrosByStatus(String status) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'membros',
//       where: 'status = ?',
//       whereArgs: [status],
//       orderBy: 'nome ASC',
//     );

//     return List.generate(maps.length, (i) {
//       return Membro.fromMap(maps[i]);
//     });
//   }

//   /// Buscar membros por nome (busca parcial)
//   Future<List<Membro>> getMembrosByNome(String nome) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'membros',
//       where: 'nome LIKE ?',
//       whereArgs: ['%$nome%'],
//       orderBy: 'nome ASC',
//     );

//     return List.generate(maps.length, (i) {
//       return Membro.fromMap(maps[i]);
//     });
//   }

//   /// Atualizar um membro existente
//   Future<int> updateMembro(Membro membro) async {
//     final db = await database;

//     if (membro.id == null) {
//       throw Exception('ID do membro não pode ser nulo para atualização');
//     }

//     return await db.update(
//       'membros',
//       membro.toMap(),
//       where: 'id = ?',
//       whereArgs: [membro.id],
//     );
//   }

//   /// Deletar um membro por ID
//   Future<int> deleteMembro(int id) async {
//     final db = await database;
//     return await db.delete('membros', where: 'id = ?', whereArgs: [id]);
//   }

//   /// Contar total de membros
//   Future<int> contarMembros() async {
//     final db = await database;
//     var result = await db.rawQuery('SELECT COUNT(*) as count FROM membros');
//     return result.first['count'] as int? ?? 0;
//   }

//   /// Contar membros por status
//   Future<Map<String, int>> contarMembrosPorStatus() async {
//     final db = await database;
//     final List<Map<String, dynamic>> result = await db.rawQuery('''
//       SELECT status, COUNT(*) as count
//       FROM membros
//       GROUP BY status
//     ''');

//     Map<String, int> contador = {};
//     for (var row in result) {
//       contador[row['status']] = row['count'];
//     }
//     return contador;
//   }

//   /// Verificar se existe algum membro com o email informado (útil para validação)
//   Future<bool> existeEmailMembro(String email, {int? excluirId}) async {
//     final db = await database;

//     String where = 'email = ?';
//     List<dynamic> whereArgs = [email];

//     // Se estiver editando, excluir o próprio registro da verificação
//     if (excluirId != null) {
//       where += ' AND id != ?';
//       whereArgs.add(excluirId);
//     }

//     final List<Map<String, dynamic>> maps = await db.query(
//       'membros',
//       where: where,
//       whereArgs: whereArgs,
//       limit: 1,
//     );

//     return maps.isNotEmpty;
//   }

//   /// Limpar todas as tabelas (útil para testes ou reset)
//   Future<void> limparDados() async {
//     final db = await database;
//     await db.delete('membros');
//   }

//   /// Fechar a conexão com o banco (opcional)
//   Future<void> fecharDatabase() async {
//     if (_database != null) {
//       await _database!.close();
//       _database = null;
//     }
//   }
// }

import 'package:flutter_dashboard_2/models/membro.dart';
import 'package:flutter_dashboard_2/models/configuracao.dart';
import 'package:flutter_dashboard_2/models/contribuicao.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DB {
  static final DB _instance = DB._internal();
  static Database? _database;

  DB._internal() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  factory DB() => _instance;

  Future<void> _onCreate(Database db, int version) async {
    // Tabela membros (existente)
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

    // Tabela configurações
    await db.execute('''
      CREATE TABLE configuracoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chave TEXT NOT NULL UNIQUE,
        valor TEXT NOT NULL,
        descricao TEXT,
        data_atualizacao INTEGER NOT NULL
      )
    ''');

    // Tabela contribuições
    await db.execute('''
      CREATE TABLE contribuicoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        membro_id INTEGER NOT NULL,
        valor REAL NOT NULL,
        mes_referencia INTEGER NOT NULL,
        ano_referencia INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pendente',
        data_geracao INTEGER NOT NULL,
        data_pagamento INTEGER,
        observacoes TEXT,
        FOREIGN KEY (membro_id) REFERENCES membros (id) ON DELETE CASCADE,
        UNIQUE(membro_id, mes_referencia, ano_referencia)
      )
    ''');

    // Inserir configurações padrão
    await _inserirConfiguracoesDefault(db);
  }

  Future<void> _inserirConfiguracoesDefault(Database db) async {
    final configuracoesPadrao = [
      {
        'chave': 'valor_contribuicao_mensal',
        'valor': '100.00',
        'descricao': 'Valor da contribuição mensal dos membros da loja',
        'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'chave': 'nome_loja',
        'valor': 'Harmonia, Luz e Sigilo nº 46',
        'descricao': 'Nome da loja',
        'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (var config in configuracoesPadrao) {
      await db.insert('configuracoes', config);
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'compasso_fiscal.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ============ CRUD Operations para Membros (existente) ============

  Future<int> insertMembro(Membro membro) async {
    final db = await database;
    return await db.insert('membros', membro.toMap());
  }

  Future<List<Membro>> getMembros() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) {
      return Membro.fromMap(maps[i]);
    });
  }

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

  Future<int> deleteMembro(int id) async {
    final db = await database;
    return await db.delete('membros', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> contarMembros() async {
    final db = await database;
    var result = await db.rawQuery('SELECT COUNT(*) as count FROM membros');
    return result.first['count'] as int? ?? 0;
  }

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

  Future<bool> existeEmailMembro(String email, {int? excluirId}) async {
    final db = await database;

    String where = 'email = ?';
    List<dynamic> whereArgs = [email];

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

  // ============ CRUD Operations para Configurações ============

  Future<int> insertConfiguracao(Configuracao configuracao) async {
    final db = await database;
    return await db.insert('configuracoes', configuracao.toMap());
  }

  Future<List<Configuracao>> getConfiguracoes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'configuracoes',
      orderBy: 'chave ASC',
    );

    return List.generate(maps.length, (i) {
      return Configuracao.fromMap(maps[i]);
    });
  }

  Future<Configuracao?> getConfiguracaoPorChave(String chave) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'configuracoes',
      where: 'chave = ?',
      whereArgs: [chave],
    );

    if (maps.isNotEmpty) {
      return Configuracao.fromMap(maps.first);
    }
    return null;
  }

  Future<String?> getValorConfiguracao(String chave) async {
    final configuracao = await getConfiguracaoPorChave(chave);
    return configuracao?.valor;
  }

  Future<double> getValorContribuicaoMensal() async {
    final valor = await getValorConfiguracao('valor_contribuicao_mensal');
    return double.tryParse(valor ?? '100.00') ?? 100.00;
  }

  Future<int> updateConfiguracao(
    String chave,
    String novoValor, {
    String? descricao,
  }) async {
    final db = await database;

    final configuracao = Configuracao(
      chave: chave,
      valor: novoValor,
      descricao: descricao,
      dataAtualizacao: DateTime.now(),
    );

    return await db.update(
      'configuracoes',
      configuracao.toMap(),
      where: 'chave = ?',
      whereArgs: [chave],
    );
  }

  Future<int> deleteConfiguracao(String chave) async {
    final db = await database;
    return await db.delete(
      'configuracoes',
      where: 'chave = ?',
      whereArgs: [chave],
    );
  }

  // ============ CRUD Operations para Contribuições ============

  Future<int> insertContribuicao(Contribuicao contribuicao) async {
    final db = await database;
    return await db.insert('contribuicoes', contribuicao.toMap());
  }

  Future<List<Contribuicao>> getContribuicoes({
    int? membroId,
    int? mesReferencia,
    int? anoReferencia,
    String? status,
  }) async {
    final db = await database;

    String where = '1=1';
    List<dynamic> whereArgs = [];

    if (membroId != null) {
      where += ' AND c.membro_id = ?';
      whereArgs.add(membroId);
    }

    if (mesReferencia != null) {
      where += ' AND c.mes_referencia = ?';
      whereArgs.add(mesReferencia);
    }

    if (anoReferencia != null) {
      where += ' AND c.ano_referencia = ?';
      whereArgs.add(anoReferencia);
    }

    if (status != null) {
      where += ' AND c.status = ?';
      whereArgs.add(status);
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        c.*,
        m.nome as membro_nome,
        m.status as membro_status
      FROM contribuicoes c
      INNER JOIN membros m ON c.membro_id = m.id
      WHERE $where
      ORDER BY c.ano_referencia DESC, c.mes_referencia DESC, m.nome ASC
    ''', whereArgs);

    return List.generate(maps.length, (i) {
      return Contribuicao.fromMap(maps[i]);
    });
  }

  Future<Contribuicao?> getContribuicaoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        c.*,
        m.nome as membro_nome,
        m.status as membro_status
      FROM contribuicoes c
      INNER JOIN membros m ON c.membro_id = m.id
      WHERE c.id = ?
    ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return Contribuicao.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateContribuicao(Contribuicao contribuicao) async {
    final db = await database;

    if (contribuicao.id == null) {
      throw Exception('ID da contribuição não pode ser nulo para atualização');
    }

    return await db.update(
      'contribuicoes',
      contribuicao.toMap(),
      where: 'id = ?',
      whereArgs: [contribuicao.id],
    );
  }

  Future<int> deleteContribuicao(int id) async {
    final db = await database;
    return await db.delete('contribuicoes', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Operações Especiais para Contribuições ============

  /// Gera contribuições mensais para todos os membros ativos
  Future<Map<String, dynamic>> gerarContribuicoesMensais({
    int? mesReferencia,
    int? anoReferencia,
  }) async {
    final agora = DateTime.now();
    final mes = mesReferencia ?? agora.month;
    final ano = anoReferencia ?? agora.year;

    // Buscar membros ativos
    final membrosAtivos = await getMembrosByStatus('ativo');

    if (membrosAtivos.isEmpty) {
      return {
        'sucesso': false,
        'mensagem': 'Nenhum membro ativo encontrado',
        'geradas': 0,
        'existentes': 0,
      };
    }

    // Obter valor da contribuição
    final valorContribuicao = await getValorContribuicaoMensal();

    int geradas = 0;
    int existentes = 0;

    for (var membro in membrosAtivos) {
      // Verificar se já existe contribuição para este membro neste período
      final contribuicoesExistentes = await getContribuicoes(
        membroId: membro.id!,
        mesReferencia: mes,
        anoReferencia: ano,
      );

      if (contribuicoesExistentes.isEmpty) {
        final novaContribuicao = Contribuicao(
          membroId: membro.id!,
          valor: valorContribuicao,
          mesReferencia: mes,
          anoReferencia: ano,
          status: 'pendente',
          dataGeracao: DateTime.now(),
        );

        await insertContribuicao(novaContribuicao);
        geradas++;
      } else {
        existentes++;
      }
    }

    return {
      'sucesso': true,
      'mensagem': 'Contribuições geradas com sucesso',
      'geradas': geradas,
      'existentes': existentes,
      'total_membros': membrosAtivos.length,
    };
  }

  /// Marcar contribuição como paga
  Future<bool> marcarContribuicaoPaga(
    int contribuicaoId, {
    String? observacoes,
  }) async {
    try {
      final contribuicao = await getContribuicaoById(contribuicaoId);
      if (contribuicao == null) return false;

      final contribuicaoAtualizada = contribuicao.copyWith(
        status: 'pago',
        dataPagamento: DateTime.now(),
        observacoes: observacoes,
      );

      final resultado = await updateContribuicao(contribuicaoAtualizada);
      return resultado > 0;
    } catch (e) {
      return false;
    }
  }

  /// Cancelar contribuição
  Future<bool> cancelarContribuicao(
    int contribuicaoId, {
    String? motivoCancelamento,
  }) async {
    try {
      final contribuicao = await getContribuicaoById(contribuicaoId);
      if (contribuicao == null) return false;

      final contribuicaoAtualizada = contribuicao.copyWith(
        status: 'cancelado',
        observacoes: motivoCancelamento,
      );

      final resultado = await updateContribuicao(contribuicaoAtualizada);
      return resultado > 0;
    } catch (e) {
      return false;
    }
  }

  /// Estatísticas de contribuições
  Future<Map<String, dynamic>> getEstatisticasContribuicoes({
    int? mesReferencia,
    int? anoReferencia,
  }) async {
    final db = await database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (mesReferencia != null) {
      whereClause += ' AND mes_referencia = ?';
      whereArgs.add(mesReferencia);
    }

    if (anoReferencia != null) {
      whereClause += ' AND ano_referencia = ?';
      whereArgs.add(anoReferencia);
    }

    final result = await db.rawQuery('''
      SELECT 
        status,
        COUNT(*) as quantidade,
        SUM(valor) as valor_total
      FROM contribuicoes 
      WHERE $whereClause
      GROUP BY status
    ''', whereArgs);

    Map<String, Map<String, dynamic>> estatisticas = {};
    double valorTotal = 0;
    int quantidadeTotal = 0;

    for (var row in result) {
      final status = row['status'] as String;
      final quantidade = row['quantidade'] as int;
      final valor = (row['valor_total'] as num?)?.toDouble() ?? 0;

      estatisticas[status] = {'quantidade': quantidade, 'valor_total': valor};

      quantidadeTotal += quantidade;
      valorTotal += valor;
    }

    return {
      'por_status': estatisticas,
      'total_geral': {'quantidade': quantidadeTotal, 'valor_total': valorTotal},
    };
  }

  /// Verificar se já existem contribuições para o período
  Future<bool> existemContribuicoesPeriodo(int mes, int ano) async {
    final contribuicoes = await getContribuicoes(
      mesReferencia: mes,
      anoReferencia: ano,
    );
    return contribuicoes.isNotEmpty;
  }

  // ============ Operações de Limpeza e Manutenção ============

  Future<void> limparDados() async {
    final db = await database;
    await db.delete('contribuicoes');
    await db.delete('membros');
    await db.delete('configuracoes');
    await _inserirConfiguracoesDefault(db);
  }

  Future<void> fecharDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
