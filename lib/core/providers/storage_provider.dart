import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../constants/storage_keys.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Resolved route after init: 'registered' | 'unregistered'
final initialRouteProvider = FutureProvider<String>((ref) async {
  final storage = ref.read(storageServiceProvider);

  static String get _appDebug => dotenv.env['APP_DEBUG'] == 'true';
  if (_appDebug) {
    await storage.clearAllData(); // debug
  }

  // cek apakah sudah ada data di storage, buat jika belum ada
  await storage.initIfEmpty();

  final appState = await storage.getAppState();
  final authType = await storage.getAuthType();
  final loginStatus = await storage.getLoginStatus();

  // for local auth type and online, and log
  if (appState == AppState.registered) {
    if (authType == AuthType.local) {
      return 'home'; // local auth type, go to home screen
    }

    if (authType == AuthType.online && loginStatus == LoginStatus.loggedIn) {
      return 'home';
    }

    if (authType == AuthType.online && loginStatus == LoginStatus.loggedOut) {
      return 'login';
    }
  }
  return 'unregistered';
});
