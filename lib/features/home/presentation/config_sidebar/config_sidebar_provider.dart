import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config_sidebar_state.dart';

class ConfigSidebarNotifier extends Notifier<ConfigSidebarState> {
  @override
  ConfigSidebarState build() {
    return const ConfigSidebarState();
  }

  void toggle() {
    state = state.copyWith(isOpen: !state.isOpen);
  }

  void setOpen(bool isOpen) {
    state = state.copyWith(isOpen: isOpen);
  }
}

final configSidebarProvider =
    NotifierProvider<ConfigSidebarNotifier, ConfigSidebarState>(
  ConfigSidebarNotifier.new,
);
