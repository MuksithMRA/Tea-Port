import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static const String projectId = '678a51bd00087d475cfb';
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String databaseId = '678a52290028e8ab3db1';
  static const String ordersCollectionId = '678a5370001286436d5c';
  static const String usersCollectionId = '678a537b00090a206dd7';

  Client get client => Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId)
    ..setSelfSigned();

  Account get account => Account(client);
  Databases get databases => Databases(client);
  Realtime get realtime => Realtime(client);
  Functions get functions => Functions(client);
}
