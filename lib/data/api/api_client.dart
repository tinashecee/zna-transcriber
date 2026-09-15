import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app/config.dart';

typedef TokenProvider = Future<String?> Function();
typedef ApiKeyProvider = Future<String?> Function();
typedef UnauthorizedHandler = Future<void> Function(DioException error);

class ApiClient {
  ApiClient({
    required AppConfig config,
    required TokenProvider tokenProvider,
    ApiKeyProvider? apiKeyProvider,
    UnauthorizedHandler? onUnauthorized,
  })  : _tokenProvider = tokenProvider,
        _apiKeyProvider = apiKeyProvider,
        _onUnauthorized = onUnauthorized,
        dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final apiKey = await _apiKeyProvider?.call();
          if (apiKey != null && apiKey.isNotEmpty) {
            options.headers['X-API-Key'] = apiKey;
            options.headers.remove('Authorization');
          } else {
            final token = await _tokenProvider();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          if (kDebugMode) {
            final qp = options.queryParameters.isEmpty
                ? ''
                : ' params=${options.queryParameters}';
            debugPrint('[Http] -> ${options.method} ${options.uri}$qp');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          if (kDebugMode) {
            final req = response.requestOptions;
            final size = _describeResponseSize(response.data);
            debugPrint(
              '[Http] <- ${req.method} ${req.uri} '
              'status=${response.statusCode} $size',
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            final method = error.requestOptions.method;
            final uri = error.requestOptions.uri;
            final status = error.response?.statusCode;
            // Never log response bodies — they may contain PII / case data.
            debugPrint('[Http] !! $method $uri -> $status');
          }

          final onUnauthorized = _onUnauthorized;
          final status = error.response?.statusCode;
          if (status == 401 && onUnauthorized != null) {
            final path = error.requestOptions.path;
            // Don't treat login failures as session expiry.
            final isAuthEndpoint = path.contains('/login') ||
                path.contains('/auth') ||
                path.contains('/password');
            // API-key auth has no JWT expiry — fix the key in settings.
            final usingApiKey =
                error.requestOptions.headers.containsKey('X-API-Key');
            if (!isAuthEndpoint && !usingApiKey && !_handlingUnauthorized) {
              _handlingUnauthorized = true;
              try {
                await onUnauthorized(error);
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('[ApiClient] onUnauthorized handler threw: $e');
                }
              } finally {
                _handlingUnauthorized = false;
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  static String _describeResponseSize(dynamic data) {
    if (data == null) return 'body=null';
    if (data is List) return 'list=${data.length}';
    if (data is Map) {
      final items = data['items'];
      if (items is List) return 'map{items=${items.length}}';
      return 'map{keys=${data.keys.length}}';
    }
    if (data is String) return 'str=${data.length}chars';
    return 'type=${data.runtimeType}';
  }

  final Dio dio;
  final TokenProvider _tokenProvider;
  final ApiKeyProvider? _apiKeyProvider;
  final UnauthorizedHandler? _onUnauthorized;
  bool _handlingUnauthorized = false;
}
