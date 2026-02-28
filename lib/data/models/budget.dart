class Budget {
  final int totalIncome;
  final int fixedExpense;
  final int debtExpense;
  final int freeBalance;

  const Budget({
    required this.totalIncome,
    required this.fixedExpense,
    required this.debtExpense,
    required this.freeBalance,
  });

  int get totalExpense => fixedExpense + debtExpense;
  int get totalAllocated => fixedExpense + debtExpense + freeBalance;

  double get fixedPercent => fixedExpense / totalIncome * 100;
  double get debtPercent => debtExpense / totalIncome * 100;
  double get freePercent => freeBalance / totalIncome * 100;
}
