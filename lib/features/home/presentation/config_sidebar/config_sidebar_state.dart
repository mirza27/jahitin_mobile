class ConfigSidebarState {
  final bool isOpen;

  const ConfigSidebarState({
    this.isOpen = false,
  });

  ConfigSidebarState copyWith({
    bool? isOpen,
  }) {
    return ConfigSidebarState(
      isOpen: isOpen ?? this.isOpen,
    );
  }
}
