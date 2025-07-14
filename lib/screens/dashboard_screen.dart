import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_dashboard_2/components/card_financeiro.dart';
import 'package:flutter_dashboard_2/components/tabela_movimentacoes.dart';
import 'package:flutter_dashboard_2/screens/relatorios_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtros de período
          const PeriodoFilter(),
          const SizedBox(height: 24),
          // Cards de resumo
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2,
            children: const [
              CardFinanceiro(
                titulo: 'Saldo Atual',
                valor: 'R\$ 12.450,00',
                icone: Icons.account_balance_wallet,
                cor: Colors.blue,
              ),
              CardFinanceiro(
                titulo: 'Total Entradas',
                valor: 'R\$ 8.200,00',
                icone: Icons.arrow_downward,
                cor: Colors.green,
              ),
              CardFinanceiro(
                titulo: 'Total Saídas',
                valor: 'R\$ 3.750,00',
                icone: Icons.arrow_upward,
                cor: Colors.red,
              ),
              CardFinanceiro(
                titulo: 'Resultado Mês',
                valor: 'R\$ 4.450,00',
                icone: Icons.trending_up,
                cor: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Gráficos
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Entradas e Saídas por Categoria',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 300,
                            child: SfCircularChart(
                              legend: Legend(
                                isVisible: true,
                                position: LegendPosition.bottom,
                                overflowMode: LegendItemOverflowMode.wrap,
                              ),
                              series: <CircularSeries<ChartData, String>>[
                                PieSeries<ChartData, String>(
                                  dataSource: [
                                    ChartData(
                                      'Mensalidade',
                                      5200,
                                      Colors.green,
                                    ),
                                    ChartData('Eventos', 1800, Colors.blue),
                                    ChartData('Doações', 1200, Colors.amber),
                                    ChartData('Manutenção', 2100, Colors.red),
                                    ChartData('Outros', 900, Colors.purple),
                                  ],
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) => data.y,
                                  pointColorMapper: (ChartData data, _) =>
                                      data.color,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fluxo Mensal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              series: <CartesianSeries<ChartData, String>>[
                                ColumnSeries<ChartData, String>(
                                  dataSource: [
                                    ChartData('Jan', 4200, Colors.green),
                                    ChartData('Fev', 3800, Colors.green),
                                    ChartData('Mar', 5200, Colors.green),
                                    ChartData('Abr', 4800, Colors.green),
                                    ChartData('Mai', 4500, Colors.green),
                                    ChartData('Jun', 5100, Colors.green),
                                  ],
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) => data.y,
                                  color: Colors.green,
                                ),
                                ColumnSeries<ChartData, String>(
                                  dataSource: [
                                    ChartData('Jan', 2100, Colors.red),
                                    ChartData('Fev', 1800, Colors.red),
                                    ChartData('Mar', 2500, Colors.red),
                                    ChartData('Abr', 2200, Colors.red),
                                    ChartData('Mai', 1900, Colors.red),
                                    ChartData('Jun', 2300, Colors.red),
                                  ],
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) => data.y,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Últimas Movimentações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TabelaMovimentacoes(
                        movimentacoes: [
                          Movimentacao(
                            data: '15/06/2023',
                            descricao: 'Mensalidade - Irmão João',
                            valor: 250.00,
                            categoria: 'Mensalidade',
                            tipo: 'Entrada',
                          ),
                          Movimentacao(
                            data: '12/06/2023',
                            descricao: 'Reparos na sede',
                            valor: 850.00,
                            categoria: 'Manutenção',
                            tipo: 'Saída',
                          ),
                          Movimentacao(
                            data: '10/06/2023',
                            descricao: 'Doação - Loja Irmãos Unidos',
                            valor: 500.00,
                            categoria: 'Doações',
                            tipo: 'Entrada',
                          ),
                          Movimentacao(
                            data: '05/06/2023',
                            descricao: 'Evento de Confraternização',
                            valor: 1200.00,
                            categoria: 'Eventos',
                            tipo: 'Saída',
                          ),
                          Movimentacao(
                            data: '01/06/2023',
                            descricao: 'Mensalidade - Irmão Pedro',
                            valor: 250.00,
                            categoria: 'Mensalidade',
                            tipo: 'Entrada',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
