import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/constants/storage_keys.dart';
import 'package:jahitin_mobile/core/services/api_service.dart';
import 'package:jahitin_mobile/core/services/storage_service.dart';
import 'package:jahitin_mobile/features/auth/auth_provider.dart';
import 'package:jahitin_mobile/features/registration/registration_state.dart';
import 'package:unique_device_identifier/unique_device_identifier.dart';

class RegistrationNotifier extends Notifier<RegistrationState> {
  @override
  RegistrationState build() => const RegistrationState();

  Future<bool> registerUser(String name) async {
    state = const RegistrationState(status: RegistrationStatus.loading);

    try {
      final storage = ref.read(storageServiceProvider);
      final appDebug = dotenv.env['APP_DEBUG']?.toLowerCase() == 'true';
      final deviceId = appDebug
          ? _generateRandomString(16)
          : await storage.getDeviceId() ??
                await UniqueDeviceIdentifier.getUniqueIdentifier() ??
                '';

      await ApiService.registerLocal(name: name, deviceId: deviceId);

      await storage.setDeviceId(deviceId);
      await storage.setAppState(StorageAppState.registered);
      await storage.setAuthType(StorageAuthType.local);
      await storage.setLoginStatus(StorageLoginStatus.loggedIn);

      // directly login local
      await ref.read(authProvider.notifier).loginLocal();

      state = const RegistrationState(status: RegistrationStatus.success);
      return true;
    } on ApiException catch (error) {
      state = RegistrationState(
        status: RegistrationStatus.error,
        message: error.message,
      );
      return false;
    } catch (_) {
      state = const RegistrationState(
        status: RegistrationStatus.error,
        message: 'Terjadi kesalahan. Coba lagi.',
      );
      return false;
    }
  }

  String _generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}

final registrationProvider =
    NotifierProvider<RegistrationNotifier, RegistrationState>(
      RegistrationNotifier.new,
    );
