import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/models/clothes_category.dart';
import 'package:jahitin_mobile/core/models/service_type.dart';
import '../../../../core/data/clothes_category_api.dart';
import '../../../../core/data/order_api.dart';
import '../../../../core/data/service_type_api.dart';
import '../../../../core/services/storage_service.dart';
import '../../model/detail_order.dart';
import '../../model/update_detail_order.dart';
import 'update_order_state.dart';

class UpdateOrderNotifier
    extends AutoDisposeFamilyNotifier<UpdateOrderState, DetailOrder> {
  @override
  UpdateOrderState build(DetailOrder initialOrder) {
    final initialDetail = UpdateDetailOrder.fromDetailOrder(initialOrder);

    Future.microtask(() => loadReferences());

    return UpdateOrderState(
      status: UpdateOrderStatus.loaded,
      orderId: initialOrder.orderId,
      existingDetailOrder: initialDetail,
      updatedDetailOrder: initialDetail,
    );
  }

  Future<void> loadReferences() async {
    state = state.copyWith(isLoadingReferences: true);
    try {
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getToken();

      final categoryApi = ref.read(clothesCategoryApiProvider);
      final serviceTypeApi = ref.read(serviceTypeApiProvider);

      final results = await Future.wait([
        categoryApi.getCategories(token: token),
        serviceTypeApi.getServiceTypes(token: token),
      ]);

      state = state.copyWith(
        categories: results[0] as List<ClothesCategoryModel>,
        serviceTypes: results[1] as List<ServiceTypeModel>,
        isLoadingReferences: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingReferences: false);
    }
  }

  void addJobItem(UpdateOrderItem item) {
    if (state.updatedDetailOrder == null) return;
    final currentItems = List<UpdateOrderItem>.from(
      state.updatedDetailOrder!.orderItems,
    );
    currentItems.add(item);

    final updated = state.updatedDetailOrder!.copyWith(
      orderItems: currentItems,
    );
    final dirty = _checkDirty(updated);

    state = state.copyWith(updatedDetailOrder: updated, anyChanges: dirty);
  }

  void updateJobItem(int index, UpdateOrderItem item) {
    if (state.updatedDetailOrder == null) return;
    final currentItems = List<UpdateOrderItem>.from(
      state.updatedDetailOrder!.orderItems,
    );
    if (index < 0 || index >= currentItems.length) return;

    currentItems[index] = item;
    final updated = state.updatedDetailOrder!.copyWith(
      orderItems: currentItems,
    );
    final dirty = _checkDirty(updated);

    state = state.copyWith(updatedDetailOrder: updated, anyChanges: dirty);
  }

  void removeJobItem(int index) {
    if (state.updatedDetailOrder == null) return;
    final currentItems = List<UpdateOrderItem>.from(
      state.updatedDetailOrder!.orderItems,
    );
    if (index < 0 || index >= currentItems.length) return;

    currentItems.removeAt(index);
    final updated = state.updatedDetailOrder!.copyWith(
      orderItems: currentItems,
    );
    final dirty = _checkDirty(updated);

    state = state.copyWith(updatedDetailOrder: updated, anyChanges: dirty);
  }

  void updateItemStatus(int index, String newStatus) {
    if (state.updatedDetailOrder == null) return;
    final currentItems = List<UpdateOrderItem>.from(
      state.updatedDetailOrder!.orderItems,
    );
    if (index < 0 || index >= currentItems.length) return;

    currentItems[index] = currentItems[index].copyWith(status: newStatus);
    final updated = state.updatedDetailOrder!.copyWith(
      orderItems: currentItems,
    );
    final dirty = _checkDirty(updated);

    state = state.copyWith(updatedDetailOrder: updated, anyChanges: dirty);
  }

  bool _checkDirty(UpdateDetailOrder updated) {
    final existing = state.existingDetailOrder;
    if (existing == null) return false;
    return existing != updated;
  }

  Future<bool> submitUpdate() async {
    if (state.updatedDetailOrder == null) return false;

    state = state.copyWith(
      status: UpdateOrderStatus.updating,
      errorMessage: null,
    );

    try {
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getToken();

      final orderApi = ref.read(orderApiProvider);
      final payload = state.updatedDetailOrder!.toPayloadJson();

      await orderApi.updateOrder(state.orderId, payload, token: token);

      state = state.copyWith(
        status: UpdateOrderStatus.success,
        anyChanges: false,
        existingDetailOrder: state.updatedDetailOrder,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: UpdateOrderStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

final updateOrderProvider = NotifierProvider.autoDispose
    .family<UpdateOrderNotifier, UpdateOrderState, DetailOrder>(
      UpdateOrderNotifier.new,
    );
