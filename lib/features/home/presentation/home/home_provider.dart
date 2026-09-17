import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/data/order_api.dart';
import 'package:jahitin_mobile/core/services/storage_service.dart';
import 'package:jahitin_mobile/features/auth/auth_provider.dart';
import 'package:jahitin_mobile/features/auth/auth_state.dart';
import 'package:jahitin_mobile/features/home/presentation/home/home_state.dart';
import 'package:jahitin_mobile/features/home/model/order_display.dart';

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    final authState = ref.watch(authProvider);

    // Initial state with user from auth
    final initialState = HomeState(
      status: HomeStatus.initial,
      user: authState.user,
      selectedTab: HomeTab.active,
    );

    // Auto-fetch orders if user is authenticated
    if (authState.status == AuthStatus.authenticated) {
      Future.microtask(() => fetchOrders());
    }

    return initialState;
  }

  Future<void> fetchOrders() async {
    final authState = ref.read(authProvider);

    if (authState.status != AuthStatus.authenticated) {
      state = state.copyWith(
        status: HomeStatus.error,
        message: 'Pengguna belum terautentikasi',
      );
      return;
    }

    state = state.copyWith(status: HomeStatus.loading);

    try {
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getToken();

      final orderApi = ref.read(orderApiProvider);
      final rawOrders = await orderApi.getUserOrders(token: token);

      final orders = rawOrders
          .map((json) => OrderDisplay.fromJson(json))
          .toList();

      state = state.copyWith(
        status: HomeStatus.loaded,
        user: authState.user,
        orderList: orders,
        activeOrderCount: orders
            .where(
              (o) =>
                  o.orderStatus == OrderStatus.pending ||
                  o.orderStatus == OrderStatus.inProgress,
            )
            .length,
      );
    } catch (e) {
      state = state.copyWith(status: HomeStatus.error, message: e.toString());
    }
  }

  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  void setTab(HomeTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void toggleSidebar() {
    state = state.copyWith(sidebarActive: !state.sidebarActive);
  }

  void setSidebarActive(bool active) {
    state = state.copyWith(sidebarActive: active);
  }

  void updateActiveOrderCount(int count) {
    state = state.copyWith(activeOrderCount: count);
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
