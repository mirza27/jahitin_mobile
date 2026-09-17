import 'package:jahitin_mobile/features/home/model/order_display.dart';

enum OrderSearchStatus { initial, loading, loaded, error }

/// Nilai filter status yang dikirim ke API.
/// Gunakan [OrderStatusFilter.all] untuk tidak memfilter status (semua order).
enum OrderStatusFilter { all, active, completed }

extension OrderStatusFilterX on OrderStatusFilter {
  /// Nilai string yang dikirim ke parameter `status` API.
  /// Mengembalikan null jika filter adalah 'all' (tidak ada filter status).
  String? get apiValue {
    switch (this) {
      case OrderStatusFilter.all:
        return null;
      case OrderStatusFilter.active:
        return 'active';
      case OrderStatusFilter.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case OrderStatusFilter.all:
        return 'Semua';
      case OrderStatusFilter.active:
        return 'Aktif';
      case OrderStatusFilter.completed:
        return 'Selesai';
    }
  }
}

class OrderSearchState {
  final OrderSearchStatus status;
  final String? searchQuery;
  final OrderStatusFilter statusFilter;
  final String? message;
  final List<OrderDisplay> orderList;

  const OrderSearchState({
    this.status = OrderSearchStatus.initial,
    this.searchQuery,
    this.statusFilter = OrderStatusFilter.all,
    this.message,
    this.orderList = const [],
  });

  OrderSearchState copyWith({
    OrderSearchStatus? status,
    String? searchQuery,
    OrderStatusFilter? statusFilter,
    String? message,
    List<OrderDisplay>? orderList,
  }) {
    return OrderSearchState(
      status: status ?? this.status,
      message: message ?? this.message,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      orderList: orderList ?? this.orderList,
    );
  }
}
