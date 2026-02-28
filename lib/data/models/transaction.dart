import 'category.dart';

class Transaction {
  final String id;
  final String title;
  final TransactionCategory category;
  final int amount;
  final DateTime date;
  final String? aiRoast;

  const Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.aiRoast,
  });
}
