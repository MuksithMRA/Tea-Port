import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'appwrite_service.dart';

class AuthService extends ChangeNotifier {
  final AppwriteService _appwrite = AppwriteService();
  models.User? _currentUser;
  UserModel? _userData;
  bool _isInitialized = false;

  models.User? get currentUser => _currentUser;
  UserModel? get userData => _userData;
  bool get isInitialized => _isInitialized;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      // First check if there's an existing session
      try {
        await _appwrite.account.get();
        // If we get here, there's an active session
        await signOut(); // Sign out first
      } catch (_) {
        // No active session, proceed with login
      }

      await _appwrite.account.createEmailSession(
        email: email,
        password: password,
      );
      _currentUser = await _appwrite.account.get();
      await _loadUserData();
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      _userData = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (_currentUser != null) {
        final document = await _appwrite.databases.getDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.usersCollectionId,
          documentId: _currentUser!.$id,
        );
        _userData = UserModel.fromMap(document.data);
        notifyListeners();
      }
    } catch (e) {
      _userData = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _appwrite.account.deleteSession(sessionId: 'current');
      await _appwrite.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        documentId: _currentUser!.$id,
        data: {'fcmToken': ''},
      );
    } finally {
      _currentUser = null;
      _userData = null;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      _currentUser = await _appwrite.account.get();
      if (_currentUser != null) {
        await _loadUserData();
      }
    } catch (e) {
      _currentUser = null;
      _userData = null;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }
}
