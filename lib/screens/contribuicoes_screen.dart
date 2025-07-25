import 'package:flutter/material.dart';
import 'package:flutter_dashboard_2/services/database_service.dart';
import 'package:flutter_dashboard_2/models/contribuicao.dart';
import 'package:flutter_dashboard_2/widgets/modals/contribuicao_form_modal.dart';

class ContribuicoesScreen extends StatefulWidget {
  const ContribuicoesScreen({super.key});

  @override
  State<ContribuicoesScreen> createState() => _ContribuicoesScreenState();
}

class _ContribuicoesScreenState extends State<ContribuicoesScreen> {
  List<Contribuicao> _contribuicoes = [];
  Map<String, dynamic> _estatisticas = {};
  bool _isLoading = true;

  int _mesReferencia = DateTime.now().month;
  int _anoReferencia = DateTime.now().year;

  final List<String> _meses = [
    '',
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);

    try {
      final db = DatabaseService();

      final contribuicoes = await db.getContribuicoes(
        mesReferencia: _mesReferencia,
        anoReferencia: _anoReferencia,
      );

      final estatisticas = await db.getEstatisticasContribuicoes(
        mesReferencia: _mesReferencia,
        anoReferencia: _anoReferencia,
      );

      setState(() {
        _contribuicoes = contribuicoes;
        _estatisticas = estatisticas;
      });
    } catch (e) {
      _mostrarMensagem('Erro ao carregar dados: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _gerarContribuicoes() async {
    // Verificar se já existem contribuições para o período
    final db = DatabaseService();
    final existem = await db.existemContribuicoesPeriodo(
      _mesReferencia,
      _anoReferencia,
    );

    if (existem) {
      final confirmacao = await _mostrarDialogoConfirmacao(
        'Contribuições Existentes',
        'Já existem contribuições geradas para ${_meses[_mesReferencia]}/$_anoReferencia. '
            'Deseja gerar apenas para os membros que ainda não possuem contribuição neste período?',
      );

      if (!confirmacao) return;
    }

    try {
      _mostrarDialogoCarregamento('Gerando contribuições...');

      final resultado = await db.gerarContribuicoesMensais(
        mesReferencia: _mesReferencia,
        anoReferencia: _anoReferencia,
      );

      Navigator.pop(context); // Fechar diálogo de carregamento

      if (resultado['sucesso']) {
        _mostrarMensagem(
          'Contribuições geradas: ${resultado['geradas']}\n'
          'Já existentes: ${resultado['existentes']}\n'
          'Total de membros: ${resultado['total_membros']}',
          Colors.green,
        );

        await _carregarDados();
      } else {
        _mostrarMensagem(resultado['mensagem'], Colors.orange);
      }
    } catch (e) {
      Navigator.pop(context); // Fechar diálogo de carregamento
      _mostrarMensagem('Erro ao gerar contribuições: $e', Colors.red);
    }
  }

  Future<void> _marcarComoPago(Contribuicao contribuicao) async {
    final observacoes = await _mostrarDialogoObservacoes(
      'Marcar como Pago',
      'Adicione observações sobre o pagamento (opcional):',
    );

    if (observacoes == null) return; // Usuário cancelou

    try {
      final db = DatabaseService();
      final sucesso = await db.marcarContribuicaoPaga(
        contribuicao.id!,
        observacoes: observacoes.isEmpty ? null : observacoes,
      );

      if (sucesso) {
        _mostrarMensagem('Contribuição marcada como paga!', Colors.green);
        await _carregarDados();
      } else {
        _mostrarMensagem('Erro ao marcar contribuição como paga', Colors.red);
      }
    } catch (e) {
      _mostrarMensagem('Erro ao marcar contribuição como paga: $e', Colors.red);
    }
  }

  Future<void> _editarContribuicao(Contribuicao contribuicao) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => ContribuicaoFormModal(contribuicao: contribuicao),
    );

    if (resultado == true) {
      await _carregarDados();
    }
  }

  Future<void> _cancelarContribuicao(Contribuicao contribuicao) async {
    final motivo = await _mostrarDialogoObservacoes(
      'Cancelar Contribuição',
      'Informe o motivo do cancelamento:',
      obrigatorio: true,
    );

    if (motivo == null || motivo.isEmpty) return;

    try {
      final db = DatabaseService();
      final sucesso = await db.cancelarContribuicao(
        contribuicao.id!,
        motivoCancelamento: motivo,
      );

      if (sucesso) {
        _mostrarMensagem('Contribuição cancelada!', Colors.green);
        await _carregarDados();
      } else {
        _mostrarMensagem('Erro ao cancelar contribuição', Colors.red);
      }
    } catch (e) {
      _mostrarMensagem('Erro ao cancelar contribuição: $e', Colors.red);
    }
  }

  Future<bool> _mostrarDialogoConfirmacao(
    String titulo,
    String mensagem,
  ) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }

  Future<String?> _mostrarDialogoObservacoes(
    String titulo,
    String mensagem, {
    bool obrigatorio = false,
  }) async {
    final controller = TextEditingController();

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensagem),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Digite aqui...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final texto = controller.text.trim();
              if (obrigatorio && texto.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Campo obrigatório')),
                );
                return;
              }
              Navigator.pop(context, texto);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    return resultado;
  }

  void _mostrarDialogoCarregamento(String mensagem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(mensagem)),
          ],
        ),
      ),
    );
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: cor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pago':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pago':
        return 'Pago';
      case 'pendente':
        return 'Pendente';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contribuições Mensais'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _carregarDados,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtros e estatísticas
                _buildHeaderSection(),

                // Lista de contribuições
                Expanded(
                  child: _contribuicoes.isEmpty
                      ? _buildEmptyState()
                      : _buildContribuicoesList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _gerarContribuicoes,
        icon: const Icon(Icons.add),
        label: const Text('Gerar Contribuições'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Seletor de período
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _mesReferencia,
                  decoration: const InputDecoration(
                    labelText: 'Mês',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: List.generate(12, (index) {
                    final mes = index + 1;
                    return DropdownMenuItem(
                      value: mes,
                      child: Text(_meses[mes]),
                    );
                  }),
                  onChanged: (valor) {
                    setState(() => _mesReferencia = valor!);
                    _carregarDados();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _anoReferencia,
                  decoration: const InputDecoration(
                    labelText: 'Ano',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: List.generate(10, (index) {
                    final ano = DateTime.now().year - 5 + index;
                    return DropdownMenuItem(
                      value: ano,
                      child: Text(ano.toString()),
                    );
                  }),
                  onChanged: (valor) {
                    setState(() => _anoReferencia = valor!);
                    _carregarDados();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Estatísticas
          if (_estatisticas.isNotEmpty) _buildEstatisticasCards(),
        ],
      ),
    );
  }

  Widget _buildEstatisticasCards() {
    final totalGeral = _estatisticas['total_geral'] ?? {};
    final porStatus = _estatisticas['por_status'] ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildEstatisticaCard(
            'Total',
            '${totalGeral['quantidade'] ?? 0}',
            'R\$ ${(totalGeral['valor_total'] ?? 0.0).toStringAsFixed(2)}',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildEstatisticaCard(
            'Pagas',
            '${porStatus['pago']?['quantidade'] ?? 0}',
            'R\$ ${(porStatus['pago']?['valor_total'] ?? 0.0).toStringAsFixed(2)}',
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildEstatisticaCard(
            'Pendentes',
            '${porStatus['pendente']?['quantidade'] ?? 0}',
            'R\$ ${(porStatus['pendente']?['valor_total'] ?? 0.0).toStringAsFixed(2)}',
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildEstatisticaCard(
    String titulo,
    String quantidade,
    String valor,
    Color cor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 12,
                color: cor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              quantidade,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(valor, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monetization_on_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma contribuição encontrada',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'para ${_meses[_mesReferencia]}/$_anoReferencia',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _gerarContribuicoes,
            icon: const Icon(Icons.add),
            label: const Text('Gerar Contribuições'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContribuicoesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _contribuicoes.length,
      itemBuilder: (context, index) {
        final contribuicao = _contribuicoes[index];
        return _buildContribuicaoCard(contribuicao);
      },
    );
  }

  Widget _buildContribuicaoCard(Contribuicao contribuicao) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(contribuicao.status),
          child: Icon(
            contribuicao.isPago
                ? Icons.check
                : contribuicao.isCancelado
                ? Icons.close
                : Icons.schedule,
            color: Colors.white,
          ),
        ),
        title: Text(
          contribuicao.membroNome ?? 'Membro não encontrado',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('R\$ ${contribuicao.valor.toStringAsFixed(2)}'),
            Text(
              _getStatusText(contribuicao.status),
              style: TextStyle(
                color: _getStatusColor(contribuicao.status),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (contribuicao.dataPagamento != null)
              Text(
                'Pago em: ${contribuicao.dataPagamento!.day.toString().padLeft(2, '0')}/'
                '${contribuicao.dataPagamento!.month.toString().padLeft(2, '0')}/'
                '${contribuicao.dataPagamento!.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (contribuicao.observacoes != null &&
                contribuicao.observacoes!.isNotEmpty)
              Text(
                'Obs: ${contribuicao.observacoes}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (valor) {
            switch (valor) {
              case 'editar':
                _editarContribuicao(contribuicao);
                break;
              case 'pagar':
                _marcarComoPago(contribuicao);
                break;
              case 'cancelar':
                _cancelarContribuicao(contribuicao);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            if (contribuicao.isPendente) ...[
              const PopupMenuItem(
                value: 'pagar',
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Marcar como Pago'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cancelar',
                child: Row(
                  children: [
                    Icon(Icons.close, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cancelar'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
