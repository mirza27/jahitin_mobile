import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/data/order_api.dart';
import 'package:jahitin_mobile/core/services/storage_service.dart';
import 'package:jahitin_mobile/features/auth/auth_provider.dart';
import 'package:jahitin_mobile/features/auth/auth_state.dart';
import 'package:jahitin_mobile/features/home/model/order_display.dart';
import 'package:jahitin_mobile/features/home/presentation/order_search/order_search_state.dart';

final orderApiProvider = Provider<OrderApi>((ref) {
  return OrderApi();
});

class OrderSearchNotifier extends Notifier<OrderSearchState> {
  @override
  OrderSearchState build() {
    return const OrderSearchState(
      status: OrderSearchStatus.initial,
      searchQuery: '',
      statusFilter: OrderStatusFilter.all,
      orderList: [],
    );
  }

  Future<void> fetchOrders(
    String query, {
    OrderStatusFilter? statusFilter,
  }) async {
    final targetFilter = statusFilter ?? state.statusFilter;
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      state = state.copyWith(
        status: OrderSearchStatus.initial,
        searchQuery: '',
        statusFilter: targetFilter,
        orderList: [],
        message: null,
      );
      return;
    }

    final authState = ref.read(authProvider);

    if (authState.status != AuthStatus.authenticated) {
      state = state.copyWith(
        status: OrderSearchStatus.error,
        message: 'Pengguna belum terautentikasi',
      );
      return;
    }

    state = state.copyWith(
      status: OrderSearchStatus.loading,
      searchQuery: trimmed,
      statusFilter: targetFilter,
    );

    try {
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getToken();

      final orderApi = ref.read(orderApiProvider);
      final rawOrders = await orderApi.getUserOrders(
        token: token,
        search: trimmed,
        status: targetFilter.apiValue,
      );

      final searchResults = rawOrders
          .map((json) => OrderDisplay.fromJson(json))
          .toList();

      state = state.copyWith(
        status: OrderSearchStatus.loaded,
        orderList: searchResults,
      );
    } catch (e) {
      state = state.copyWith(
        status: OrderSearchStatus.error,
        message: 'Gagal mencari pesanan: ${e.toString()}',
      );
    }
  }

  void setStatusFilter(OrderStatusFilter filter) {
    if (state.statusFilter == filter) return;
    state = state.copyWith(statusFilter: filter);
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      fetchOrders(state.searchQuery!, statusFilter: filter);
    }
  }

  void clearSearch() {
    state = const OrderSearchState(
      status: OrderSearchStatus.initial,
      searchQuery: '',
      statusFilter: OrderStatusFilter.all,
      orderList: [],
    );
  }
}

final orderSearchProvider =
    NotifierProvider<OrderSearchNotifier, OrderSearchState>(
  OrderSearchNotifier.new,
);

