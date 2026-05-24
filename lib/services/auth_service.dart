import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database_service.dart';

class UserSession {
  final String name;
  final String email;
  final String avatarUrl;
  final String provider;

  UserSession({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.provider,
  });
}

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  UserSession? _currentUser;
  
  final _authStateController = StreamController<UserSession?>.broadcast();
  Stream<UserSession?> get authStateChanges => _authStateController.stream;

  Future<void> init() async {
    final db = DatabaseService.instance;
    // Create users table dynamically if it doesn't exist
    final database = await db.database;
    await database.execute('''
      CREATE TABLE IF NOT EXISTS users(
        email TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    final isLoggedIn = await db.fetchSessionValue('is_logged_in');
    if (isLoggedIn == '1') {
      final name = await db.fetchSessionValue('user_name') ?? 'User';
      final email = await db.fetchSessionValue('user_email') ?? '';
      final avatarUrl = await db.fetchSessionValue('user_avatar') ?? '';
      final provider = await db.fetchSessionValue('user_provider') ?? 'email';
      _currentUser = UserSession(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
        provider: provider,
      );
      _authStateController.add(_currentUser);
    } else {
      _currentUser = null;
      _authStateController.add(null);
    }
  }

  UserSession? get currentUserValue => _currentUser;

  Future<bool> register(String name, String email, String password) async {
    try {
      final db = await DatabaseService.instance.database;
      
      // Check if user exists
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (existing.isNotEmpty) {
        return false; // User already exists
      }

      await db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
      });

      // Automatically log in
      await _loginUser(name, email, 'email', '');
      return true;
    } catch (e) {
      if (kDebugMode) print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final db = await DatabaseService.instance.database;
      final results = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      
      if (results.isEmpty) {
        return false; // Invalid credentials
      }

      final name = results.first['name'] as String;
      await _loginUser(name, email, 'email', '');
      return true;
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      return false;
    }
  }

  Future<void> signInWithGoogle(String name, String email, String avatarUrl) async {
    await _loginUser(name, email, 'google', avatarUrl);
  }

  Future<void> _loginUser(String name, String email, String provider, String avatarUrl) async {
    final db = DatabaseService.instance;
    await db.saveSessionValue('is_logged_in', '1');
    await db.saveSessionValue('user_name', name);
    await db.saveSessionValue('user_email', email);
    await db.saveSessionValue('user_avatar', avatarUrl);
    await db.saveSessionValue('user_provider', provider);

    _currentUser = UserSession(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      provider: provider,
    );
    _authStateController.add(_currentUser);
  }

  Future<void> logout() async {
    final db = DatabaseService.instance;
    await db.clearSession();
    _currentUser = null;
    _authStateController.add(null);
  }
}
