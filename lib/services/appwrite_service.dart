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
}
