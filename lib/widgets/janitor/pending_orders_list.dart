import 'package:flutter/material.dart';
import '../../models/tea_order.dart';
import '../../services/order_service.dart';
import 'pending_order_card.dart';

class PendingOrdersList extends StatelessWidget {
  final OrderService orderService;

  const PendingOrdersList({
    super.key,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TeaOrder>>(
      stream: orderService.getJanitorOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading orders:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.done_all,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No pending orders\nAll caught up!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return PendingOrderCard(
              order: order,
              orderService: orderService,
            );
          },
        );
      },
    );
  }
}
