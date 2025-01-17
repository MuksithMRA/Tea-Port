enum OrderStatus { pending, preparing, completed, cancelled }

enum DrinkType { tea, milkTea, coffee }

class TeaOrder {
  final String id;
  final String userId;
  final String userName;
  final DateTime orderTime;
  final OrderStatus status;
  final DrinkType drinkType;
  final bool isScheduled;
  final DateTime? scheduledTime;

  TeaOrder({
    required this.id,
    required this.userId,
    required this.userName,
    required this.orderTime,
    required this.status,
    required this.drinkType,
    this.isScheduled = false,
    this.scheduledTime,
  });

  factory TeaOrder.fromMap(Map<String, dynamic> map) {
    return TeaOrder(
      id: map['\$id'] ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      orderTime: DateTime.parse(map['orderTime']),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      drinkType: map['drinkType'] != null 
          ? DrinkType.values.firstWhere(
              (e) => e.toString().split('.').last == map['drinkType'],
              orElse: () => DrinkType.tea,
            )
          : DrinkType.tea,
      isScheduled: map['isScheduled'] ?? false,
      scheduledTime: map['scheduledTime'] != null
          ? DateTime.parse(map['scheduledTime'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'userId': userId,
      'userName': userName,
      'orderTime': orderTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'drinkType': drinkType.toString().split('.').last,
      'isScheduled': isScheduled,
    };

    if (scheduledTime != null) {
      map['scheduledTime'] = scheduledTime!.toIso8601String();
    }

    return map;
  }
}
