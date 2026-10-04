import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/models/clothes_category.dart';
import 'package:jahitin_mobile/core/models/service_type.dart';
import 'package:jahitin_mobile/features/create_order/model/create_order_item.dart';
import 'handle_order_item_state.dart';

final handleOrderItemProvider =
    NotifierProvider.autoDispose<HandleOrderItemNotifier, HandleOrderItemState>(
      HandleOrderItemNotifier.new,
    );

class HandleOrderItemNotifier
    extends AutoDisposeNotifier<HandleOrderItemState> {
  @override
  HandleOrderItemState build() {
    return const HandleOrderItemState();
  }

  /// Inisialisasi saat sheet dibuka untuk create baru atau edit item
  void initialize({
    CreateOrderItem? existingItem,
    required String defaultRecipient,
    List<ClothesCategoryModel> categories = const [],
    List<ServiceTypeModel> serviceTypes = const [],
  }) {
    if (existingItem != null) {
      final isCustomService =
          (existingItem.customServiceName != null &&
              existingItem.customServiceName!.isNotEmpty) ||
          (existingItem.serviceTypeId == null &&
              existingItem.customServiceName != null &&
              existingItem.customServiceName!.isNotEmpty);

      state = HandleOrderItemState(
        itemId: existingItem.id,
        recipientName: existingItem.clothesFor,
        selectedCategoryId: existingItem.clothesCategoryId,
        categoryName: existingItem.clothesCategoryName,
        selectedServiceTypeId: existingItem.serviceTypeId,
        serviceName: existingItem.serviceTypeName,
        customServiceName: existingItem.customServiceName,
        isCustomServiceMode: isCustomService,
        cost: existingItem.price > 0
            ? existingItem.price
            : null,
        notes: existingItem.notes,
        saveCustomerNotes: existingItem.saveCustomerNotes,
        categories: categories,
        serviceTypes: serviceTypes,
      );
    } else {
      state = HandleOrderItemState(
        recipientName: defaultRecipient,
        categories: categories,
        serviceTypes: serviceTypes,
      );
    }
  }

  void setRecipientName(String name) {
    state = state.copyWith(recipientName: name);
  }

  void selectCategory(int? id, String? name) {
    if (state.selectedCategoryId == id) {
      // Toggle unselect
      state = state.copyWith(
        selectedCategoryId: () => null,
        categoryName: () => null,
      );
    } else {
      state = state.copyWith(
        selectedCategoryId: () => id,
        categoryName: () => name,
      );
    }
  }

  void selectServiceType(int? id, String? name) {
    if (state.selectedServiceTypeId == id && !state.isCustomServiceMode) {
      state = state.copyWith(
        selectedServiceTypeId: () => null,
        serviceName: () => null,
      );
    } else {
      state = state.copyWith(
        selectedServiceTypeId: () => id,
        serviceName: () => name,
        customServiceName: () => null,
        isCustomServiceMode: false,
      );
    }
  }

  void toggleCustomServiceMode() {
    final nextMode = !state.isCustomServiceMode;
    state = state.copyWith(
      isCustomServiceMode: nextMode,
      selectedServiceTypeId: () => null,
      serviceName: () => null,
      customServiceName: () => nextMode ? state.customServiceName : null,
    );
  }

  void setCustomServiceName(String? name) {
    state = state.copyWith(customServiceName: () => name);
  }

  void setCost(double? cost) {
    state = state.copyWith(cost: () => cost);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: () => notes);
  }

  void setSaveCustomerNotes(bool value) {
    state = state.copyWith(saveCustomerNotes: value);
  }
}
