import 'package:jahitin_mobile/core/models/clothes_category.dart';
import 'package:jahitin_mobile/core/models/service_type.dart';

import '../../../../core/models/job_item.dart';

class HandleOrderItemState {
  final String? itemId;
  final String recipientName;
  final int? selectedCategoryId;
  final String? categoryName;
  final int? selectedServiceTypeId;
  final String? serviceName;
  final String? customServiceName;
  final bool isCustomServiceMode;
  final double? cost;
  final String? notes;

  final List<ClothesCategoryModel> categories;
  final List<ServiceTypeModel> serviceTypes;

  const HandleOrderItemState({
    this.itemId,
    this.recipientName = '',
    this.selectedCategoryId,
    this.categoryName,
    this.selectedServiceTypeId,
    this.serviceName,
    this.customServiceName,
    this.isCustomServiceMode = false,
    this.cost,
    this.notes,
    this.categories = const [],
    this.serviceTypes = const [],
  });

  bool get isEditMode => itemId != null;

  JobItem toJobItem({required String fallbackRecipient}) {
    return JobItem(
      id: itemId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: selectedCategoryId,
      categoryName: selectedCategoryId != null ? categoryName : null,
      serviceTypeId: selectedServiceTypeId,
      serviceNameExplicit: selectedServiceTypeId != null ? serviceName : null,
      customServiceName:
          isCustomServiceMode && (customServiceName?.isNotEmpty ?? false)
          ? customServiceName
          : null,
      recipientName: recipientName.trim().isNotEmpty
          ? recipientName.trim()
          : fallbackRecipient,
      measurements: const BodyMeasurement(),
      estimatedCost: cost ?? 0.0,
      notes: notes?.trim().isEmpty ?? true ? null : notes?.trim(),
      referencePhotoPaths: const [],
    );
  }

  HandleOrderItemState copyWith({
    String? itemId,
    String? recipientName,
    int? Function()? selectedCategoryId,
    String? Function()? categoryName,
    int? Function()? selectedServiceTypeId,
    String? Function()? serviceName,
    String? Function()? customServiceName,
    bool? isCustomServiceMode,
    double? Function()? cost,
    String? Function()? notes,
    List<ClothesCategoryModel>? categories,
    List<ServiceTypeModel>? serviceTypes,
  }) {
    return HandleOrderItemState(
      itemId: itemId ?? this.itemId,
      recipientName: recipientName ?? this.recipientName,
      selectedCategoryId: selectedCategoryId != null
          ? selectedCategoryId()
          : this.selectedCategoryId,
      categoryName: categoryName != null ? categoryName() : this.categoryName,
      selectedServiceTypeId: selectedServiceTypeId != null
          ? selectedServiceTypeId()
          : this.selectedServiceTypeId,
      serviceName: serviceName != null ? serviceName() : this.serviceName,
      customServiceName: customServiceName != null
          ? customServiceName()
          : this.customServiceName,
      isCustomServiceMode: isCustomServiceMode ?? this.isCustomServiceMode,
      cost: cost != null ? cost() : this.cost,
      notes: notes != null ? notes() : this.notes,
      categories: categories ?? this.categories,
      serviceTypes: serviceTypes ?? this.serviceTypes,
    );
  }
}
