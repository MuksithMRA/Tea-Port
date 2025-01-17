import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import '../models/tea_order.dart';
import 'appwrite_service.dart';
import 'notification_service.dart'; // Import NotificationService

class OrderService {
  final AppwriteService _appwrite = AppwriteService();

  // Create a new order
  Future<void> createOrder(TeaOrder order) async {
    try {
      final documentId = ID.unique();
      final orderData = order.toMap();
      orderData['id'] = documentId; // Set the ID before creating the document

      await _appwrite.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ordersCollectionId,
        documentId: documentId,
        data: orderData,
      );

      // Send notification to janitors
      await NotificationService().sendJanitorNotification(order);
      
      print('Order created successfully with ID: $documentId'); // Debug print
    } catch (e) {
      print('Error creating order: $e'); // Debug print
      rethrow;
    }
  }

  // Get orders stream for employees
  Stream<List<TeaOrder>> getEmployeeOrders(String userId) async* {
    final realtime = _appwrite.realtime;
    
    try {
      // First, yield initial orders
      final initialOrders = await _getInitialOrders(userId);
      yield initialOrders;

      // Then listen to realtime updates
      await for (final event in realtime.subscribe([
        'databases.${AppwriteService.databaseId}.collections.${AppwriteService.ordersCollectionId}.documents'
      ]).stream) {
        print('Realtime event received: ${event.events}'); // Debug print
        
        // Handle different event types
        if (event.events.contains('databases.*.collections.*.documents.*.create') ||
            event.events.contains('databases.*.collections.*.documents.*.update') ||
            event.events.contains('databases.*.collections.*.documents.*.delete')) {
          // Fetch updated list after any change
          final updatedOrders = await _getInitialOrders(userId);
          yield updatedOrders;
        }
      }
    } catch (e) {
      print('Error in getEmployeeOrders: $e'); // Debug print
      rethrow;
    }
  }

  Future<List<TeaOrder>> _getInitialOrders(String userId) async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ordersCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('orderTime'),
        ],
      );

      print('Initial orders response: ${response.documents.length}'); // Debug print

      return response.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['\$id'] = doc.$id; // Add the document ID to the data
        print('Document data: $data'); // Debug print
        return TeaOrder.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting initial orders: $e'); // Debug print
      rethrow;
    }
  }

  List<TeaOrder> _handleRealtimeEvent(RealtimeMessage event, String userId) {
    try {
      final List<TeaOrder> orders = [];
      
      if (event.events.contains('databases.*.collections.*.documents.*')) {
        final payload = event.payload;
        if (payload['userId'] == userId) {
          orders.add(TeaOrder.fromMap(payload));
        }
      }

      return orders;
    } catch (e) {
      print('Error handling realtime event: $e'); // Debug print
      return [];
    }
  }

  // Get initial orders for janitor
  Future<List<TeaOrder>> _getInitialJanitorOrders() async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ordersCollectionId,
        queries: [
          Query.equal('status', [
            OrderStatus.pending.toString().split('.').last,
            OrderStatus.preparing.toString().split('.').last,
          ]),
          Query.orderDesc('orderTime'),
        ],
      );

      return response.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['\$id'] = doc.$id;
        return TeaOrder.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting initial janitor orders: $e'); // Debug print
      rethrow;
    }
  }

  // Get orders stream for janitor
  Stream<List<TeaOrder>> getJanitorOrders() async* {
    final realtime = _appwrite.realtime;
    
    try {
      // First, yield initial orders
      final initialOrders = await _getInitialJanitorOrders();
      yield initialOrders;

      // Then listen to realtime updates
      await for (final event in realtime.subscribe([
        'databases.${AppwriteService.databaseId}.collections.${AppwriteService.ordersCollectionId}.documents'
      ]).stream) {
        print('Janitor received realtime event: ${event.events}'); // Debug print
        
        // Handle different event types
        if (event.events.contains('databases.*.collections.*.documents.*.create') ||
            event.events.contains('databases.*.collections.*.documents.*.update') ||
            event.events.contains('databases.*.collections.*.documents.*.delete')) {
          // Fetch updated list after any change
          final updatedOrders = await _getInitialJanitorOrders();
          yield updatedOrders;
        }
      }
    } catch (e) {
      print('Error in getJanitorOrders: $e'); // Debug print
      rethrow;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      // First get the current order data
      final response = await _appwrite.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ordersCollectionId,
        documentId: orderId,
      );

      // Get the current data and remove system fields
      final currentData = Map<String, dynamic>.from(response.data);
      currentData.remove('\$id');
      currentData.remove('\$collectionId');
      currentData.remove('\$databaseId');
      currentData.remove('\$createdAt');
      currentData.remove('\$updatedAt');
      currentData.remove('\$permissions');
      
      // Update the status
      currentData['status'] = status.toString().split('.').last;

      // Update the document with cleaned data
      await _appwrite.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ordersCollectionId,
        documentId: orderId,
        data: currentData,
      );
      if (kDebugMode) {
        print('Order status updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating order status: $e');
      }
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, OrderStatus.cancelled);
      print('Order cancelled successfully'); // Debug print
    } catch (e) {
      print('Error cancelling order: $e'); // Debug print
      rethrow;
    }
  }

  // Get all orders (for admin)
  Future<List<TeaOrder>> getAllOrders() async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ordersCollectionId,
      );
      
      return response.documents.map((doc) => TeaOrder.fromMap(doc.data)).toList();
    } catch (e) {
      throw e;
    }
  }
}
