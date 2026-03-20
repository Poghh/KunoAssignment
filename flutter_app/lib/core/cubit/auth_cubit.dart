import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_network_constants.dart';
import '../network/api_client.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  guest,
}

enum AuthErrorCode {
  loginRequiresInternet,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.username,
    this.displayName,
    this.isSubmitting = false,
    this.errorCode,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? username;
  final String? displayName;
  final bool isSubmitting;
  final AuthErrorCode? errorCode;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    String? username,
    String? displayName,
    bool clearUsername = false,
    bool clearDisplayName = false,
    bool? isSubmitting,
    Object? errorCode = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return AuthState(
      status: status ?? this.status,
      username: clearUsername ? null : (username ?? this.username),
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorCode: identical(errorCode, _sentinel)
          ? this.errorCode
          : errorCode as AuthErrorCode?,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();

  @override
  List<Object?> get props => <Object?>[
        status,
        username,
        displayName,
        isSubmitting,
        errorCode,
        errorMessage,
      ];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.apiClient}) : super(const AuthState());

  final ApiClient apiClient;

  Future<void> loadSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn =
        prefs.getBool(AppStorageKeys.sessionLoggedIn) ?? false;
    final String? username = prefs.getString(AppStorageKeys.sessionUsername);
    final String? displayName =
        prefs.getString(AppStorageKeys.sessionDisplayName);

    if (isLoggedIn) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        username: username,
        displayName: displayName,
        errorCode: null,
        errorMessage: null,
      ));
    } else {
      // Not logged in → use app without an account (guest/local mode).
      emit(state.copyWith(
        status: AuthStatus.guest,
        clearUsername: true,
        clearDisplayName: true,
        errorCode: null,
        errorMessage: null,
      ));
    }
  }

  Future<void> enterGuestMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStorageKeys.sessionGuestMode, true);
    emit(state.copyWith(
      status: AuthStatus.guest,
      clearUsername: true,
      clearDisplayName: true,
      errorCode: null,
      errorMessage: null,
    ));
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = email.trim();
    final String normalizedPassword = password.trim();
    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      return false;
    }

    emit(state.copyWith(
        isSubmitting: true, errorCode: null, errorMessage: null));

    try {
      final response = await apiClient.post(
        AppApiPath.authLogin,
        data: <String, dynamic>{
          AppApiResponseKey.email: normalizedEmail,
          'password': normalizedPassword,
        },
      );
      final data =
          (response.data as Map<String, dynamic>)[AppApiResponseKey.data]
              as Map<String, dynamic>;
      final String responseUsername =
          (data[AppApiResponseKey.email] as String?)?.trim() ?? '';
      final String responseDisplayName =
          (data[AppApiResponseKey.displayName] as String?)?.trim() ?? '';

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppStorageKeys.sessionLoggedIn, true);
      await prefs.setString(AppStorageKeys.sessionUsername, responseUsername);
      await prefs.setString(
        AppStorageKeys.sessionDisplayName,
        responseDisplayName,
      );
      await prefs.remove(AppStorageKeys.sessionGuestMode);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          username: responseUsername,
          displayName: responseDisplayName,
          isSubmitting: false,
          errorCode: null,
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorCode: _isConnectionError(error)
              ? AuthErrorCode.loginRequiresInternet
              : null,
          errorMessage: _resolveErrorMessage(error),
        ),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = email.trim();
    final String normalizedPassword = password.trim();
    if (normalizedEmail.isEmpty || normalizedPassword.length < 6) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await apiClient.post(
        AppApiPath.authRegister,
        data: <String, dynamic>{
          AppApiResponseKey.email: normalizedEmail,
          'password': normalizedPassword,
        },
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppStorageKeys.sessionLoggedIn, false);
      await prefs.remove(AppStorageKeys.sessionUsername);
      await prefs.remove(AppStorageKeys.sessionDisplayName);

      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isSubmitting: false,
          clearUsername: true,
          clearDisplayName: true,
          errorCode: null,
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorCode: null,
          errorMessage: _resolveErrorMessage(error),
        ),
      );
      return false;
    }
  }

  Future<bool> setDisplayName(String displayName) async {
    final String normalizedDisplayName = displayName.trim();
    final String email = state.username?.trim() ?? '';
    if (normalizedDisplayName.length < 2 || email.isEmpty) {
      return false;
    }

    try {
      final response = await apiClient.put(
        AppApiPath.authProfileDisplayName,
        data: <String, dynamic>{
          AppApiResponseKey.email: email,
          AppApiResponseKey.displayName: normalizedDisplayName,
        },
      );
      final data =
          (response.data as Map<String, dynamic>)[AppApiResponseKey.data]
              as Map<String, dynamic>;
      final String responseDisplayName =
          (data[AppApiResponseKey.displayName] as String?)?.trim() ??
              normalizedDisplayName;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppStorageKeys.sessionDisplayName,
        responseDisplayName,
      );

      emit(state.copyWith(displayName: responseDisplayName));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStorageKeys.sessionLoggedIn, false);
    await prefs.remove(AppStorageKeys.sessionUsername);
    await prefs.remove(AppStorageKeys.sessionDisplayName);

    // After logout, return to local/guest mode so the user can keep using
    // the app without an account.
    emit(
      state.copyWith(
        status: AuthStatus.guest,
        isSubmitting: false,
        clearUsername: true,
        clearDisplayName: true,
        errorCode: null,
        errorMessage: null,
      ),
    );
  }

  bool _isConnectionError(Object error) {
    if (error is! DioException) {
      return false;
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    return error.type == DioExceptionType.unknown && error.response == null;
  }

  String? _resolveErrorMessage(Object error) {
    if (error is DioException) {
      final String message = (error.message ?? '').trim();
      if (message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}
