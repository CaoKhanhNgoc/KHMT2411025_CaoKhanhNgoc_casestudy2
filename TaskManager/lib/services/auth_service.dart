import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.keyToken);
    final userJson = prefs.getString(AppConstants.keyUser);

    if (_token != null && userJson != null) {
      _apiClient.setToken(_token);
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
        notifyListeners();
        // Fetch fresh profile from server in background
        await fetchCurrentUser();
      } catch (_) {
        await logout();
      }
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    _setLoading(true);
    try {
      final response = await _apiClient.post('/auth/register', body: {
        'fullName': fullName,
        'email': email,
        'password': password,
      });

      final data = response['data'];
      _token = data['token'];
      _currentUser = User.fromJson(data['user']);
      _apiClient.setToken(_token);

      await _persistAuth();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _apiClient.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      final data = response['data'];
      _token = data['token'];
      _currentUser = User.fromJson(data['user']);
      _apiClient.setToken(_token);

      await _persistAuth();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _apiClient.setToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUser);

    notifyListeners();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      if (response['data'] != null) {
        _currentUser = User.fromJson(response['data']);
        await _persistAuth();
        notifyListeners();
      }
    } catch (_) {
      // Ignore background refresh errors
    }
  }

  Future<void> updateProfile({required String fullName, String? avatarUrl}) async {
    _setLoading(true);
    try {
      final response = await _apiClient.put('/auth/me', body: {
        'fullName': fullName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });

      _currentUser = User.fromJson(response['data']);
      await _persistAuth();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _apiClient.put('/auth/change-password', body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _persistAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(AppConstants.keyToken, _token!);
    }
    if (_currentUser != null) {
      await prefs.setString(AppConstants.keyUser, jsonEncode(_currentUser!.toJson()));
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
