import 'package:flutter/material.dart';

class TabelaMovimentacoes extends StatelessWidget {
  final List<Movimentacao> movimentacoes;

  const TabelaMovimentacoes({super.key, required this.movimentacoes});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Data')),
          DataColumn(label: Text('Descrição')),
          DataColumn(label: Text('Valor'), numeric: true),
          DataColumn(label: Text('Categoria')),
          DataColumn(label: Text('Tipo')),
        ],
        rows: movimentacoes.map((mov) {
          return DataRow(
            cells: [
              DataCell(Text(mov.data)),
              DataCell(Text(mov.descricao)),
              DataCell(Text('R\$ ${mov.valor.toStringAsFixed(2)}')),
              DataCell(Text(mov.categoria)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: mov.tipo == 'Entrada'
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mov.tipo,
                    style: TextStyle(
                      color: mov.tipo == 'Entrada' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class Movimentacao {
  final String data;
  final String descricao;
  final double valor;
  final String categoria;
  final String tipo;

  Movimentacao({
    required this.data,
    required this.descricao,
    required this.valor,
    required this.categoria,
    required this.tipo,
  });
}
