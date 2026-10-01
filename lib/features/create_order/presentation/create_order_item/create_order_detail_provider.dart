import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/clothes_category_api.dart';
import '../../../../core/data/order_api.dart';
import '../../../../core/data/service_type_api.dart';
import '../../../../core/models/job_item.dart';
import '../../../../core/services/storage_service.dart';
import '../../../detail_order/model/update_detail_order.dart';
import '../../model/create_order_request.dart';
import '../create_order/create_order_provider.dart';
import 'create_order_detail_state.dart';

class CreateOrderDetailNotifier extends Notifier<CreateOrderDetailState> {
  @override
  CreateOrderDetailState build() {
    final step1State = ref.watch(createOrderProvider);

    return CreateOrderDetailState(
      status: OrderDetailStatus.ready,
      customer: step1State.selectedCustomer,
      deadline: step1State.deadline,
      orderNotes: step1State.notes,
      jobs: const [],
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

  void addJob(JobItem job) {
    state = state.copyWith(jobs: [...state.jobs, job]);
  }

  void updateJob(JobItem updatedJob) {
    state = state.copyWith(
      jobs: state.jobs
          .map((j) => j.id == updatedJob.id ? updatedJob : j)
          .toList(),
    );
  }

  void removeJob(String jobId) {
    state = state.copyWith(
      jobs: state.jobs.where((j) => j.id != jobId).toList(),
    );
  }

  void setDownPayment(double amount) {
    state = state.copyWith(downPayment: amount);
  }

  CreateOrderRequest buildCreateOrderRequest({bool isDraft = false}) {
    final orderName = state.orderNotes.isNotEmpty
        ? state.orderNotes
        : (state.customer?.displayName ?? 'Pesanan');

    final deadlineStr = state.deadline != null
        ? state.deadline!.toIso8601String()
        : DateTime.now().toIso8601String();

    final orderItems = state.jobs.map((job) {
      return CreateOrderItemRequest(
        clothesFor: job.recipientName.isNotEmpty
            ? job.recipientName
            : (state.customer?.displayName ?? ''),
        notes: job.notes ?? '',
        categoryId: job.resolvedCategoryId,
        serviceId: job.resolvedServiceTypeId,
        customServiceName: job.customServiceName ?? job.customCategoryName ?? '',
        price: job.estimatedCost,
        saveCustomerNotes: false,
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
