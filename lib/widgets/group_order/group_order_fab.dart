import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_order_provider.dart';
import '../../services/auth_service.dart';
import 'group_order_sheet.dart';

class GroupOrderFAB extends StatelessWidget {
  const GroupOrderFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GroupOrderProvider, AuthService>(
      builder: (context, groupOrderProvider, authProvider, _) {
        final hasActiveOrder = groupOrderProvider.hasActiveGroupOrder;
        final user = authProvider.userData;

        if (user == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: FloatingActionButton.extended(
            onPressed: () {
              if (hasActiveOrder) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const GroupOrderSheet(),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Start Group Order'),
                    content: const Text(
                      'Would you like to start a group order? Others will be able to add their drinks to your order.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          groupOrderProvider.createGroupOrder(
                            creatorId: user.uid,
                            creatorName: user.name,
                          );
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const GroupOrderSheet(),
                          );
                        },
                        child: const Text('Start'),
                      ),
                    ],
                  ),
                );
              }
            },
            backgroundColor: hasActiveOrder ? Colors.orange : Colors.blue,
            label: Text(
              hasActiveOrder ? 'View Group Order' : 'Start Group Order',
            ),
            icon: Icon(
              hasActiveOrder ? Icons.group : Icons.group_add,
            ),
          ),
        );
      },
    );
  }
}
