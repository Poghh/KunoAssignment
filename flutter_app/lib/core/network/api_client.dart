import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_network_constants.dart';

abstract class ApiClient {
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
}

class DioApiClient implements ApiClient {
  DioApiClient({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppApiBaseUrl.resolve(),
        connectTimeout: AppApiTimeout.connect,
        sendTimeout: AppApiTimeout.send,
        receiveTimeout: AppApiTimeout.receive,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: <String, String>{
          AppApiHeader.accept: AppApiHeaderValue.json,
        },
      ),
    );

    dio.interceptors.add(_RequestInterceptor());
    dio.interceptors.add(_ErrorInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    return dio;
  }

  @override
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

ApiClient createApiClient() => DioApiClient();

class _RequestInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String username =
        (prefs.getString(AppStorageKeys.sessionUsername) ?? '').trim();
    if (username.isNotEmpty) {
      options.headers[AppApiHeader.username] = username;
    } else {
      options.headers.remove(AppApiHeader.username);
    }

    options.headers.putIfAbsent(
      AppApiHeader.accept,
      () => AppApiHeaderValue.json,
    );
    options.headers.putIfAbsent(
      Headers.contentTypeHeader,
      () => Headers.jsonContentType,
    );
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: err.error,
        stackTrace: err.stackTrace,
        message: _resolveMessage(err),
      ),
    );
  }
}

String _resolveMessage(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return AppApiErrorMessage.timeout;
  }

  if (error.type == DioExceptionType.connectionError) {
    return AppApiErrorMessage.connectionError;
  }

  if (error.type == DioExceptionType.cancel) {
    return AppApiErrorMessage.cancelled;
  }

  final dynamic data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final dynamic message = data[AppApiResponseKey.message];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
  }

  final int? statusCode = error.response?.statusCode;
  if (statusCode != null) {
    if (statusCode >= 500) {
      return '${AppApiErrorMessage.serverError} ($statusCode). Please try again later.';
    }
    if (statusCode == 401) {
      return AppApiErrorMessage.unauthorized;
    }
    if (statusCode == 403) {
      return AppApiErrorMessage.forbidden;
    }
    if (statusCode == 404) {
      return AppApiErrorMessage.notFound;
    }
    if (statusCode == 400 || statusCode == 422) {
      return AppApiErrorMessage.invalidRequest;
    }
  }

  return error.message ?? AppApiErrorMessage.unexpectedNetworkError;
}
