class UserProfile {
  final String name;
  final String handle;
  final String avatarUrl;
  final int hematStreak;
  final int savedAmount;
  final int financialScore;
  final int income;
  final int fixedExpense;

  const UserProfile({
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.hematStreak,
    required this.savedAmount,
    required this.financialScore,
    required this.income,
    required this.fixedExpense,
  });
}
