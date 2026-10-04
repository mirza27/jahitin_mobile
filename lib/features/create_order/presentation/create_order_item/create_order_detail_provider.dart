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

  String _formatDateTimeWithOffset(DateTime dateTime) {
    final offset = dateTime.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$year-$month-${day}T$hour:$minute:$second$sign$hours:$minutes';
  }

  CreateOrderRequest buildCreateOrderRequest({bool isDraft = false}) {
    final orderName = state.orderName.isNotEmpty
        ? state.orderName
        : (state.customer?.displayName ?? 'Pesanan Baru');

    final deadlineStr = state.deadline != null
        ? _formatDateTimeWithOffset(state.deadline!)
        : '';

    final orderItems = state.orderItems.map((item) {
      return CreateOrderItemRequest(
        clothesFor: item.clothesFor.isNotEmpty
            ? item.clothesFor
            : (state.customer?.displayName ?? ''),
        categoryId: item.clothesCategoryId,
        serviceId: item.serviceTypeId,
        customServiceName: item.serviceTypeId == null
            ? item.customServiceName
            : null,
        price: item.price.toInt(),
        notes: item.notes ?? '',
        saveCustomerNotes: item.saveCustomerNotes,
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
