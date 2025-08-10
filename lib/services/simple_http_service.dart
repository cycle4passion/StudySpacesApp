import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Simple HTTP API service using the basic http package
/// This is a lightweight alternative to the Dio-based service
class SimpleHttpService {
  static const String baseUrl =
      'https://api.example.com'; // Replace with your API base URL
  static const Duration timeout = Duration(seconds: 30);

  // Optional: Store auth token
  String? _authToken;

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Get headers with optional authentication
  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Build full URL
  String _buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Handle HTTP response and errors
  dynamic _handleResponse(http.Response response) {
    debugPrint('HTTP ${response.request?.method} ${response.request?.url}');
    debugPrint('Response: ${response.statusCode} ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      throw HttpException(
        statusCode: response.statusCode,
        message: _getErrorMessage(response.statusCode),
        responseBody: response.body,
      );
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Forbidden. You don\'t have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred (Status: $statusCode). Please try again.';
    }
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(endpoint));
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('GET request error: $e');
      rethrow;
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(endpoint));
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .post(
            uri,
            headers: _getHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST request error: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(endpoint));
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .put(
            uri,
            headers: _getHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT request error: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(endpoint));
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .delete(uri, headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('DELETE request error: $e');
      rethrow;
    }
  }
}

/// Custom HTTP exception class
class HttpException implements Exception {
  final int statusCode;
  final String message;
  final String? responseBody;

  const HttpException({
    required this.statusCode,
    required this.message,
    this.responseBody,
  });

  @override
  String toString() {
    return 'HttpException: $message (Status: $statusCode)';
  }
}

// =============================================================================
// EXAMPLE USAGE
// =============================================================================

/// Example service using SimpleHttpService
class ExampleApiService {
  final SimpleHttpService _httpService = SimpleHttpService();

  /// Example: Fetch user data
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final response = await _httpService.get('/users/$userId');
      return response;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  /// Example: Create a new post
  Future<bool> createPost({
    required String title,
    required String content,
  }) async {
    try {
      await _httpService.post(
        '/posts',
        body: {
          'title': title,
          'content': content,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      return true;
    } catch (e) {
      debugPrint('Error creating post: $e');
      return false;
    }
  }

  /// Example: Update user profile
  Future<bool> updateUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await _httpService.put('/users/$userId', body: profileData);
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  /// Example: Delete a post
  Future<bool> deletePost(String postId) async {
    try {
      await _httpService.delete('/posts/$postId');
      return true;
    } catch (e) {
      debugPrint('Error deleting post: $e');
      return false;
    }
  }

  /// Example: Login and set auth token
  Future<bool> login(String email, String password) async {
    try {
      final response = await _httpService.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response != null && response['token'] != null) {
        _httpService.setAuthToken(response['token']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  /// Example: Logout
  Future<void> logout() async {
    try {
      await _httpService.post('/auth/logout');
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _httpService.clearAuthToken();
    }
  }
}
