import 'package:flutter/material.dart';
import '../models/tea_order.dart';

IconData getDrinkIcon(DrinkType type) {
  switch (type) {
    case DrinkType.tea:
      return Icons.emoji_food_beverage;
    case DrinkType.milkTea:
      return Icons.coffee;
    case DrinkType.coffee:
      return Icons.coffee_maker;
  }
}

Color getStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Colors.orange;
    case OrderStatus.preparing:
      return Colors.blue;
    case OrderStatus.completed:
      return Colors.green;
    case OrderStatus.cancelled:
      return Colors.red;
  }
}

String formatDateTime(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
