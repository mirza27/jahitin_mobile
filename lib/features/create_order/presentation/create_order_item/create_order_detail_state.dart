import '../../../../core/models/job_item.dart';
import '../../../detail_order/model/update_detail_order.dart';
import '../../model/customer_contact.dart';

enum OrderDetailStatus { initial, loading, ready, submitting, success, error }

class CreateOrderDetailState {
  final OrderDetailStatus status;
  final CustomerContact? customer;
  final DateTime? deadline;
  final String orderNotes;
  final List<JobItem> jobs;
  final double downPayment;
  final String? errorMessage;
  final List<ClothesCategoryModel> clothesCategories;
  final List<ServiceTypeModel> serviceTypes;
  final bool isLoadingOptions;
  final String? optionsErrorMessage;

  const CreateOrderDetailState({
    this.status = OrderDetailStatus.ready,
    this.customer,
    this.deadline,
    this.orderNotes = '',
    this.jobs = const [],
    this.downPayment = 0,
    this.errorMessage,
    this.clothesCategories = const [],
    this.serviceTypes = const [],
    this.isLoadingOptions = false,
    this.optionsErrorMessage,
  });

  double get totalCost =>
      jobs.fold(0.0, (sum, item) => sum + item.estimatedCost);

  double get remainingBalance =>
      (totalCost - downPayment).clamp(0.0, double.infinity);

  bool get canSubmit =>
      customer != null &&
      deadline != null &&
      jobs.isNotEmpty &&
      status != OrderDetailStatus.submitting;

  CreateOrderDetailState copyWith({
    OrderDetailStatus? status,
    CustomerContact? customer,
    DateTime? deadline,
    String? orderNotes,
    List<JobItem>? jobs,
    double? downPayment,
    String? errorMessage,
    List<ClothesCategoryModel>? clothesCategories,
    List<ServiceTypeModel>? serviceTypes,
    bool? isLoadingOptions,
    String? optionsErrorMessage,
  }) {
    return CreateOrderDetailState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      deadline: deadline ?? this.deadline,
      orderNotes: orderNotes ?? this.orderNotes,
      jobs: jobs ?? this.jobs,
      downPayment: downPayment ?? this.downPayment,
      errorMessage: errorMessage ?? this.errorMessage,
      clothesCategories: clothesCategories ?? this.clothesCategories,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
      optionsErrorMessage: optionsErrorMessage ?? this.optionsErrorMessage,
    );
  }
}

