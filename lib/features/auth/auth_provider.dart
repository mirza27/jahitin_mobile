import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/constants/storage_keys.dart';
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
    final storageLoginStatus = await storage.getLoginStatus();

    // local and logged in
    if (storageAuthType == StorageAuthType.local &&
        storageLoginStatus == StorageLoginStatus.loggedIn) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        authType: AuthType.local,
      );

      // save token

      return;
    }

    // local and logged out
    if (storageAuthType == StorageAuthType.local &&
        storageLoginStatus == StorageLoginStatus.loggedOut) {
      // process auth
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        authType: AuthType.local,
      );
      return;
    }

    // online and logged in
    if (storageAuthType == StorageAuthType.online &&
        storageLoginStatus == StorageLoginStatus.loggedIn) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        authType: AuthType.online,
      );
      return;
    }

    // online and logged out
    if (storageAuthType == StorageAuthType.online &&
        storageLoginStatus == StorageLoginStatus.loggedOut) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        authType: AuthType.online,
      );

      return;
    }

    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<bool> login({required String email, required String password}) async {
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
