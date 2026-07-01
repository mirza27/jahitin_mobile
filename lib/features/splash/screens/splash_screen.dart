import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/features/home/sreens/home_screens.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/storage_provider.dart';
import '../../registration/screens/registration_screen.dart';
import '../../auth/screens/login_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // cek state awal
    final routeAsync = ref.watch(initialRouteProvider);

    routeAsync.whenData((route) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        late final Widget target;

        if (route == 'home') {
          target = const HomeScreen();
        }

        if (route == 'login') {
          target = const LoginScreen();
        }

        if (route == 'unregistered') {
          target = const RegistrationScreen();
        }

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => target));
      });
    });

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
            routeAsync.when(
              data: (_) => const SizedBox.shrink(),
              loading: () => const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
              error: (e, _) => Column(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(height: 8),
                  Text(
                    'Gagal memuat: $e',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
