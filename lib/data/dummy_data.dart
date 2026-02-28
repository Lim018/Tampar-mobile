import 'models/transaction.dart';
import 'models/budget.dart';
import 'models/user_profile.dart';
import 'models/category.dart';

class DummyData {
  DummyData._();

  static const userProfile = UserProfile(
    name: 'Zoya Amirah',
    handle: '@zoya_hemat',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC-0tdOW6FBREKxiaCycGRthMvUtdONAI44Fsj8vIDaPoTHsSL59DZAYmN5Rtb1tE8exBJlXTCD0f2WkeOdNJi1eGgVzav7PA5ApTgLX5cGRd-WT3Z20v_gRg6oY9KU6fAe6y4QLYGt2qt0RueXBcD8Zz6VxYVzLvO8T3Iz_otCqB_W3bVMWnqXmDSNmTyzzqtc0qB4HolajWu3jPN7zUXn4uzxxufUijVKu2Df3tpLQArMMAzHvYBr_9Tq6Hu1lTyBaURV5zD7og3T',
    hematStreak: 12,
    savedAmount: 450000,
    financialScore: 72,
    income: 5000000,
    fixedExpense: 2150000,
  );

  static const budget = Budget(
    totalIncome: 5000000,
    fixedExpense: 1500000,
    debtExpense: 750000,
    freeBalance: 2450000,
  );

  static final transactions = [
    Transaction(
      id: '1',
      title: 'Kopi Senja Mahal',
      category: TransactionCategory.coffee,
      amount: 58000,
      date: DateTime.now(),
      aiRoast:
          '"Lagian ngopi doang seharga beras sekilo? Sadar diri bestie, dompetmu nangis."',
    ),
    Transaction(
      id: '2',
      title: 'Gojek ke Kantor',
      category: TransactionCategory.transport,
      amount: 24000,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: '3',
      title: 'Makan Siang Padang',
      category: TransactionCategory.food,
      amount: 35000,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: '4',
      title: 'Skincare The Ordinary',
      category: TransactionCategory.shopping,
      amount: 185000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      aiRoast:
          '"Skincare Rp185rb tapi tabungan masih kayak kulit kering—tipis banget."',
    ),
    Transaction(
      id: '5',
      title: 'Langganan Spotify',
      category: TransactionCategory.bills,
      amount: 55000,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // Spending chart data per category (percentage of bar height)
  static const spendingByCategory = {
    'Makan': 0.65,
    'Trans': 0.85,
    'Hobby': 0.40,
    'Tagihan': 0.25,
  };

  // AI roasting texts for demo
  static const roastTexts = [
    'Rp85.000 buat kopi premium padahal gaji tinggal 12%?',
    'Bestie, kamu serius?',
  ];

  // Scan receipt dummy result
  static const scanReceiptItems = [
    {'name': 'Nasi Goreng Spesial', 'price': 25000},
    {'name': 'Es Teh Manis', 'price': 5000},
    {'name': 'Kerupuk', 'price': 3000},
    {'name': 'Tahu Goreng (2x)', 'price': 8000},
  ];
}
