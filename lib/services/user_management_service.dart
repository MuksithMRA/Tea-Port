import 'package:appwrite/appwrite.dart';
import '../models/user_model.dart';
import 'appwrite_service.dart';

class UserManagementService {
  final AppwriteService _appwrite = AppwriteService();

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      // Create user account
      final user = await _appwrite.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Create user document in database
      await _appwrite.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        documentId: user.$id,
        data: {
          'email': email,
          'name': name,
          'role': role.toString().split('.').last,
        },
      );
    } catch (e) {
      throw e;
    }
  }

  Future<void> createAdminUser({
    String email = 'admin@teaservice.com',
    String password = 'Admin@123',
    String name = 'Admin',
  }) async {
    try {
      await createUser(
        email: email,
        password: password,
        name: name,
        role: UserRole.admin,
      );
    } catch (e) {
      throw e;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
      );

      return response.documents
          .map((doc) => UserModel.fromMap(doc.data))
          .toList();
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document from database
      await _appwrite.databases.deleteDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        documentId: userId,
      );

      // Note: Deleting the actual user account requires admin privileges
      // and should be done through the Appwrite console or a server-side function
    } catch (e) {
      throw e;
    }
  }
}
