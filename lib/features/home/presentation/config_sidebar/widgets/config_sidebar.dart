import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../../home/home_provider.dart';
import '../../settings/screens/settings_screen.dart';
import '../config_sidebar_provider.dart';

class ConfigSidebar extends ConsumerWidget {
  const ConfigSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarState = ref.watch(configSidebarProvider);
    final isOpen = sidebarState.isOpen;
    final homeState = ref.watch(homeProvider);
    final user = homeState.user;

    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = (screenWidth * 0.75).clamp(260.0, 320.0);

    return IgnorePointer(
      ignoring: !isOpen,
      child: Stack(
        children: [
          // Backdrop / Scrim
          AnimatedOpacity(
            opacity: isOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () =>
                  ref.read(configSidebarProvider.notifier).setOpen(false),
              child: Container(
                color: Colors.black45,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Sidebar Panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            left: isOpen ? 0 : -sidebarWidth,
            width: sidebarWidth,
            child: Material(
              color: AppColors.surface,
              elevation: 16,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Sidebar
                    _buildHeader(context, ref, user?.name, user?.email),
                    const Divider(height: 1, color: AppColors.divider),

                    // Menu Items
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          // Menu Akun (Disabled / Commented)
                          // _buildMenuItem(
                          //   icon: Icons.person_outline,
                          //   title: context.tr('account'),
                          //   onTap: () {
                          //     ref
                          //         .read(configSidebarProvider.notifier)
                          //         .setOpen(false);
                          //   },
                          // ),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            title: context.tr('settings'),
                            onTap: () {
                              ref
                                  .read(configSidebarProvider.notifier)
                                  .setOpen(false);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    const Divider(height: 1, color: AppColors.divider),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    String? name,
    String? email,
  ) {
    final defaultName = context.tr('default_user_name');
    final avatarLetter = (name != null && name.isNotEmpty)
        ? name[0].toUpperCase()
        : (defaultName.isNotEmpty ? defaultName[0].toUpperCase() : 'U');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              avatarLetter,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name ?? defaultName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (email != null && email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () =>
                ref.read(configSidebarProvider.notifier).setOpen(false),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textPrimary,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textHint,
        size: 18,
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('app_name'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('sidebar_tagline'),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
