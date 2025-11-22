import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/main_navigation/main_navigation_page.dart';
import 'injection_container.dart' as di;
import 'features/expenses/data/models/expense_model.dart';
import 'features/expenses/data/models/recurring_expense_model.dart';
import 'features/budget/data/models/budget_model.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(RecurringExpenseModelAdapter());

  final expenseBox = await Hive.openBox<ExpenseModel>('expensesBox');
  final budgetBox = await Hive.openBox<BudgetModel>('budgetsBox');
  final recurringExpenseBox = await Hive.openBox<RecurringExpenseModel>('recurringExpensesBox');

  // Initialize dependency injection
  await di.init(expenseBox, budgetBox, recurringExpenseBox);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.getIt<AuthBloc>()..add(const AuthCheckRequested()),
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // Base design size (iPhone X)
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Gastos Diarios',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          // Mostrar splash screen mientras verifica autenticación
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is Authenticated) {
          // Usuario autenticado - mostrar app principal
          return const MainNavigationPage();
        }

        // Usuario no autenticado - mostrar login
        return const LoginPage();
      },
    );
  }
}
