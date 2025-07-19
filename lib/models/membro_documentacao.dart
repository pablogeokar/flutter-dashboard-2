/// Modelo de dados para representar um membro da organização
///
/// Esta classe representa a estrutura de dados de um membro e fornece
/// métodos para conversão entre objeto Dart e Map (necessário para SQLite).
///
/// **O que é um Model/Modelo?**
/// É uma classe que representa os dados da aplicação. Ela define:
/// - Quais informações um objeto possui (propriedades)
/// - Como converter esses dados para armazenamento (toMap)
/// - Como criar objetos a partir de dados armazenados (fromMap)
/// - Validações e regras de negócio dos dados
///
/// **Por que usar Models?**
/// - Organização: Centraliza a estrutura dos dados
/// - Type Safety: Garante que os dados tenham os tipos corretos
/// - Reutilização: Pode ser usado em toda a aplicação
/// - Manutenibilidade: Facilita mudanças na estrutura dos dados
class Membro {
  // ========== PROPRIEDADES DO MEMBRO ==========

  /// ID único do membro no banco de dados
  ///
  /// **Por que int? (nullable)?**
  /// - Quando criamos um novo membro, ainda não tem ID (será gerado pelo banco)
  /// - Após salvar no banco, o ID será preenchido automaticamente
  /// - final: uma vez definido, não pode ser alterado (imutabilidade)
  final int? id;

  /// Nome completo do membro (obrigatório)
  ///
  /// **Por que String (não nullable)?**
  /// - Todo membro deve ter um nome
  /// - É um campo obrigatório no banco de dados
  final String nome;

  /// Email do membro (opcional)
  ///
  /// **Por que String? (nullable)?**
  /// - Nem todo membro precisa ter email
  /// - Pode ser adicionado posteriormente
  final String? email;

  /// Telefone do membro (opcional)
  final String? telefone;

  /// Grau/nível do membro na organização (obrigatório)
  ///
  /// **Valores possíveis:** 'Aprendiz', 'Companheiro', 'Mestre', 'Administrador'
  /// Em uma versão mais avançada, isso poderia ser um enum
  final String grau;

  /// Status atual do membro (obrigatório, com valor padrão)
  ///
  /// **Valores possíveis:** 'ativo', 'inativo', 'pausado', 'suspenso'
  final String status;

  /// Observações adicionais sobre o membro (opcional)
  final String? observacoes;

  /// Data e hora de criação do registro
  ///
  /// **Por que DateTime (não nullable)?**
  /// - Todo registro deve ter uma data de criação
  /// - Importante para auditoria e controle
  final DateTime dataCriacao;

  /// Data e hora da última atualização do registro
  final DateTime dataAtualizacao;

  // ========== CONSTRUTORES ==========

  /// Construtor principal da classe Membro
  ///
  /// **Parâmetros obrigatórios (required):**
  /// - nome: Todo membro deve ter um nome
  /// - grau: Todo membro deve ter um grau definido
  ///
  /// **Parâmetros opcionais:**
  /// - id: Será null para novos membros, preenchido pelo banco
  /// - email, telefone, observacoes: Campos opcionais
  /// - status: Tem valor padrão 'ativo'
  /// - dataCriacao, dataAtualizacao: Preenchidos automaticamente se não fornecidos
  Membro({
    this.id,
    required this.nome,
    this.email,
    this.telefone,
    required this.grau,
    this.status = 'ativo',
    this.observacoes,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) : // Inicializadores: executados antes do corpo do construtor
       dataCriacao = dataCriacao ?? DateTime.now(),
       dataAtualizacao = dataAtualizacao ?? DateTime.now() {
    // Validações no construtor
    _validarDados();
  }

  /// Construtor nomeado para criar um novo membro (sem ID)
  ///
  /// **Quando usar?**
  /// Ao criar um membro que ainda não foi salvo no banco de dados.
  /// É mais semântico que usar o construtor principal com id: null.
  ///
  /// **Exemplo de uso:**
  /// ```dart
  /// final novoMembro = Membro.novo(
  ///   nome: 'João Silva',
  ///   grau: 'Aprendiz',
  ///   email: 'joao@email.com'
  /// );
  /// ```
  Membro.novo({
    required String nome,
    required String grau,
    String? email,
    String? telefone,
    String status = 'ativo',
    String? observacoes,
  }) : this(
         nome: nome,
         grau: grau,
         email: email,
         telefone: telefone,
         status: status,
         observacoes: observacoes,
       );

  // ========== VALIDAÇÕES PRIVADAS ==========

  /// Valida os dados do membro
  ///
  /// **Por que validar?**
  /// - Garante que os dados estão corretos antes de usar
  /// - Evita erros em tempo de execução
  /// - Facilita a identificação de problemas
  void _validarDados() {
    // Valida nome
    if (nome.trim().isEmpty) {
      throw ArgumentError('Nome não pode estar vazio');
    }

    if (nome.trim().length < 2) {
      throw ArgumentError('Nome deve ter pelo menos 2 caracteres');
    }

    // Valida email se fornecido
    if (email != null && email!.isNotEmpty) {
      if (!_isEmailValido(email!)) {
        throw ArgumentError('Email inválido: $email');
      }
    }

    // Valida grau
    if (!_isGrauValido(grau)) {
      throw ArgumentError(
        'Grau inválido: $grau. Valores aceitos: ${grausValidos.join(', ')}',
      );
    }

    // Valida status
    if (!_isStatusValido(status)) {
      throw ArgumentError(
        'Status inválido: $status. Valores aceitos: ${statusValidos.join(', ')}',
      );
    }
  }

  /// Valida se o email tem formato correto
  bool _isEmailValido(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Valida se o grau é um dos valores aceitos
  bool _isGrauValido(String grau) {
    return grausValidos.contains(grau);
  }

  /// Valida se o status é um dos valores aceitos
  bool _isStatusValido(String status) {
    return statusValidos.contains(status);
  }

  // ========== CONSTANTES DE VALIDAÇÃO ==========

  /// Lista de graus válidos para um membro
  ///
  /// **Por que usar constantes?**
  /// - Evita erros de digitação
  /// - Facilita manutenção (mudança em um lugar só)
  /// - Permite validação consistente
  static const List<String> grausValidos = [
    'Aprendiz',
    'Companheiro',
    'Mestre',
    'Administrador',
  ];

  /// Lista de status válidos para um membro
  static const List<String> statusValidos = [
    'ativo',
    'inativo',
    'pausado',
    'suspenso',
  ];

  // ========== MÉTODOS DE CONVERSÃO ==========

  /// Converte o objeto Membro em um Map para armazenamento no banco
  ///
  /// **Por que precisamos deste método?**
  /// O SQLite trabalha com Maps (chave-valor), não com objetos Dart.
  /// Este método converte nosso objeto em um formato que o banco entende.
  ///
  /// **Quando é usado?**
  /// - Ao inserir um novo membro no banco
  /// - Ao atualizar um membro existente
  ///
  /// **Exemplo de retorno:**
  /// ```dart
  /// {
  ///   'id': 1,
  ///   'nome': 'João Silva',
  ///   'email': 'joao@email.com',
  ///   'grau': 'Aprendiz',
  ///   'status': 'ativo',
  ///   'data_criacao': 1642781234,
  ///   'data_atualizacao': 1642781234
  /// }
  /// ```
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'grau': grau,
      'status': status,
      'observacoes': observacoes,
      // Converte DateTime para timestamp (segundos desde 1970)
      // Isso é necessário porque SQLite não tem tipo DateTime nativo
      'data_criacao': dataCriacao.millisecondsSinceEpoch ~/ 1000,
      'data_atualizacao': dataAtualizacao.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Cria um objeto Membro a partir de um Map vindo do banco de dados
  ///
  /// **Por que é um factory constructor?**
  /// Factory constructors podem fazer validações e processamentos
  /// antes de criar o objeto, diferente de construtores normais.
  ///
  /// **Quando é usado?**
  /// - Ao buscar membros do banco de dados
  /// - Ao receber dados de APIs
  ///
  /// **Exemplo de uso:**
  /// ```dart
  /// Map<String, dynamic> dadosDoBanco = {
  ///   'id': 1,
  ///   'nome': 'João Silva',
  ///   'grau': 'Aprendiz'
  /// };
  /// Membro membro = Membro.fromMap(dadosDoBanco);
  /// ```
  factory Membro.fromMap(Map<String, dynamic> map) {
    // Validação básica dos dados obrigatórios
    if (map['nome'] == null || map['nome'].toString().trim().isEmpty) {
      throw ArgumentError('Nome é obrigatório nos dados do mapa');
    }

    if (map['grau'] == null || map['grau'].toString().trim().isEmpty) {
      throw ArgumentError('Grau é obrigatório nos dados do mapa');
    }

    return Membro(
      id: map['id']?.toInt(),
      nome: map['nome'].toString().trim(),
      email: map['email']?.toString().trim(),
      telefone: map['telefone']?.toString().trim(),
      grau: map['grau'].toString().trim(),
      status: map['status']?.toString().trim() ?? 'ativo',
      observacoes: map['observacoes']?.toString().trim(),
      // Converte timestamp de volta para DateTime
      // Se não existir, usa DateTime.now()
      dataCriacao: map['data_criacao'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['data_criacao'] * 1000)
          : DateTime.now(),
      dataAtualizacao: map['data_atualizacao'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['data_atualizacao'] * 1000)
          : DateTime.now(),
    );
  }

  // ========== MÉTODOS DE CÓPIA E ATUALIZAÇÃO ==========

  /// Cria uma cópia do membro com alguns campos alterados
  ///
  /// **Por que este método é importante?**
  /// Como as propriedades são 'final' (imutáveis), não podemos alterá-las
  /// diretamente. Este método cria um novo objeto com as mudanças desejadas.
  ///
  /// **Quando usar?**
  /// - Ao atualizar informações de um membro
  /// - Ao criar variações de um membro existente
  ///
  /// **Exemplo de uso:**
  /// ```dart
  /// Membro membroOriginal = Membro.novo(nome: 'João', grau: 'Aprendiz');
  /// Membro membroAtualizado = membroOriginal.copyWith(
  ///   grau: 'Companheiro',
  ///   email: 'joao@email.com'
  /// );
  /// ```
  Membro copyWith({
    int? id,
    String? nome,
    String? email,
    String? telefone,
    String? grau,
    String? status,
    String? observacoes,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return Membro(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      grau: grau ?? this.grau,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      // Se não especificar dataAtualizacao, usa DateTime.now() para indicar modificação
      dataAtualizacao: dataAtualizacao ?? DateTime.now(),
    );
  }

  /// Cria uma cópia do membro marcando como atualizado agora
  ///
  /// **Conveniência:** Método específico para marcar um membro como recém-atualizado
  Membro marcarComoAtualizado() {
    return copyWith(dataAtualizacao: DateTime.now());
  }

  // ========== MÉTODOS DE VALIDAÇÃO PÚBLICA ==========

  /// Verifica se o membro está ativo
  bool get isAtivo => status == 'ativo';

  /// Verifica se o membro está inativo
  bool get isInativo => status == 'inativo';

  /// Verifica se o membro tem email cadastrado
  bool get temEmail => email != null && email!.isNotEmpty;

  /// Verifica se o membro tem telefone cadastrado
  bool get temTelefone => telefone != null && telefone!.isNotEmpty;

  /// Verifica se o membro é um administrador
  bool get isAdministrador => grau == 'Administrador';

  /// Verifica se o membro é um mestre
  bool get isMestre => grau == 'Mestre';

  /// Retorna a idade do registro em dias
  int get idadeEmDias => DateTime.now().difference(dataCriacao).inDays;

  /// Retorna há quantos dias foi atualizado
  int get diasDesdeUltimaAtualizacao =>
      DateTime.now().difference(dataAtualizacao).inDays;

  // ========== MÉTODOS DE FORMATAÇÃO ==========

  /// Retorna o nome formatado (primeira letra maiúscula)
  String get nomeFormatado {
    return nome
        .split(' ')
        .map((palavra) {
          if (palavra.isEmpty) return palavra;
          return palavra[0].toUpperCase() + palavra.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Retorna as iniciais do nome
  String get iniciais {
    List<String> palavras = nome.trim().split(' ');
    if (palavras.isEmpty) return '';

    String iniciais = '';
    for (String palavra in palavras) {
      if (palavra.isNotEmpty) {
        iniciais += palavra[0].toUpperCase();
      }
    }
    return iniciais;
  }

  /// Retorna uma descrição resumida do membro
  String get resumo => '$nomeFormatado ($grau) - $status';

  // ========== MÉTODOS DE COMPARAÇÃO ==========

  /// Compara dois membros por igualdade
  ///
  /// **Quando dois membros são considerados iguais?**
  /// Quando têm o mesmo ID (se ambos tiverem ID) ou
  /// quando têm o mesmo nome e grau (para membros sem ID)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Membro &&
        // Se ambos têm ID, compara por ID
        ((id != null && other.id != null && id == other.id) ||
            // Se não têm ID, compara por nome e grau
            (id == null &&
                other.id == null &&
                nome == other.nome &&
                grau == other.grau));
  }

  /// Gera um hash code para o objeto
  ///
  /// **Para que serve?**
  /// Necessário quando sobrescrevemos o operador ==
  /// Usado em coleções como Set e Map para identificar objetos únicos
  @override
  int get hashCode {
    return id?.hashCode ?? Object.hash(nome, grau);
  }

  // ========== MÉTODOS DE REPRESENTAÇÃO ==========

  /// Representação em string do objeto (para debugging)
  ///
  /// **Quando é usado?**
  /// - Ao fazer print() do objeto
  /// - Em logs de debug
  /// - Em mensagens de erro
  @override
  String toString() {
    return 'Membro{id: $id, nome: $nome, grau: $grau, status: $status, '
        'criado: ${dataCriacao.day}/${dataCriacao.month}/${dataCriacao.year}}';
  }

  /// Representação detalhada em string
  String toStringDetalhado() {
    return '''
Membro:
  ID: $id
  Nome: $nomeFormatado
  Email: ${email ?? 'Não informado'}
  Telefone: ${telefone ?? 'Não informado'}
  Grau: $grau
  Status: $status
  Observações: ${observacoes ?? 'Nenhuma'}
  Criado em: ${dataCriacao.day}/${dataCriacao.month}/${dataCriacao.year}
  Atualizado em: ${dataAtualizacao.day}/${dataAtualizacao.month}/${dataAtualizacao.year}
''';
  }

  // ========== MÉTODOS ESTÁTICOS UTILITÁRIOS ==========

  /// Cria uma lista de membros a partir de uma lista de Maps
  ///
  /// **Quando usar?**
  /// Ao buscar múltiplos membros do banco de dados
  ///
  /// **Exemplo:**
  /// ```dart
  /// List<Map<String, dynamic>> dadosDoBanco = await db.query('membros');
  /// List<Membro> membros = Membro.fromMapList(dadosDoBanco);
  /// ```
  static List<Membro> fromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => Membro.fromMap(map)).toList();
  }

  /// Converte uma lista de membros em uma lista de Maps
  ///
  /// **Quando usar?**
  /// Raramente usado diretamente, mas útil para serialização
  static List<Map<String, dynamic>> toMapList(List<Membro> membros) {
    return membros.map((membro) => membro.toMap()).toList();
  }

  /// Filtra membros por status
  static List<Membro> filtrarPorStatus(List<Membro> membros, String status) {
    return membros.where((membro) => membro.status == status).toList();
  }

  /// Filtra membros por grau
  static List<Membro> filtrarPorGrau(List<Membro> membros, String grau) {
    return membros.where((membro) => membro.grau == grau).toList();
  }

  /// Ordena membros por nome
  static List<Membro> ordenarPorNome(List<Membro> membros) {
    List<Membro> copia = List.from(membros);
    copia.sort((a, b) => a.nome.compareTo(b.nome));
    return copia;
  }

  /// Ordena membros por data de criação (mais recentes primeiro)
  static List<Membro> ordenarPorDataCriacao(List<Membro> membros) {
    List<Membro> copia = List.from(membros);
    copia.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    return copia;
  }
}

// ========== COMENTÁRIOS FINAIS PARA INICIANTES ==========

/*
RESUMO DAS MELHORIAS NO MODEL MEMBRO:

1. **Comentários Educativos Detalhados**: Cada conceito explicado de forma didática
   para facilitar o aprendizado de iniciantes.

2. **Validações Robustas**: Validação de email, nome, grau e status com mensagens
   de erro claras.

3. **Construtores Múltiplos**: Construtor principal e construtor nomeado para
   diferentes cenários de uso.

4. **Propriedades Computadas**: Getters que fornecem informações úteis como
   isAtivo, temEmail, nomeFormatado, etc.

5. **Métodos de Conversão Seguros**: toMap() e fromMap() com validações e
   tratamento de casos especiais.

6. **Timestamps Automáticos**: Controle automático de datas de criação e
   atualização.

7. **Métodos de Comparação**: Implementação de == e hashCode para comparações
   corretas entre objetos.

8. **Métodos Utilitários Estáticos**: Funções auxiliares para trabalhar com
   listas de membros.

9. **Formatação e Apresentação**: Métodos para exibir dados de forma amigável
   ao usuário.

10. **Imutabilidade**: Uso de 'final' e copyWith() para garantir que os objetos
    não sejam modificados acidentalmente.

COMO USAR ESTE MODEL:

```dart
// Criar um novo membro
final novoMembro = Membro.novo(
  nome: 'João Silva',
  grau: 'Aprendiz',
  email: 'joao@email.com'
);

// Verificar propriedades
if (novoMembro.isAtivo && novoMembro.temEmail) {
  print('Membro ativo com email: ${novoMembro.email}');
}

// Atualizar membro (cria nova instância)
final membroAtualizado = novoMembro.copyWith(
  grau: 'Companheiro',
  status: 'ativo'
);

// Converter para Map (para salvar no banco)
Map<String, dynamic> dados = membroAtualizado.toMap();

// Criar a partir de Map (vindo do banco)
final membroDoBanco = Membro.fromMap(dados);

// Trabalhar com listas
List<Membro> membrosAtivos = Membro.filtrarPorStatus(todosMembros, 'ativo');
List<Membro> membrosOrdenados = Membro.ordenarPorNome(membrosAtivos);
```

PRÓXIMOS PASSOS RECOMENDADOS:

1. Criar enums para grau e status (mais type-safe)
2. Implementar serialização JSON para APIs
3. Adicionar mais validações específicas do negócio
4. Criar testes unitários para todas as funcionalidades
5. Implementar padrão Repository para separar lógica de dados
*/
