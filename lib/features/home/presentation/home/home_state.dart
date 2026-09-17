import 'package:jahitin_mobile/core/models/user.dart';
import 'package:jahitin_mobile/features/home/model/order_display.dart';

enum HomeStatus { initial, loading, loaded, error }

enum HomeTab { active, completed }

class HomeState {
  final HomeStatus status;
  final User? user;
  final String? message;
  final int activeOrderCount;
  final HomeTab selectedTab;
  final List<OrderDisplay> orderList;
  final bool sidebarActive;

  const HomeState({
    this.status = HomeStatus.initial,
    this.user,
    this.message,
    this.activeOrderCount = 0,
    this.selectedTab = HomeTab.active,
    this.orderList = const [],
    this.sidebarActive = false,
  });

  /// Nama user untuk greeting header, fallback ke 'Pengguna' jika null.
  String get userName => user?.name ?? 'Pengguna';

  /// Teks greeting lengkap untuk header.
  String get greetingText => 'Halo, $userName \u{1F44B}';

  /// Daftar pesanan aktif (pending / in progress).
  List<OrderDisplay> get activeOrders => orderList
      .where(
        (o) =>
            o.orderStatus == OrderStatus.pending ||
            o.orderStatus == OrderStatus.inProgress,
      )
      .toList();

  /// Daftar pesanan selesai (completed / picked up).
  List<OrderDisplay> get completedOrders => orderList
      .where(
        (o) =>
            o.orderStatus == OrderStatus.completed ||
            o.orderStatus == OrderStatus.pickedUp,
      )
      .toList();

  /// Daftar pesanan yang ditampilkan sesuai tab yang dipilih.
  List<OrderDisplay> get displayedOrders =>
      selectedTab == HomeTab.active ? activeOrders : completedOrders;

  /// Teks subtitle berisi jumlah pesanan aktif.
  String get activeOrderSummary =>
      'Anda memiliki ${activeOrders.length} pesanan aktif';

  HomeState copyWith({
    HomeStatus? status,
    User? user,
    String? message,
    int? activeOrderCount,
    HomeTab? selectedTab,
    List<OrderDisplay>? orderList,
    bool? sidebarActive,
    bool? searchActive,
  }) {
    return HomeState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message ?? this.message,
      activeOrderCount: activeOrderCount ?? this.activeOrderCount,
      selectedTab: selectedTab ?? this.selectedTab,
      orderList: orderList ?? this.orderList,
      sidebarActive: sidebarActive ?? this.sidebarActive,
    );
  }
}
