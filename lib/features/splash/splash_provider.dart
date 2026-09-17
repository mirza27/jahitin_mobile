import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/services/storage_service.dart';
import 'package:jahitin_mobile/core/constants/storage_keys.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jahitin_mobile/features/splash/splash_state.dart';

class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() {
    return const SplashState();
  }

  Future<void> initialize() async {
    state = state.copyWith(status: SplashStatus.initial);

    final appDebug = dotenv.env['APP_DEBUG'] == 'true';
    final storage = ref.read(storageServiceProvider);

    if (appDebug) {
      // await storage.clearAllData();
    }

    await storage.initIfEmpty();

    state = state.copyWith(status: SplashStatus.loading);

    final storageAppState = await storage.getAppState();

    await storage.setDeviceId('bocil');

    // check version and API for update, if needed
    // ...

    if (storageAppState == StorageAppState.registered) {
      state = state.copyWith(appState: AppState.registered);
    } else {
      state = state.copyWith(appState: AppState.unregistered);
    }

    state = state.copyWith(status: SplashStatus.success);
  }
}

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
