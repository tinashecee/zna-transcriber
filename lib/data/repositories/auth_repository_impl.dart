import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../api/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/login', // Updated endpoint to match Flask route
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Empty response from login endpoint',
      );
    }

    final token = data['token'] as String?;
    if (token == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Missing token in login response',
      );
    }

    return data;
  }

  @override
  Future<void> logout() async {
    await _client.dio.post('/api/logout');
  }

  @override
  Future<User?> getCurrentUser() async {
    final response = await _client.dio.get<Map<String, dynamic>>('/api/me');
    final data = response.data;
    if (data == null) return null;
    return User(
      id: data['id'].toString(),
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? '',
      email: data['email'] as String? ?? '',
    );
  }

  @override
  Future<bool> sendPasswordReset(String email) async {
    final response = await _client.dio.post(
      '/api/forgot-password',
      data: {'email': email},
    );
    return response.statusCode == 200;
  }

  static User userFromToken(String token) {
    // Reject mock/dev tokens: never grant access from a non-real token
    if (token == 'mock_jwt_token_for_development') {
      throw ArgumentError('Invalid token: mock tokens are not allowed');
    }

    try {
      final payload = JwtDecoder.decode(token);
      return User(
        id: payload['id'].toString(),
        name: payload['name'] as String? ?? '',
        role: payload['role'] as String? ?? '',
        email: payload['email'] as String? ?? '',
        court: payload['court'] as String?,
        contactInfo: payload['contact_info'] as String?,
        district: payload['district'] as String?,
        province: payload['province'] as String?,
        region: payload['region'] as String?,
        dateCreated: payload['date_created'] as String?,
      );
    } catch (e) {
      // Invalid or tampered token: do not grant access (never log token material).
      print('JWT decoding failed: $e');
      rethrow;
    }
  }
}
