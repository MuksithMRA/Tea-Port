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
      
      debugPrint('Order created successfully with ID: $documentId'); // Debug print
    } catch (e) {
      debugPrint('Error creating order: $e'); // Debug print
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
        debugPrint('Realtime event received: ${event.events}'); // Debug print
        
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
      debugPrint('Error in getEmployeeOrders: $e'); // Debug print
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

      debugPrint('Initial orders response: ${response.documents.length}'); // Debug print

      return response.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['\$id'] = doc.$id; // Add the document ID to the data
        debugPrint('Document data: $data'); // Debug print
        return TeaOrder.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting initial orders: $e'); // Debug print
      rethrow;
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
      debugPrint('Error getting initial janitor orders: $e'); // Debug print
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
        debugPrint('Janitor received realtime event: ${event.events}'); // Debug print
        
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
      debugPrint('Error in getJanitorOrders: $e'); // Debug print
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

      // Send notification to the employee
      final order = TeaOrder.fromMap({...currentData, 'id': orderId});
      await NotificationService().sendOrderStatusNotification(order);
      
      if (kDebugMode) {
        debugPrint('Order status updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating order status: $e');
      }
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, OrderStatus.cancelled);
      debugPrint('Order cancelled successfully'); // Debug print
    } catch (e) {
      debugPrint('Error cancelling order: $e'); // Debug print
      rethrow;
    }
  }

  // Get all orders (for admin)
  Stream<List<TeaOrder>> getAllOrders() async* {
    final realtime = _appwrite.realtime;
    
    try {
      // First, yield initial orders
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ordersCollectionId,
      );
      
      final orders = response.documents.map((doc) {
        final data = doc.data;
        data['id'] = doc.$id;
        return TeaOrder.fromMap(data);
      }).toList();
      
      yield orders;

      // Then listen to realtime updates
      await for (final event in realtime.subscribe([
        'databases.${AppwriteService.databaseId}.collections.${AppwriteService.ordersCollectionId}.documents'
      ]).stream) {
        debugPrint('Admin realtime event received: ${event.events}');
        
        // Get fresh data after any change
        final updatedResponse = await _appwrite.databases.listDocuments(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.ordersCollectionId,
        );
        
        final updatedOrders = updatedResponse.documents.map((doc) {
          final data = doc.data;
          data['id'] = doc.$id;
          return TeaOrder.fromMap(data);
        }).toList();
        
        yield updatedOrders;
      }
    } catch (e) {
      debugPrint('Error in admin orders stream: $e');
      rethrow;
    }
  }
}
