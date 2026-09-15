import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/features/splash/splash_provider.dart';
import 'package:jahitin_mobile/features/splash/splash_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../../registration/screens/registration_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(splashProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final splash = ref.watch(splashProvider);

    if (splash.status != SplashStatus.success || splash.appState == null) {
      return _buildSplashView();
    }

    switch (splash.appState!) {
      case AppState.registered:
        return const LoginScreen();
      case AppState.unregistered:
        return const RegistrationScreen();
    }
  }

  Widget _buildSplashView() {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.content_cut_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jahitin',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manajemen Order Penjahit',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
