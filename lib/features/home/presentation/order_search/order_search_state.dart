import 'package:jahitin_mobile/features/home/model/order_display.dart';

enum OrderSearchStatus { initial, loading, loaded, error }

class OrderSearchState {
  final OrderSearchStatus status;
  final String? searchQuery;
  final String? message;
  final List<OrderDisplay> orderList;

  const OrderSearchState({
    this.status = OrderSearchStatus.initial,
    this.searchQuery,
    this.message,
    this.orderList = const [],
  });

  OrderSearchState copyWith({
    OrderSearchStatus? status,
    String? searchQuery,
    String? message,
    List<OrderDisplay>? orderList,
  }) {
    return OrderSearchState(
      status: status ?? this.status,
      message: message ?? this.message,
      searchQuery: searchQuery ?? this.searchQuery,
      orderList: orderList ?? this.orderList,
    );
  }
}
