import 'package:flutter/material.dart';

enum TransactionCategory {
  food('Makan', Icons.restaurant, Color(0xFFFB923C), Color(0xFFFFF7ED)),
  transport(
    'Transport',
    Icons.directions_car,
    Color(0xFF3B82F6),
    Color(0xFFEFF6FF),
  ),
  shopping('Belanja', Icons.shopping_bag, Color(0xFFA855F7), Color(0xFFFAF5FF)),
  hobby('Hobby', Icons.sports_esports, Color(0xFF14B8A6), Color(0xFFF0FDFA)),
  bills('Tagihan', Icons.receipt_long, Color(0xFF6366F1), Color(0xFFEEF2FF)),
  coffee('Kopi', Icons.local_cafe, Color(0xFFFB923C), Color(0xFFFFF7ED));

  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const TransactionCategory(this.label, this.icon, this.color, this.bgColor);
}
