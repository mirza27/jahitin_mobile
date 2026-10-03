import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/models/clothes_category.dart';
import 'package:jahitin_mobile/core/models/service_type.dart';
import 'package:jahitin_mobile/features/create_order/model/create_order_item.dart';
import '../../../../core/data/clothes_category_api.dart';
import '../../../../core/data/order_api.dart';
import '../../../../core/data/service_type_api.dart';
import '../../../../core/services/storage_service.dart';
import '../../model/create_order_request.dart';
import '../create_order/create_order_provider.dart';
import 'create_order_detail_state.dart';

class CreateOrderDetailNotifier extends Notifier<CreateOrderDetailState> {
  @override
  CreateOrderDetailState build() {
    final step1State = ref.watch(createOrderProvider);

    return CreateOrderDetailState(
      status: OrderDetailStatus.ready,
      orderName: step1State.orderName.isNotEmpty
          ? step1State.orderName
          : 'Pesanan Baru',
      customer: step1State.selectedCustomer,
      deadline: step1State.deadline,
      orderNotes: step1State.notes,
      saveCustomerNotes: step1State.saveCustomerNotes,
      orderItems: const [],
      downPayment: 0,
    );
  }

  /// Memuat daftar kategori pakaian & jenis layanan dari API (/category/list & /service/list)
  Future<void> loadCategoriesAndServices() async {
    state = state.copyWith(isLoadingOptions: true, optionsErrorMessage: null);
    try {
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getToken();
      final categoryApi = ref.read(clothesCategoryApiProvider);
      final serviceApi = ref.read(serviceTypeApiProvider);

      final results = await Future.wait([
        categoryApi.getCategories(token: token),
        serviceApi.getServiceTypes(token: token),
      ]);

      final categories = results[0] as List<ClothesCategoryModel>;
      final services = results[1] as List<ServiceTypeModel>;

      state = state.copyWith(
        clothesCategories: categories,
        serviceTypes: services,
        isLoadingOptions: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingOptions: false,
        optionsErrorMessage: e.toString(),
      );
    }
  }

  void addOrderItem(CreateOrderItem orderItem) {
    state = state.copyWith(orderItems: [...state.orderItems, orderItem]);
  }

  void updateOrderItem(CreateOrderItem updatedOrderItem) {
    state = state.copyWith(
      orderItems: state.orderItems
          .map(
            (item) => item.id == updatedOrderItem.id ? updatedOrderItem : item,
          )
          .toList(),
    );
  }

  void removeOrderItem(String orderItemId) {
    state = state.copyWith(
      orderItems: state.orderItems
          .where((item) => item.id != orderItemId)
          .toList(),
    );
  }

  void setDownPayment(double amount) {
    state = state.copyWith(downPayment: amount);
  }

  CreateOrderRequest buildCreateOrderRequest({bool isDraft = false}) {
    final orderName = state.orderName.isNotEmpty
        ? state.orderName
        : (state.orderNotes.isNotEmpty
              ? state.orderNotes
              : (state.customer?.displayName ?? 'Pesanan'));

    final deadlineStr = state.deadline != null
        ? state.deadline!.toIso8601String()
        : '';

    final orderItems = state.orderItems.map((item) {
      return CreateOrderItemRequest(
        clothesFor: item.clothesFor.isNotEmpty
            ? item.clothesFor
            : (state.customer?.displayName ?? ''),
        notes: item.notes ?? '',
        categoryId: item.clothesCategoryId ?? 1,
        serviceId: item.serviceTypeId,
        customServiceName: item.customServiceName ?? '',
        price: item.price,
        saveCustomerNotes: state.saveCustomerNotes,
      );
    }).toList();

    return CreateOrderRequest(
      name: orderName,
      deadline: deadlineStr,
      customerContact: state.customer!,
      orderItems: orderItems,
    );
  }

  Future<bool> submitOrder({bool isDraft = false}) async {
    if (!state.canSubmit) return false;

    state = state.copyWith(
      status: OrderDetailStatus.submitting,
      errorMessage: null,
    );

    try {
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getToken();
      final orderApi = ref.read(orderApiProvider);

      final request = buildCreateOrderRequest(isDraft: isDraft);
      final payload = request.toJson();

      await orderApi.createUserOrder(payload, token: token);

      state = state.copyWith(status: OrderDetailStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OrderDetailStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = build();
  }
}

final createOrderDetailProvider =
    NotifierProvider<CreateOrderDetailNotifier, CreateOrderDetailState>(
      CreateOrderDetailNotifier.new,
    );
