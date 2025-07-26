import 'package:flutter/material.dart';
import 'package:flutter_dashboard_2/screens/cadastros_screen.dart';
import 'package:flutter_dashboard_2/screens/configuracoes_screen.dart';
import 'package:flutter_dashboard_2/screens/contribuicoes_screen.dart';
import 'package:flutter_dashboard_2/screens/dashboard_screen.dart';
import 'package:flutter_dashboard_2/screens/entradas_screen.dart';
import 'package:flutter_dashboard_2/screens/membros_list_screen.dart';
import 'package:flutter_dashboard_2/screens/relatorios_screen.dart';
import 'package:flutter_dashboard_2/screens/saidas_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainLayout> {
  int _selectedIndex = 0;
  String _appVersion = '';

  // Dados dos itens de navegação centralizados
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      screen: DashboardScreen(),
      title: 'Dashboard',
      icon: Icons.dashboard,
      color: Colors.blue,
    ),
    NavigationItem(
      screen: MembrosListScreen(),
      title: 'Membros',
      icon: Icons.people,
      color: Color(0xFF00BCD4),
    ),
    NavigationItem(
      screen: ContribuicoesScreen(),
      title: 'Contribuições',
      icon: Icons.monetization_on,
      color: Colors.lightGreen,
    ),
    NavigationItem(
      screen: EntradasScreen(),
      title: 'Entradas',
      icon: Icons.trending_up,
      color: Colors.green,
    ),
    NavigationItem(
      screen: SaidasScreen(),
      title: 'Saídas',
      icon: Icons.trending_down,
      color: Colors.red,
    ),
    NavigationItem(
      screen: RelatoriosScreen(),
      title: 'Relatórios',
      icon: Icons.analytics,
      color: Colors.amber,
    ),
    NavigationItem(
      screen: CadastrosScreen(),
      title: 'Cadastros',
      icon: Icons.people,
      color: Colors.purple,
    ),
    NavigationItem(
      screen: ConfiguracoesScreen(),
      title: 'Configurações',
      icon: Icons.settings,
      color: Colors.grey,
    ),
  ];

  NavigationItem get _currentItem => _navigationItems[_selectedIndex];

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: _currentItem.screen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
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
          _buildSidebarHeader(),
          _buildDivider(),
          const SizedBox(height: 24),
          _buildNavigationMenu(),
          _buildUserInfo(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Image.asset('assets/logo.png', height: 128, width: 128),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Gestão Financeira',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (_appVersion.isNotEmpty) ...[
                const SizedBox(height: 2, width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _appVersion,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 1,
      color: AppColors.border,
    );
  }

  Widget _buildNavigationMenu() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _navigationItems.length,
        itemBuilder: (context, index) => _buildNavItem(index),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _selectedIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? item.color.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: item.color.withValues(alpha: 0.2))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? item.color : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  item.title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
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
                      color: item.color,
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

  Widget _buildUserInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildAppBarTitle(), _buildAppBarActions()],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Icon(_currentItem.icon, color: _currentItem.color, size: 24),
        const SizedBox(width: 12),
        Text(
          _currentItem.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarActions() {
    return Row(
      children: [
        _buildCompanyInfo(),
        const SizedBox(width: 16),
        ..._buildActionButtons(),
      ],
    );
  }

  Widget _buildCompanyInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Aug∴ e Resp∴ Loja Simb∴ Harmonia, Luz e Sigilo nº 46',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          'CNPJ: 12.345.678/0001-90',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons() {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {},
        color: AppColors.textSecondary,
      ),
      const SizedBox(width: 8),
      _buildNotificationButton(),
      const SizedBox(width: 16),
      IconButton(
        icon: const Icon(Icons.fullscreen),
        onPressed: () {},
        color: AppColors.textSecondary,
      ),
    ];
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
          color: AppColors.textSecondary,
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
    );
  }
}

// Classe para encapsular dados de navegação
class NavigationItem {
  final Widget screen;
  final String title;
  final IconData icon;
  final Color color;

  const NavigationItem({
    required this.screen,
    required this.title,
    required this.icon,
    required this.color,
  });
}

// Classe para centralizar cores
class AppColors {
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF424242);
  static final Color textSecondary = Colors.grey[700]!;
}
