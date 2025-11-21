import '../../../../core/validators/input_validators.dart';
import '../repositories/expense_repository.dart';
import '../entities/expense.dart';

class AddExpense {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  Future<void> call(Expense expense) async {
    // Validar datos antes de guardar
    _validateExpense(expense);

    // Si pasa la validación, guardar el gasto
    await repository.addExpense(expense);
  }

  void _validateExpense(Expense expense) {
    // Validar monto
    InputValidators.validateAmount(expense.amount);

    // Validar fecha (no debe ser futura)
    InputValidators.validateDate(expense.date, allowFuture: false);

    // Validar categoría
    InputValidators.validateCategoryId(expense.categoryId);

    // Validar y sanitizar nota (opcional, pero si existe debe ser válido)
    if (expense.note != null && expense.note!.isNotEmpty) {
      InputValidators.validateAndSanitizeText(
        expense.note,
        fieldName: 'nota',
        required: false,
        maxLength: 500,
      );
    }
  }
}