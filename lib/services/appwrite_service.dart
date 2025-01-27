import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal() {
    _initializeClient();
  }

  static const String projectId = '678a51bd00087d475cfb';
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String databaseId = '678a52290028e8ab3db1';
  static const String ordersCollectionId = '678a5370001286436d5c';
  static const String usersCollectionId = '678a537b00090a206dd7';

  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Functions functions;
  late final Realtime realtime;

  void _initializeClient() {
    client = Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId)
      // Set self-signed only in debug mode
      ..setSelfSigned();

    account = Account(client);
    databases = Databases(client);
    functions = Functions(client);
    realtime = Realtime(client);
  }

  String getOrigin() {
    if (kDebugMode) {
      return 'localhost';
    } else {
      return 'internal-ht.web.app';
    }
  }

  // Retry configuration
  static const int maxRetries = 3;
  static const int initialDelayMs = 1000;

  /// Generic retry mechanism for Appwrite operations
  Future<T> retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    int delay = initialDelayMs;

    while (true) {
      try {
        return await operation();
      } on AppwriteException catch (e) {
        attempts++;
        
        // Check if it's a rate limit error (HTTP 429)
        if (e.code == 429) {
          if (attempts >= maxRetries) {
            rethrow; // Max retries reached, throw the error
          }

          // Wait with exponential backoff
          await Future.delayed(Duration(milliseconds: delay));
          delay *= 2; // Exponential backoff
          continue;
        }
        
        rethrow; // Not a rate limit error, throw immediately
      }
    }
  }

  // Example wrapper for database operations
  Future<dynamic> safeDatabaseOperation(Future<dynamic> Function() dbOperation) {
    return retryOperation(dbOperation);
  }
}
