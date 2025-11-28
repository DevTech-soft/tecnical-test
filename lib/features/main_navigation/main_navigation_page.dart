import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../expenses/presentation/pages/home_page.dart';
import '../budget/presentation/pages/budget_page.dart';
import '../analytics/presentation/pages/analytics_page.dart';
import '../accounts/presentation/pages/accounts_page.dart';
import '../../core/theme/app_colors.dart';
import '../../core/usecases/usecase.dart';
import '../../injection_container.dart';
import '../expenses/domain/usecases/generate_expenses_from_recurring.dart';
import '../expenses/presentation/blocs/category_bloc.dart';
import '../expenses/presentation/blocs/category_event.dart';
import '../accounts/presentation/bloc/account_bloc.dart';
import '../accounts/presentation/bloc/account_event.dart';
import '../../core/utils/app_logger.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<CategoryBloc>()..add(const LoadCategories()),
        ),
        BlocProvider(
          create: (context) => sl<AccountBloc>()..add(LoadAccounts()),
        ),
      ],
      child: const _MainNavigationPageContent(),
    );
  }
}

class _MainNavigationPageContent extends StatefulWidget {
  const _MainNavigationPageContent();

  @override
  State<_MainNavigationPageContent> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<_MainNavigationPageContent> {
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
    // Sincronizar todos los datos con Firebase cuando el usuario entra
    _syncAllData();
    // Generar gastos desde recurrencias al iniciar la app
    _generateRecurringExpenses();
  }

  /// Sincroniza todos los datos locales con Firebase
  Future<void> _syncAllData() async {
    try {
      _logger.info('Iniciando sincronización completa de datos con Firebase');

      // Sincronizar categorías (esto también inicializará las predefinidas si no existen)
      context.read<CategoryBloc>().add(const InitializeDefaultCategoriesEvent());

      // Las demás colecciones se sincronizarán automáticamente cuando se llamen
      // sus respectivos métodos getAllXXX() gracias al patrón offline-first

      _logger.info('Sincronización de datos iniciada correctamente');
    } catch (e, stackTrace) {
      _logger.error('Error al sincronizar datos', e, stackTrace);
    }
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
