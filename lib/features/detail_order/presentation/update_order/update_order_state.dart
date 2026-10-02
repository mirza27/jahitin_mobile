import 'package:jahitin_mobile/core/models/clothes_category.dart';
import 'package:jahitin_mobile/core/models/service_type.dart';

import '../../model/update_detail_order.dart';

enum UpdateOrderStatus { initial, loading, loaded, updating, success, error }

class UpdateOrderState {
  final UpdateOrderStatus status;
  final bool anyChanges;
  final String? errorMessage;
  final String orderId;
  final UpdateDetailOrder? existingDetailOrder;
  final UpdateDetailOrder? updatedDetailOrder;
  final List<ClothesCategoryModel> categories;
  final List<ServiceTypeModel> serviceTypes;
  final bool isLoadingReferences;

  const UpdateOrderState({
    this.status = UpdateOrderStatus.initial,
    this.anyChanges = false,
    this.errorMessage,
    required this.orderId,
    this.existingDetailOrder,
    this.updatedDetailOrder,
    this.categories = const [],
    this.serviceTypes = const [],
    this.isLoadingReferences = false,
  });

  UpdateOrderState copyWith({
    UpdateOrderStatus? status,
    bool? anyChanges,
    String? errorMessage,
    String? orderId,
    UpdateDetailOrder? existingDetailOrder,
    UpdateDetailOrder? updatedDetailOrder,
    List<ClothesCategoryModel>? categories,
    List<ServiceTypeModel>? serviceTypes,
    bool? isLoadingReferences,
  }) {
    return UpdateOrderState(
      status: status ?? this.status,
      anyChanges: anyChanges ?? this.anyChanges,
      errorMessage: errorMessage ?? this.errorMessage,
      orderId: orderId ?? this.orderId,
      existingDetailOrder: existingDetailOrder ?? this.existingDetailOrder,
      updatedDetailOrder: updatedDetailOrder ?? this.updatedDetailOrder,
      categories: categories ?? this.categories,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      isLoadingReferences: isLoadingReferences ?? this.isLoadingReferences,
    );
  }
}
