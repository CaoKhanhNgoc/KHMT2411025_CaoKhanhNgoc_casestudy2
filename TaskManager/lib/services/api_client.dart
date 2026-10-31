import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;
  String? _customBaseUrl;

  void setToken(String? token) {
    _token = token;
  }

  void setBaseUrl(String url) {
    _customBaseUrl = url;
  }

  String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) {
      return AppConstants.fallbackLocalUrl;
    }
    if (Platform.isAndroid) {
      return AppConstants.baseUrl; // 10.0.2.2 for Android emulator
    }
    return AppConstants.fallbackLocalUrl; // localhost for Windows, iOS, macOS
  }

  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        final stringParams = queryParams.map((k, v) => MapEntry(k, v.toString()));
        uri = uri.replace(queryParameters: stringParams);
      }

      final response = await http.get(uri, headers: _buildHeaders());
      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.patch(
        uri,
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(uri, headers: _buildHeaders());
      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic responseData;
    try {
      responseData = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      responseData = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    }

    String message = 'Đã xảy ra lỗi, vui lòng thử lại';
    if (responseData is Map && responseData['message'] != null) {
      message = responseData['message'];
    }

    throw ApiException(message, statusCode: response.statusCode);
  }

  void _handleException(dynamic e) {
    if (e is ApiException) {
      throw e;
    }
    if (e is SocketException) {
      throw ApiException('Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng hoặc backend.');
    }
    throw ApiException(e.toString());
  }
}
