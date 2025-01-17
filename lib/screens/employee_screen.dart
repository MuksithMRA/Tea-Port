import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tea_order.dart';
import '../providers/drink_selection_provider.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import 'login_screen.dart';

class EmployeeScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const EmployeeScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final OrderService orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Tea Service'),
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.signOut();
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            widget.userName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome,',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                widget.userName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Select your drink:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: screenSize.width > 600 ? 200 : 180,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildListDelegate([
                  _buildDrinkTile(DrinkType.tea, Icons.emoji_food_beverage, 'Tea'),
                  _buildDrinkTile(DrinkType.milkTea, Icons.coffee, 'Milk Tea'),
                  _buildDrinkTile(DrinkType.coffee, Icons.coffee_maker, 'Coffee'),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Orders',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildOrdersList(),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<DrinkSelectionProvider>(
        builder: (context, drinkProvider, _) {
          final bool isSelected = drinkProvider.selectedDrink != null;
          final double buttonHeight = screenSize.height * 0.08;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isSelected ? buttonHeight + bottomPadding : 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    SafeArea(
                      top: false,
                      child: SizedBox(
                        height: buttonHeight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.04,
                            vertical: buttonHeight * 0.15,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: buttonHeight * 0.3,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  _getDrinkIcon(drinkProvider.selectedDrink!),
                                  color: Theme.of(context).primaryColor,
                                  size: buttonHeight * 0.35,
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.04),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Drink',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: buttonHeight * 0.16,
                                      ),
                                    ),
                                    Text(
                                      drinkProvider.selectedDrink!.toString().split('.').last,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: buttonHeight * 0.22,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: buttonHeight * 0.7,
                                child: ElevatedButton.icon(
                                  onPressed: () => _placeOrder(context, drinkProvider),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Theme.of(context).primaryColor,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenSize.width * 0.04,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(buttonHeight * 0.35),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.add,
                                    size: buttonHeight * 0.3,
                                  ),
                                  label: Text(
                                    'Place Order',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: buttonHeight * 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrinkTile(DrinkType type, IconData icon, String title) {
    return Consumer<DrinkSelectionProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.selectedDrink == type;
        return Card(
          elevation: isSelected ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () => provider.selectDrink(isSelected ? null : type),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersList() {
    return StreamBuilder<List<TeaOrder>>(
      stream: orderService.getEmployeeOrders(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
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
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.no_drinks,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet\nSelect a drink to place an order!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final order = orders[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(order.status),
                      child: Icon(
                        _getDrinkIcon(order.drinkType),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      order.drinkType.toString().split('.').last,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
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
                        const SizedBox(height: 4),
                        Text(
                          'Ordered: ${_formatDateTime(order.orderTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: order.status == OrderStatus.pending
                        ? IconButton(
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                            ),
                            onPressed: () => _cancelOrder(order),
                          )
                        : null,
                  ),
                ),
              );
            },
            childCount: orders.length,
          ),
        );
      },
    );
  }

  Future<void> _placeOrder(BuildContext context, DrinkSelectionProvider drinkProvider) async {
    try {
      final order = TeaOrder(
        id: '',
        userId: widget.userId,
        userName: widget.userName,
        orderTime: DateTime.now(),
        status: OrderStatus.pending,
        drinkType: drinkProvider.selectedDrink!,
      );

      await orderService.createOrder(order);
      setState(() {});

      if (!mounted) return;
      drinkProvider.clearSelection();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order placed: ${drinkProvider.selectedDrink.toString().split('.').last}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelOrder(TeaOrder order) async {
    try {
      await orderService.cancelOrder(order.id);
      setState(() {});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
