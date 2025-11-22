import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'core/services/export_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/user_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in_with_email.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up_with_email.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/expenses/data/datasources/expense_local_datasource.dart';
import 'features/expenses/data/datasources/expense_remote_datasource.dart';
import 'features/expenses/data/datasources/recurring_expense_local_datasource.dart';
import 'features/expenses/data/repositories/expense_repository_impl.dart';
import 'features/expenses/data/repositories/recurring_expense_repository_impl.dart';
import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/expenses/domain/repositories/recurring_expense_repository.dart';
import 'features/expenses/domain/usecases/get_all_expenses.dart';
import 'features/expenses/domain/usecases/add_expense.dart';
import 'features/expenses/domain/usecases/delete_expense.dart';
import 'features/expenses/domain/usecases/update_expense.dart';
import 'features/expenses/domain/usecases/search_expenses.dart';
import 'features/expenses/domain/usecases/create_recurring_expense.dart';
import 'features/expenses/domain/usecases/get_all_recurring_expenses.dart';
import 'features/expenses/domain/usecases/update_recurring_expense.dart';
import 'features/expenses/domain/usecases/delete_recurring_expense.dart';
import 'features/expenses/domain/usecases/generate_expenses_from_recurring.dart';
import 'features/expenses/presentation/blocs/expenses_bloc.dart';
import 'features/expenses/presentation/blocs/filter_bloc.dart';
import 'features/expenses/presentation/blocs/recurring_expenses_bloc.dart';
import 'features/expenses/data/models/expense_model.dart';
import 'features/expenses/data/models/recurring_expense_model.dart';
import 'features/budget/data/datasources/budget_local_datasource.dart';
import 'features/budget/data/repositories/budget_repository_impl.dart';
import 'features/budget/domain/repositories/budget_repository.dart';
import 'features/budget/domain/usecases/create_budget.dart';
import 'features/budget/domain/usecases/get_current_budget.dart';
import 'features/budget/domain/usecases/update_budget.dart';
import 'features/budget/domain/usecases/delete_budget.dart';
import 'features/budget/domain/usecases/calculate_budget_status.dart';
import 'features/budget/presentation/bloc/budget_bloc.dart';
import 'features/budget/data/models/budget_model.dart';
import 'features/export/domain/usecases/export_expenses_csv.dart';
import 'features/export/domain/usecases/export_expenses_pdf.dart';
import 'features/export/domain/usecases/import_expenses_csv.dart';
import 'features/export/domain/usecases/share_export.dart';
import 'features/export/presentation/bloc/export_bloc.dart';


final sl = GetIt.instance;
// Alias para compatibilidad
final getIt = sl;


Future<void> init(
  Box<ExpenseModel> expenseBox,
  Box<BudgetModel> budgetBox,
  Box<RecurringExpenseModel> recurringExpenseBox,
) async {
// datasources - Expenses
sl.registerLazySingleton<ExpenseLocalDataSource>(() => ExpenseLocalDataSourceImpl(expenseBox));
sl.registerLazySingleton<ExpenseRemoteDataSource>(() => ExpenseRemoteDataSourceImpl());
sl.registerLazySingleton<RecurringExpenseLocalDataSource>(
  () => RecurringExpenseLocalDataSourceImpl(recurringExpenseBox),
);

// datasources - Budget
sl.registerLazySingleton<BudgetLocalDataSource>(() => BudgetLocalDataSourceImpl(budgetBox: budgetBox));


// repositories - Expenses
sl.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl(
  local: sl(),
  remote: sl(),
  authRepository: sl(),
));

// repositories - Budget
sl.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl(localDataSource: sl()));

// repositories - Recurring Expenses
sl.registerLazySingleton<RecurringExpenseRepository>(
  () => RecurringExpenseRepositoryImpl(localDataSource: sl()),
);


// usecases - Expenses
sl.registerLazySingleton(() => GetAllExpenses(sl()));
sl.registerLazySingleton(() => AddExpense(sl()));
sl.registerLazySingleton(() => DeleteExpense(sl()));
sl.registerLazySingleton(() => UpdateExpense(sl()));
sl.registerLazySingleton(() => SearchExpenses(sl()));

// usecases - Budget
sl.registerLazySingleton(() => CreateBudget(sl()));
sl.registerLazySingleton(() => GetCurrentBudget(sl()));
sl.registerLazySingleton(() => UpdateBudget(sl()));
sl.registerLazySingleton(() => DeleteBudget(sl()));
sl.registerLazySingleton(() => CalculateBudgetStatus(sl())); // usa ExpenseRepository

// usecases - Recurring Expenses
sl.registerLazySingleton(() => CreateRecurringExpense(sl()));
sl.registerLazySingleton(() => GetAllRecurringExpenses(sl()));
sl.registerLazySingleton(() => UpdateRecurringExpense(sl()));
sl.registerLazySingleton(() => DeleteRecurringExpense(sl()));
sl.registerLazySingleton(() => GenerateExpensesFromRecurring(
  recurringRepository: sl(),
  expenseRepository: sl(),
));


// blocs - Expenses
sl.registerFactory(() => ExpensesBloc(getAll: sl(), addExpense: sl(), deleteExpense: sl(), updateExpense: sl()));
sl.registerFactory(() => FilterBloc(searchExpenses: sl()));
sl.registerFactory(() => RecurringExpensesBloc(
  getAllRecurringExpenses: sl(),
  createRecurringExpense: sl(),
  updateRecurringExpense: sl(),
  deleteRecurringExpense: sl(),
  generateExpensesFromRecurring: sl(),
));

// blocs - Budget
sl.registerFactory(() => BudgetBloc(
  createBudgetUseCase: sl(),
  getCurrentBudgetUseCase: sl(),
  updateBudgetUseCase: sl(),
  deleteBudgetUseCase: sl(),
  calculateBudgetStatusUseCase: sl(),
));

// services - Export
sl.registerLazySingleton(() => ExportService());

// usecases - Export
sl.registerLazySingleton(() => ExportExpensesCsv(sl()));
sl.registerLazySingleton(() => ExportExpensesPdf(sl()));
sl.registerLazySingleton(() => ImportExpensesCsv(sl()));
sl.registerLazySingleton(() => ShareExport(sl()));

// blocs - Export
sl.registerFactory(() => ExportBloc(
  exportExpensesCsv: sl(),
  exportExpensesPdf: sl(),
  shareExport: sl(),
  importExpensesCsv: sl(),
));

// datasources - Auth
sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl());

// repositories - Auth
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
  remoteDataSource: sl(),
  userRemoteDataSource: sl(),
));

// usecases - Auth
sl.registerLazySingleton(() => GetCurrentUser(sl()));
sl.registerLazySingleton(() => SignInWithEmail(sl()));
sl.registerLazySingleton(() => SignUpWithEmail(sl()));
sl.registerLazySingleton(() => SignInWithGoogle(sl()));
sl.registerLazySingleton(() => SignOut(sl()));

// blocs - Auth
sl.registerFactory(() => AuthBloc(
  getCurrentUser: sl(),
  signInWithEmail: sl(),
  signUpWithEmail: sl(),
  signInWithGoogle: sl(),
  signOut: sl(),
));
}