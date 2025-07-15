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

  final List<String> _screenTitles = [
    'Dashboard',
    'Entradas',
    'Saídas',
    'Relatórios',
    'Cadastros',
    'Configurações',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Row(
        children: [
          // Sidebar melhorada
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border(
                right: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo e título na sidebar
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo maior
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 128,
                          width: 128,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Compasso Fiscal',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestão Financeira',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 1,
                  color: Colors.grey[800],
                ),

                const SizedBox(height: 24),

                // Menu de navegação
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildNavItem(
                        0,
                        Icons.dashboard,
                        'Dashboard',
                        Colors.blue,
                      ),
                      _buildNavItem(
                        1,
                        Icons.trending_up,
                        'Entradas',
                        Colors.green,
                      ),
                      _buildNavItem(
                        2,
                        Icons.trending_down,
                        'Saídas',
                        Colors.red,
                      ),
                      _buildNavItem(
                        3,
                        Icons.analytics,
                        'Relatórios',
                        Colors.amber,
                      ),
                      _buildNavItem(
                        4,
                        Icons.people,
                        'Cadastros',
                        Colors.purple,
                      ),
                      _buildNavItem(
                        5,
                        Icons.settings,
                        'Configurações',
                        Colors.grey,
                      ),
                    ],
                  ),
                ),

                // Informações do usuário na parte inferior
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/user.png'),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Antonio Neto',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Tesoureiro',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
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

          // Conteúdo principal
          Expanded(
            child: Column(
              children: [
                // AppBar simplificada
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Título da tela atual
                      Row(
                        children: [
                          Text(
                            _screenTitles[_selectedIndex],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // Ações do header
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Aug∴ e Resp∴ Loja Simb∴ Harmonia, Luz e Sigilo nº 46',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'CNPJ: 12.345.678/0001-90',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {},
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 8),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () {},
                                color: Colors.grey[400],
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.fullscreen),
                            onPressed: () {},
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Conteúdo da tela
                Expanded(
                  child: Container(
                    color: const Color(0xFF0F0F0F),
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color color) {
    final bool isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: color.withValues(alpha: 0.2), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? color : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
