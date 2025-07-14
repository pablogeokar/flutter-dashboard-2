import 'package:flutter/material.dart';
import 'package:flutter_dashboard_2/screens/cadastros_screen.dart';
import 'package:flutter_dashboard_2/screens/configuracoes_screen.dart';
import 'package:flutter_dashboard_2/screens/dashboard_screen.dart';
import 'package:flutter_dashboard_2/screens/entradas_screen.dart';
import 'package:flutter_dashboard_2/screens/relatorios_screen.dart';
import 'package:flutter_dashboard_2/screens/saidas_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const EntradasScreen(),
    const SaidasScreen(),
    const RelatoriosScreen(),
    const CadastrosScreen(),
    const ConfiguracoesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            minWidth: 80,
            extended: true,
            backgroundColor: const Color(0xFF121212),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard, color: Colors.blue),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.arrow_downward),
                selectedIcon: Icon(Icons.arrow_downward, color: Colors.green),
                label: Text('Entradas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.arrow_upward),
                selectedIcon: Icon(Icons.arrow_upward, color: Colors.red),
                label: Text('Saídas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                selectedIcon: Icon(Icons.bar_chart, color: Colors.amber),
                label: Text('Relatórios'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.app_registration),
                selectedIcon: Icon(Icons.app_registration, color: Colors.blue),
                label: Text('Cadastros'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings, color: Colors.grey),
                label: Text('Configurações'),
              ),
            ],
          ),
          // Conteúdo principal
          Expanded(
            child: Column(
              children: [
                // AppBar
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/logo.png', height: 40),
                          const SizedBox(width: 16),
                          const Text(
                            'Compasso Fiscal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Icon(Icons.notifications, size: 24),
                          SizedBox(width: 16),
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage('assets/user.png'),
                          ),
                          SizedBox(width: 8),
                          Text('Mestre Financeiro'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Conteúdo da tela
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
