import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:unique_device_identifier/unique_device_identifier.dart';
import '../constants/storage_keys.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // Returns true if storage was freshly initialized (first launch)
  Future<bool> initIfEmpty() async {
    final existing = await _storage.read(key: StorageKeys.appState);
    if (existing != null) return false;

    String? deviceId;
    try {
      deviceId = await UniqueDeviceIdentifier.getUniqueIdentifier();
    } catch (_) {
      deviceId = null;
    }

    await _storage.write(
      key: StorageKeys.appState,
      value: StorageAppState.unregistered,
    );
    await _storage.write(key: StorageKeys.loginStatus, value: 'false');
    if (deviceId != null) {
      await _storage.write(key: StorageKeys.deviceId, value: deviceId);
    }

    return true;
  }

  Future<String?> getAppState() => _storage.read(
    key: StorageKeys.appState,
  ); // app state can be 'registered' or 'unregistered'

  Future<String?> getLoginStatus() =>
      _storage.read(key: StorageKeys.loginStatus);
  // login status can be 'true' or 'false'

  Future<String?> getDeviceId() => _storage.read(key: StorageKeys.deviceId);
  Future<String?> getToken() => _storage.read(key: StorageKeys.token);
  Future<String?> getUserId() => _storage.read(key: StorageKeys.userId);
  Future<String?> getEmail() => _storage.read(key: StorageKeys.email);
  Future<String?> getUsername() => _storage.read(key: StorageKeys.username);
  Future<String?> getAuthType() => _storage.read(key: StorageKeys.authType);

  Future<void> setAppState(String value) =>
      _storage.write(key: StorageKeys.appState, value: value);

  Future<void> setLoginStatus(String value) =>
      _storage.write(key: StorageKeys.loginStatus, value: value);

  Future<void> setAuthType(String value) =>
      _storage.write(key: StorageKeys.authType, value: value);

  Future<void> setAuthData({
    required String token,
    required String userId,
    required String email,
    required String username,
  }) async {
    await _storage.write(key: StorageKeys.token, value: token);
    await _storage.write(key: StorageKeys.userId, value: userId);
    await _storage.write(key: StorageKeys.email, value: email);
    await _storage.write(key: StorageKeys.username, value: username);
    await _storage.write(key: StorageKeys.loginStatus, value: 'true');
  }

  Future<void> clearAuthData() async {
    await _storage.write(key: StorageKeys.loginStatus, value: 'false');
    await _storage.delete(key: StorageKeys.token);
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.email);
    await _storage.delete(key: StorageKeys.username);
  }

  Future<void> clearAllData() async {
    await _storage.deleteAll();
  }
}
