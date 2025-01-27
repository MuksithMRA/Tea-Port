import 'package:tea_port/models/tea_order.dart';

class GroupOrder {
  final String id;
  final String creatorId;
  final String creatorName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<TeaOrder> orders;
  final bool isActive;
  final String? note;

  GroupOrder({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    required this.expiresAt,
    required this.orders,
    required this.isActive,
    this.note,
  });

  factory GroupOrder.create({
    required String creatorId,
    required String creatorName,
    String? note,
  }) {
    return GroupOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      creatorId: creatorId,
      creatorName: creatorName,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      orders: [],
      isActive: true,
      note: note,
    );
  }

  GroupOrder copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<TeaOrder>? orders,
    bool? isActive,
    String? note,
  }) {
    return GroupOrder(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      orders: orders ?? this.orders,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'orders': orders.map((order) => order.toMap()).toList(),
      'isActive': isActive,
      'note': note,
    };
  }

  factory GroupOrder.fromMap(Map<String, dynamic> json) {
    return GroupOrder(
      id: json['id'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      orders: (json['orders'] as List)
          .map((order) => TeaOrder.fromMap(order))
          .toList(),
      isActive: json['isActive'],
      note: json['note'],
    );
  }
}
