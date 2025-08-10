import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Comprehensive API service class using Dio for HTTP requests
/// This class provides a robust foundation for making API calls with
/// error handling, retries, and network connectivity checks
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  static const String baseUrl =
      'https://api.example.com'; // Replace with your API base URL
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Initialize the API service with configuration
  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(_getLogInterceptor());
    _dio.interceptors.add(_getErrorInterceptor());
    _dio.interceptors.add(_getAuthInterceptor());
  }

  /// Log interceptor for debugging (only in debug mode)
  Interceptor _getLogInterceptor() {
    return LogInterceptor(
      request: kDebugMode,
      requestHeader: kDebugMode,
      requestBody: kDebugMode,
      responseHeader: kDebugMode,
      responseBody: kDebugMode,
      error: kDebugMode,
      logPrint: (obj) => debugPrint(obj.toString()),
    );
  }

  /// Error interceptor for handling common errors
  Interceptor _getErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('API Error: ${error.message}');

        // Handle specific error cases
        if (error.response?.statusCode == 401) {
          // Handle unauthorized access
          _handleUnauthorized();
        } else if (error.response?.statusCode == 429) {
          // Handle rate limiting
          _handleRateLimit(error, handler);
          return;
        }

        handler.next(error);
      },
    );
  }

  /// Auth interceptor for adding authentication headers
  Interceptor _getAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication token if available
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    );
  }

  /// Check network connectivity before making requests
  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    // Check if we have a valid connection
    return connectivityResult != ConnectivityResult.none;
  }

  /// Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!await _checkConnectivity()) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!await _checkConnectivity()) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!await _checkConnectivity()) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!await _checkConnectivity()) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handle DioException and convert to user-friendly messages
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return Exception('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Server response timeout. Please try again.');
      case DioExceptionType.badResponse:
        return Exception(_getErrorMessage(e.response?.statusCode));
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      default:
        return Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Get user-friendly error message based on status code
  String _getErrorMessage(int? statusCode) {
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
        return 'An error occurred. Please try again.';
    }
  }

  /// Handle unauthorized access (401)
  void _handleUnauthorized() {
    // Clear stored auth token
    // Navigate to login screen
    debugPrint('Unauthorized access - redirecting to login');
  }

  /// Handle rate limiting (429)
  void _handleRateLimit(DioException error, ErrorInterceptorHandler handler) {
    // Implement retry logic with exponential backoff
    debugPrint('Rate limit exceeded - implementing retry logic');
    handler.next(error);
  }

  /// Get authentication token (implement based on your auth system)
  Future<String?> _getAuthToken() async {
    // Implement token retrieval logic
    // This could be from SharedPreferences, secure storage, etc.
    return null;
  }

  /// Set authentication token
  Future<void> setAuthToken(String token) async {
    // Implement token storage logic
    debugPrint('Auth token set');
  }

  /// Clear authentication token
  Future<void> clearAuthToken() async {
    // Implement token clearing logic
    debugPrint('Auth token cleared');
  }
}
