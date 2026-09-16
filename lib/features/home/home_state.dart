import 'package:jahitin_mobile/core/models/user.dart';

enum HomeStatus { initial, loading, loaded, error }

enum HomeTab { active, completed }

class HomeState {
  final HomeStatus status;
  final User? user;
  final String? message;
  final int activeOrderCount;
  final HomeTab selectedTab;

  const HomeState({
    this.status = HomeStatus.initial,
    this.user,
    this.message,
    this.activeOrderCount = 0,
    this.selectedTab = HomeTab.active,
  });

  /// Nama user untuk greeting header, fallback ke 'Pengguna' jika null.
  String get userName => user?.name ?? 'Pengguna';

  /// Teks greeting lengkap untuk header.
  String get greetingText => 'Halo, $userName \u{1F44B}';

  /// Teks subtitle berisi jumlah pesanan aktif.
  String get activeOrderSummary =>
      'Anda memiliki $activeOrderCount pesanan aktif';

  HomeState copyWith({
    HomeStatus? status,
    User? user,
    String? message,
    int? activeOrderCount,
    HomeTab? selectedTab,
  }) {
    return HomeState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message ?? this.message,
      activeOrderCount: activeOrderCount ?? this.activeOrderCount,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}
