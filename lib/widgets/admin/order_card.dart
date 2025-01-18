import 'package:flutter/material.dart';
import '../../models/tea_order.dart';

class AdminOrderCard extends StatelessWidget {
  final TeaOrder order;

  const AdminOrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status),
          child: Icon(
            _getDrinkIcon(order.drinkType),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          order.userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Ordered: ${_formatDateTime(order.orderTime)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            order.status.toString().split('.').last,
            style: TextStyle(
              color: _getStatusColor(order.status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(OrderStatus status) {
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

  IconData _getDrinkIcon(DrinkType type) {
    switch (type) {
      case DrinkType.tea:
        return Icons.emoji_food_beverage;
      case DrinkType.milkTea:
        return Icons.coffee;
      case DrinkType.coffee:
        return Icons.coffee_maker;
    }
  }
}
