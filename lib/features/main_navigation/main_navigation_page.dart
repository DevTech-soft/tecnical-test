import 'package:flutter/material.dart';
import '../expenses/presentation/pages/home_page.dart';
import '../budget/presentation/pages/budget_page.dart';
import '../analytics/presentation/pages/analytics_page.dart';
import '../accounts/presentation/pages/accounts_page.dart';
import '../../core/theme/app_colors.dart';
import '../../core/usecases/usecase.dart';
import '../../injection_container.dart';
import '../expenses/domain/usecases/generate_expenses_from_recurring.dart';
import '../../core/utils/app_logger.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  final _logger = AppLogger('MainNavigationPage');

  final List<Widget> _pages = [
    const HomePage(),
    const BudgetPage(),
    const AnalyticsPage(),
    const AccountsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Generar gastos desde recurrencias al iniciar la app
    _generateRecurringExpenses();
  }

  Future<void> _generateRecurringExpenses() async {
    try {
      _logger.info('Iniciando generación automática de gastos recurrentes');
      final generateExpenses = sl<GenerateExpensesFromRecurring>();
      final count = await generateExpenses(NoParams());

      if (count > 0) {
        _logger.info('Se generaron $count gasto(s) automáticamente');
        // Mostrar notificación al usuario
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Se generaron $count gasto(s) recurrente(s)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        _logger.info('No hay gastos recurrentes pendientes de generar');
      }
    } catch (e, stackTrace) {
      _logger.error('Error generando gastos recurrentes automáticamente', e, stackTrace);
      // No mostrar error al usuario para no interrumpir el flujo
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet_outlined),
              activeIcon: Icon(Icons.wallet),
              label: 'Presupuestos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Análisis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Cuentas',
            ),
          ],
        ),
      ),
    );
  }
}
