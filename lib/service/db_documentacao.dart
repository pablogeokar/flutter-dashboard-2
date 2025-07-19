// Importações necessárias para trabalhar com banco de dados SQLite
import 'package:path/path.dart'; // Para manipulação de caminhos de arquivos
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // SQLite para desktop (Windows, Linux, macOS)
import 'dart:developer' as developer; // Para logs de desenvolvimento

/// Classe responsável por gerenciar a conexão e operações do banco de dados SQLite
///
/// Esta classe implementa o padrão Singleton, garantindo que apenas uma instância
/// da conexão com o banco seja criada durante toda a execução da aplicação.
///
/// **O que é o padrão Singleton?**
/// É um padrão de design que garante que uma classe tenha apenas uma instância
/// e fornece um ponto global de acesso a essa instância. Isso é importante para
/// bancos de dados porque evita múltiplas conexões desnecessárias.
///
/// **Por que usar Singleton para banco de dados?**
/// - Evita criar múltiplas conexões com o banco
/// - Economiza recursos do sistema
/// - Garante consistência dos dados
/// - Facilita o controle de transações
class DB {
  // ========== IMPLEMENTAÇÃO DO PADRÃO SINGLETON ==========

  /// Instância única da classe DB (padrão Singleton)
  ///
  /// O modificador 'static final' garante que:
  /// - static: pertence à classe, não a uma instância específica
  /// - final: não pode ser reatribuída após a inicialização
  ///
  /// '_instance' é privado (começa com _) para que não possa ser acessado
  /// diretamente de fora da classe
  static final DB _instance = DB._internal();

  /// Variável que armazena a conexão com o banco de dados
  ///
  /// É nullable (Database?) porque inicialmente não temos conexão.
  /// Será inicializada apenas quando necessário (lazy initialization)
  static Database? _database;

  /// Factory constructor - ponto de entrada público para obter a instância
  ///
  /// **O que é um factory constructor?**
  /// É um construtor especial que pode retornar uma instância existente
  /// ao invés de sempre criar uma nova. Perfeito para implementar Singleton.
  ///
  /// Quando você chama DB(), sempre recebe a mesma instância (_instance)
  factory DB() => _instance;

  /// Construtor privado que é chamado apenas uma vez
  ///
  /// **Por que é privado?**
  /// O underscore (_) torna o construtor privado, impedindo que seja
  /// chamado diretamente de fora da classe. Isso força o uso do factory.
  ///
  /// **O que faz a inicialização?**
  /// - sqfliteFfiInit(): Inicializa o SQLite para desktop
  /// - databaseFactory: Define qual implementação do SQLite usar
  DB._internal() {
    try {
      // Inicializa o SQLite FFI para funcionar em desktop (Windows, Linux, macOS)
      sqfliteFfiInit();

      // Define a factory do banco para usar a implementação FFI
      // Isso é necessário para que o SQLite funcione em desktop
      databaseFactory = databaseFactoryFfi;

      developer.log('DB: Inicialização do SQLite FFI concluída com sucesso');
    } catch (e) {
      developer.log('DB: Erro na inicialização do SQLite FFI: $e', level: 1000);
      rethrow; // Relança a exceção para que possa ser tratada em nível superior
    }
  }

  // ========== GERENCIAMENTO DA CONEXÃO COM O BANCO ==========

  /// Getter assíncrono para obter a instância do banco de dados
  ///
  /// **O que é um getter?**
  /// É uma propriedade computada que executa código quando acessada.
  /// Parece uma propriedade normal, mas na verdade executa uma função.
  ///
  /// **Por que é assíncrono (Future)?**
  /// Operações de banco de dados são I/O (entrada/saída) e podem demorar,
  /// então precisam ser assíncronas para não travar a interface do usuário.
  ///
  /// **O operador ??=**
  /// Significa "se for null, então atribua". Garante que o banco seja
  /// inicializado apenas uma vez (lazy initialization).
  Future<Database> get database async {
    try {
      // Se _database for null, inicializa. Caso contrário, usa a existente
      _database ??= await _initDatabase();

      // O operador ! força o unwrap do nullable, pois sabemos que não é null
      return _database!;
    } catch (e) {
      developer.log('DB: Erro ao obter conexão com o banco: $e', level: 1000);
      rethrow;
    }
  }

  /// Método privado para inicializar o banco de dados
  ///
  /// **Por que é privado?**
  /// Só deve ser chamado internamente pela classe, não por código externo.
  ///
  /// **O que faz?**
  /// 1. Define o caminho onde o arquivo do banco será salvo
  /// 2. Abre/cria o banco de dados
  /// 3. Define a versão do schema (importante para migrações futuras)
  /// 4. Chama onCreate se for a primeira vez que o banco é criado
  Future<Database> _initDatabase() async {
    try {
      // Obtém o diretório padrão para bancos de dados do sistema
      String databasesPath = await getDatabasesPath();

      // Constrói o caminho completo para o arquivo do banco
      // join() é uma função segura para construir caminhos de arquivo
      String path = join(databasesPath, 'database_compasso_fiscal.db');

      developer.log('DB: Inicializando banco de dados em: $path');

      // Abre/cria o banco de dados
      return await openDatabase(
        path, // Caminho do arquivo
        version: 1, // Versão do schema (importante para migrações)
        onCreate: _onCreate, // Callback chamado na primeira criação
        onUpgrade: _onUpgrade, // Callback para atualizações de versão
        onOpen: _onOpen, // Callback chamado sempre que o banco é aberto
      );
    } catch (e) {
      developer.log('DB: Erro na inicialização do banco: $e', level: 1000);
      rethrow;
    }
  }

  // ========== CALLBACKS DO CICLO DE VIDA DO BANCO ==========

  /// Callback executado quando o banco é criado pela primeira vez
  ///
  /// **Quando é chamado?**
  /// Apenas na primeira vez que a aplicação roda, quando o arquivo
  /// do banco ainda não existe no sistema.
  ///
  /// **Para que serve?**
  /// Para criar todas as tabelas, índices e dados iniciais necessários.
  Future<void> _onCreate(Database db, int version) async {
    try {
      developer.log('DB: Criando estrutura inicial do banco (versão $version)');

      // Cria a tabela de membros
      await db.execute('''
        CREATE TABLE membros(
          id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Chave primária auto-incrementável
          nome TEXT NOT NULL,                    -- Nome obrigatório
          email TEXT UNIQUE,                     -- Email único (pode ser null)
          telefone TEXT,                         -- Telefone opcional
          grau TEXT NOT NULL,                    -- Grau/cargo obrigatório
          status TEXT NOT NULL DEFAULT 'ativo', -- Status com valor padrão
          observacoes TEXT,                      -- Observações opcionais
          data_criacao INTEGER NOT NULL DEFAULT (strftime('%s', 'now')), -- Timestamp de criação
          data_atualizacao INTEGER NOT NULL DEFAULT (strftime('%s', 'now')) -- Timestamp de atualização
        )
      ''');

      // Cria índices para melhorar performance das consultas
      await db.execute('CREATE INDEX idx_membros_status ON membros(status)');
      await db.execute('CREATE INDEX idx_membros_grau ON membros(grau)');

      developer.log('DB: Estrutura do banco criada com sucesso');
    } catch (e) {
      developer.log('DB: Erro ao criar estrutura do banco: $e', level: 1000);
      rethrow;
    }
  }

  /// Callback executado quando o banco precisa ser atualizado
  ///
  /// **Quando é chamado?**
  /// Quando a versão do banco no código é maior que a versão
  /// do arquivo existente no dispositivo.
  ///
  /// **Para que serve?**
  /// Para fazer migrações: adicionar novas tabelas, colunas,
  /// modificar estruturas existentes, etc.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      developer.log(
        'DB: Atualizando banco da versão $oldVersion para $newVersion',
      );

      // Exemplo de migração da versão 1 para 2
      if (oldVersion < 2) {
        // await db.execute('ALTER TABLE membros ADD COLUMN nova_coluna TEXT');
      }

      // Exemplo de migração da versão 2 para 3
      if (oldVersion < 3) {
        // await db.execute('CREATE TABLE nova_tabela(id INTEGER PRIMARY KEY)');
      }

      developer.log('DB: Atualização do banco concluída');
    } catch (e) {
      developer.log('DB: Erro na atualização do banco: $e', level: 1000);
      rethrow;
    }
  }

  /// Callback executado sempre que o banco é aberto
  ///
  /// **Para que serve?**
  /// Para configurações que devem ser aplicadas toda vez que
  /// o banco é aberto, como habilitar foreign keys.
  Future<void> _onOpen(Database db) async {
    try {
      // Habilita foreign keys (chaves estrangeiras)
      await db.execute('PRAGMA foreign_keys = ON');

      developer.log('DB: Banco de dados aberto e configurado');
    } catch (e) {
      developer.log('DB: Erro ao configurar banco aberto: $e', level: 1000);
    }
  }

  // ========== MÉTODOS CRUD BÁSICOS (EXEMPLO) ==========
  // Estes métodos servem como exemplo de como implementar operações básicas

  /// Insere um novo membro no banco de dados
  ///
  /// **Parâmetros:**
  /// - dados: Map com os dados do membro (nome, email, etc.)
  ///
  /// **Retorna:**
  /// - int: ID do registro inserido
  ///
  /// **Exemplo de uso:**
  /// ```dart
  /// final db = DB();
  /// int id = await db.inserirMembro({
  ///   'nome': 'João Silva',
  ///   'email': 'joao@email.com',
  ///   'grau': 'Membro'
  /// });
  /// ```
  Future<int> inserirMembro(Map<String, dynamic> dados) async {
    try {
      final db = await database;

      // Adiciona timestamps automáticos
      dados['data_criacao'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      dados['data_atualizacao'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      int id = await db.insert('membros', dados);
      developer.log('DB: Membro inserido com ID: $id');

      return id;
    } catch (e) {
      developer.log('DB: Erro ao inserir membro: $e', level: 1000);
      rethrow;
    }
  }

  /// Busca todos os membros ou filtra por status
  ///
  /// **Parâmetros:**
  /// - status: Filtro opcional por status ('ativo', 'inativo', etc.)
  ///
  /// **Retorna:**
  /// - List<Map<String, dynamic>>: Lista de membros
  Future<List<Map<String, dynamic>>> buscarMembros({String? status}) async {
    try {
      final db = await database;

      List<Map<String, dynamic>> resultado;

      if (status != null) {
        // Busca com filtro
        resultado = await db.query(
          'membros',
          where: 'status = ?',
          whereArgs: [status],
          orderBy: 'nome ASC',
        );
      } else {
        // Busca todos
        resultado = await db.query('membros', orderBy: 'nome ASC');
      }

      developer.log('DB: Encontrados ${resultado.length} membros');
      return resultado;
    } catch (e) {
      developer.log('DB: Erro ao buscar membros: $e', level: 1000);
      rethrow;
    }
  }

  /// Atualiza um membro existente
  ///
  /// **Parâmetros:**
  /// - id: ID do membro a ser atualizado
  /// - dados: Map com os novos dados
  ///
  /// **Retorna:**
  /// - int: Número de registros afetados (deve ser 1 se bem-sucedido)
  Future<int> atualizarMembro(int id, Map<String, dynamic> dados) async {
    try {
      final db = await database;

      // Atualiza timestamp de modificação
      dados['data_atualizacao'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      int count = await db.update(
        'membros',
        dados,
        where: 'id = ?',
        whereArgs: [id],
      );

      developer.log('DB: $count membro(s) atualizado(s)');
      return count;
    } catch (e) {
      developer.log('DB: Erro ao atualizar membro: $e', level: 1000);
      rethrow;
    }
  }

  /// Remove um membro do banco de dados
  ///
  /// **Parâmetros:**
  /// - id: ID do membro a ser removido
  ///
  /// **Retorna:**
  /// - int: Número de registros removidos (deve ser 1 se bem-sucedido)
  Future<int> removerMembro(int id) async {
    try {
      final db = await database;

      int count = await db.delete('membros', where: 'id = ?', whereArgs: [id]);

      developer.log('DB: $count membro(s) removido(s)');
      return count;
    } catch (e) {
      developer.log('DB: Erro ao remover membro: $e', level: 1000);
      rethrow;
    }
  }

  // ========== MÉTODOS DE UTILIDADE ==========

  /// Fecha a conexão com o banco de dados
  ///
  /// **Quando usar?**
  /// Geralmente não é necessário chamar manualmente, mas pode ser útil
  /// em testes ou quando você quer forçar uma nova conexão.
  Future<void> fecharBanco() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        developer.log('DB: Conexão com banco fechada');
      }
    } catch (e) {
      developer.log('DB: Erro ao fechar banco: $e', level: 1000);
    }
  }

  /// Executa uma query SQL personalizada
  ///
  /// **Cuidado!** Use apenas se souber o que está fazendo.
  /// Prefira os métodos específicos acima para operações comuns.
  Future<List<Map<String, dynamic>>> executarQuery(
    String sql, [
    List<dynamic>? argumentos,
  ]) async {
    try {
      final db = await database;
      return await db.rawQuery(sql, argumentos);
    } catch (e) {
      developer.log('DB: Erro ao executar query: $e', level: 1000);
      rethrow;
    }
  }

  /// Verifica se o banco está funcionando corretamente
  ///
  /// **Para que serve?**
  /// Útil para diagnósticos e testes de conectividade
  Future<bool> verificarConexao() async {
    try {
      final db = await database;
      await db.rawQuery('SELECT 1');
      developer.log('DB: Conexão verificada com sucesso');
      return true;
    } catch (e) {
      developer.log('DB: Falha na verificação da conexão: $e', level: 1000);
      return false;
    }
  }
}

// ========== COMENTÁRIOS FINAIS PARA INICIANTES ==========

/*
RESUMO DAS MELHORIAS IMPLEMENTADAS:

1. **Comentários Detalhados**: Cada linha importante foi comentada explicando
   o que faz e por que é importante.

2. **Tratamento de Erros**: Todos os métodos agora têm try-catch adequado
   com logs detalhados para facilitar o debugging.

3. **Logs de Desenvolvimento**: Usando dart:developer para logs que ajudam
   a entender o que está acontecendo durante a execução.

4. **Métodos CRUD Completos**: Exemplos de como inserir, buscar, atualizar
   e remover dados do banco.

5. **Timestamps Automáticos**: Campos de data_criacao e data_atualizacao
   são preenchidos automaticamente.

6. **Índices de Performance**: Criação de índices para consultas mais rápidas.

7. **Callbacks de Ciclo de Vida**: Implementação completa de onCreate,
   onUpgrade e onOpen.

8. **Validações e Segurança**: Uso de parâmetros preparados (?) para
   evitar SQL injection.

9. **Métodos Utilitários**: Funções auxiliares para verificação de conexão
   e execução de queries personalizadas.

10. **Estrutura Organizacional**: Código organizado em seções lógicas
    com comentários de cabeçalho.

COMO USAR ESTA CLASSE:

```dart
// Obter instância (sempre a mesma devido ao Singleton)
final db = DB();

// Inserir um membro
int id = await db.inserirMembro({
  'nome': 'João Silva',
  'email': 'joao@email.com',
  'grau': 'Membro'
});

// Buscar membros
List<Map<String, dynamic>> membros = await db.buscarMembros();

// Buscar apenas membros ativos
List<Map<String, dynamic>> ativos = await db.buscarMembros(status: 'ativo');

// Atualizar um membro
await db.atualizarMembro(id, {'telefone': '11999999999'});

// Remover um membro
await db.removerMembro(id);
```

PRÓXIMOS PASSOS RECOMENDADOS:

1. Criar classes de modelo (Model) para representar os dados
2. Implementar um padrão Repository para separar a lógica de dados
3. Adicionar validações de entrada nos métodos
4. Implementar cache em memória para consultas frequentes
5. Adicionar suporte a transações para operações complexas
*/
