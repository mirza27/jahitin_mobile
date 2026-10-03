import 'package:jahitin_mobile/core/models/user.dart';
import 'package:jahitin_mobile/features/home/model/order_display.dart';

enum HomeStatus { initial, loading, loaded, error }

enum HomeTab { active, completed, all }

class HomeState {
  final HomeStatus status;
  final User? user;
  final String? message;
  final int activeOrderCount;
  final HomeTab selectedTab;
  final List<OrderDisplay> orderList;

  const HomeState({
    this.status = HomeStatus.initial,
    this.user,
    this.message,
    this.activeOrderCount = 0,
    this.selectedTab = HomeTab.active,
    this.orderList = const [],
  });

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
  List<OrderDisplay> get displayedOrders {
    switch (selectedTab) {
      case HomeTab.active:
        return activeOrders;
      case HomeTab.completed:
        return completedOrders;
      case HomeTab.all:
        return orderList;
    }
  }

  HomeState copyWith({
    HomeStatus? status,
    User? user,
    String? message,
    int? activeOrderCount,
    HomeTab? selectedTab,
    List<OrderDisplay>? orderList,
  }) {
    return HomeState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message ?? this.message,
      activeOrderCount: activeOrderCount ?? this.activeOrderCount,
      selectedTab: selectedTab ?? this.selectedTab,
      orderList: orderList ?? this.orderList,
    );
  }
}
