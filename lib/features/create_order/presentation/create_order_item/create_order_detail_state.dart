import 'package:jahitin_mobile/core/models/clothes_category.dart';
import 'package:jahitin_mobile/core/models/service_type.dart';
import 'package:jahitin_mobile/features/create_order/model/create_order_item.dart';

import '../../model/customer_contact.dart';

enum OrderDetailStatus { initial, loading, ready, submitting, success, error }

class CreateOrderDetailState {
  final OrderDetailStatus status;
  final String orderName;
  final CustomerContact? customer;
  final DateTime? deadline;
  final String orderNotes;
  final bool saveCustomerNotes;
  final List<CreateOrderItem> orderItems;
  final double downPayment;
  final String? errorMessage;
  final List<ClothesCategoryModel> clothesCategories;
  final List<ServiceTypeModel> serviceTypes;
  final bool isLoadingOptions;
  final String? optionsErrorMessage;

  const CreateOrderDetailState({
    this.status = OrderDetailStatus.ready,
    this.orderName = '',
    this.customer,
    this.deadline,
    this.orderNotes = '',
    this.saveCustomerNotes = false,
    this.orderItems = const [],
    this.downPayment = 0,
    this.errorMessage,
    this.clothesCategories = const [],
    this.serviceTypes = const [],
    this.isLoadingOptions = false,
    this.optionsErrorMessage,
  });

  double get totalCost =>
      orderItems.fold(0.0, (sum, item) => sum + item.price);

  double get remainingBalance =>
      (totalCost - downPayment).clamp(0.0, double.infinity);

  bool get canSubmit =>
      customer != null &&
      orderItems.isNotEmpty &&
      status != OrderDetailStatus.submitting;

  CreateOrderDetailState copyWith({
    OrderDetailStatus? status,
    String? orderName,
    CustomerContact? customer,
    DateTime? deadline,
    String? orderNotes,
    bool? saveCustomerNotes,
    List<CreateOrderItem>? orderItems,
    double? downPayment,
    String? errorMessage,
    List<ClothesCategoryModel>? clothesCategories,
    List<ServiceTypeModel>? serviceTypes,
    bool? isLoadingOptions,
    String? optionsErrorMessage,
  }) {
    return CreateOrderDetailState(
      status: status ?? this.status,
      orderName: orderName ?? this.orderName,
      customer: customer ?? this.customer,
      deadline: deadline ?? this.deadline,
      orderNotes: orderNotes ?? this.orderNotes,
      saveCustomerNotes: saveCustomerNotes ?? this.saveCustomerNotes,
      orderItems: orderItems ?? this.orderItems,
      downPayment: downPayment ?? this.downPayment,
      errorMessage: errorMessage ?? this.errorMessage,
      clothesCategories: clothesCategories ?? this.clothesCategories,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
      optionsErrorMessage: optionsErrorMessage ?? this.optionsErrorMessage,
    );
  }
}
