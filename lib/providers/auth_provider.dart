import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nhpms/models/auth/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? accessToken,
    String? refreshToken,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  final _apiService = ApiService();
  final _storageService = StorageService();

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = await _storageService.getAccessToken();

      if (token != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          accessToken: token,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> login(String phoneNumber, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response =
          await _apiService.login(phoneNumber, password);

      final tokens = AuthTokens.fromJson(response['tokens']);

      await _storageService.saveTokens(
        tokens.accessToken,
        tokens.refreshToken,
      );

      UserModel? user;

      if (response['user'] != null) {
        user = UserModel.fromJson(response['user']);
      } else if (response['business'] != null) {
        user = UserModel(
          username: response['business']['name'],
          email: response['business']['email'] ?? '',
          phoneNumber: response['business']['phone_number'],
          businessId: response['business']['id'],
          businessName: response['business']['name'],
        );
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signup(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.signup(data);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } finally {
      await _storageService.clearAll();
      state = AuthState();
    }
  }
}