import '../../model/detail_order.dart';

enum DetailOrderStatus { initial, loading, loaded, error }

class DetailOrderState {
  final DetailOrderStatus status;
  final DetailOrder? detailOrder;
  final String? message;

  const DetailOrderState({
    this.status = DetailOrderStatus.initial,
    this.detailOrder,
    this.message,
  });

  DetailOrderState copyWith({
    DetailOrderStatus? status,
    DetailOrder? detailOrder,
    String? message,
  }) {
    return DetailOrderState(
      status: status ?? this.status,
      detailOrder: detailOrder ?? this.detailOrder,
      message: message ?? this.message,
    );
  }
}
