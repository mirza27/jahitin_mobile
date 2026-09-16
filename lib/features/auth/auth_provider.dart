import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/constants/storage_keys.dart';
import 'package:jahitin_mobile/core/models/user.dart';
import 'package:jahitin_mobile/core/services/api_service.dart';
import 'package:jahitin_mobile/core/services/storage_service.dart';
import 'package:jahitin_mobile/features/auth/auth_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> initialize() async {
    state = state.copyWith(status: AuthStatus.initial);

    final appDebug = dotenv.env['APP_DEBUG'] == 'true';
    final storage = ref.read(storageServiceProvider);

    if (appDebug) {
      // await storage.clearAllData();
    }

    state = state.copyWith(status: AuthStatus.loading);

    // set provider state each time app is launched, based on storage data
    final storageAuthType = await storage.getAuthType();

    // if online
    if (storageAuthType == StorageAuthType.online) {
      final isSessionValid = await checkSession();

      if (isSessionValid) {
        state = state.copyWith(status: AuthStatus.authenticated);
        return;
      }
    }

    // if local then just auto relogin and update token
    if (storageAuthType == StorageAuthType.local) {
      await loginLocal();
      state = state.copyWith(status: AuthStatus.authenticated);
      return;
    }

    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<bool> checkSession() async {
    state = state.copyWith(status: AuthStatus.loading);

    final storage = ref.read(storageServiceProvider);
    final String? storageToken = await storage.getToken();

    if (storageToken != null && storageToken.isNotEmpty) {
      // if response from API is valid, return true
      final result = await ApiService.userSession(token: storageToken);

      state = state.copyWith(
        user: result['data'] != null ? User.fromJson(result['data']) : null,
      );

      return true;
    }

    return false;
  }

  Future<void> getUserData() async {
    state = state.copyWith(status: AuthStatus.loading);

    final storage = ref.read(storageServiceProvider);
    final String? storageToken = await storage.getToken();

    final result = await ApiService.userSession(token: storageToken!);
    state = state.copyWith(
      user: result['data'] != null ? User.fromJson(result['data']) : null,
    );
  }

  Future<void> loginLocal() async {
    final storage = ref.read(storageServiceProvider);
    final deviceId = await storage.getDeviceId();

    final result = await ApiService.loginLocal(deviceId: deviceId!);
    final token = result['data']['token'];

    await storage.setToken(token);

    // set user data
    await getUserData();

    return;
  }

  Future<bool> loginAccount({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // TODO: call login API, then save token and user data.
      await Future.delayed(const Duration(milliseconds: 800));

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        message: 'Login belum terhubung ke API',
      );
      return false;
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: error.toString(),
      );
      return false;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
