import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/models.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late final Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        // Only log in debug mode
        if (AppConfig.appVersion.contains('debug')) {
          debugPrint(object.toString());
        }
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        final apiError = _handleError(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: apiError,
          type: error.type,
        ));
      },
    ));
  }

  ApiError _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          message: 'Connection timeout. Please check your internet connection.',
          code: 408,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        String message = 'Server error occurred';
        
        if (error.response?.data != null) {
          try {
            final data = error.response!.data;
            if (data is Map<String, dynamic>) {
              message = data['message'] ?? data['error'] ?? message;
            } else if (data is String) {
              message = data;
            }
          } catch (e) {
            // Use default message
          }
        }
        
        return ApiError(
          message: message,
          code: statusCode,
        );
      
      case DioExceptionType.cancel:
        return const ApiError(
          message: 'Request was cancelled',
          code: 499,
        );
      
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const ApiError(
            message: 'No internet connection',
            code: 503,
          );
        }
        return const ApiError(
          message: 'An unexpected error occurred',
          code: 500,
        );
      
      default:
        return const ApiError(
          message: 'An unexpected error occurred',
          code: 500,
        );
    }
  }

  // GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw e.error as ApiError;
    }
  }

  // POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw e.error as ApiError;
    }
  }

  // PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw e.error as ApiError;
    }
  }

  // DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw e.error as ApiError;
    }
  }
}

// Service Result wrapper
class ServiceResult<T> {
  final T? data;
  final ApiError? error;
  final bool isSuccess;

  const ServiceResult.success(this.data) 
      : error = null, 
        isSuccess = true;

  const ServiceResult.failure(this.error) 
      : data = null, 
        isSuccess = false;
}