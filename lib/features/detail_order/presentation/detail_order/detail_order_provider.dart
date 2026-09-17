import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/data/order_api.dart';
import 'package:jahitin_mobile/core/services/storage_service.dart';
import '../../model/detail_order.dart';
import 'detail_order_state.dart';

class DetailOrderNotifier
    extends AutoDisposeFamilyNotifier<DetailOrderState, String> {
  @override
  DetailOrderState build(String orderId) {
    Future.microtask(() => fetchDetailOrder(orderId));
    return const DetailOrderState(status: DetailOrderStatus.loading);
  }

  Future<void> fetchDetailOrder(String orderId) async {
    state = state.copyWith(status: DetailOrderStatus.loading);

    try {
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getToken();

      final orderApi = ref.read(orderApiProvider);
      final data = await orderApi.getUserOrderDetail(orderId, token: token);
      final detail = DetailOrder.fromJson(data);

      state = state.copyWith(
        status: DetailOrderStatus.loaded,
        detailOrder: detail,
      );
    } catch (e) {
      state = state.copyWith(
        status: DetailOrderStatus.error,
        message: e.toString(),
      );
    }
  }
}

final detailOrderProvider =
    NotifierProvider.autoDispose.family<DetailOrderNotifier, DetailOrderState, String>(
  DetailOrderNotifier.new,
);
