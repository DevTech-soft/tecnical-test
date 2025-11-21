part of 'expenses_bloc.dart';


abstract class ExpensesEvent {}


class LoadExpensesEvent extends ExpensesEvent {}


class AddExpenseEvent extends ExpensesEvent {
final Expense expense;
AddExpenseEvent(this.expense);
}


class DeleteExpenseEvent extends ExpensesEvent {
final String id;
DeleteExpenseEvent(this.id);
}

class UpdateExpenseEvent extends ExpensesEvent {
final Expense expense;
UpdateExpenseEvent(this.expense);
}