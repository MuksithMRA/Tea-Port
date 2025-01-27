import 'package:flutter/foundation.dart';
import 'package:tea_port/models/group_order.dart';
import 'package:tea_port/models/tea_order.dart';

class GroupOrderProvider extends ChangeNotifier {
  GroupOrder? _activeGroupOrder;
  List<GroupOrder> _pastGroupOrders = [];

  GroupOrder? get activeGroupOrder => _activeGroupOrder;
  List<GroupOrder> get pastGroupOrders => _pastGroupOrders;

  void createGroupOrder({
    required String creatorId,
    required String creatorName,
    String? note,
  }) {
    _activeGroupOrder = GroupOrder.create(
      creatorId: creatorId,
      creatorName: creatorName,
      note: note,
    );
    notifyListeners();
  }

  void addOrderToGroup(TeaOrder order) {
    if (_activeGroupOrder == null) return;

    final updatedOrders = [..._activeGroupOrder!.orders, order];
    _activeGroupOrder = _activeGroupOrder!.copyWith(orders: updatedOrders);
    notifyListeners();
  }

  void finalizeGroupOrder() {
    if (_activeGroupOrder == null) return;

    _pastGroupOrders = [
      _activeGroupOrder!.copyWith(isActive: false),
      ..._pastGroupOrders,
    ];
    _activeGroupOrder = null;
    notifyListeners();
  }

  void cancelGroupOrder() {
    _activeGroupOrder = null;
    notifyListeners();
  }

  bool get hasActiveGroupOrder => _activeGroupOrder != null;
}
