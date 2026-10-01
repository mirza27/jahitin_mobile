import 'detail_order.dart';

class ClothesCategoryModel {
  final int id;
  final String name;
  final DateTime? createdAt;

  ClothesCategoryModel({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory ClothesCategoryModel.fromJson(Map<String, dynamic> json) {
    return ClothesCategoryModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothesCategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class ServiceTypeModel {
  final int id;
  final String name;
  final DateTime? createdAt;

  ServiceTypeModel({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceTypeModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class UpdateOrderItem {
  final String localId; // Digunakan sebagai key identifikasi lokal pada list
  final String? clothesFor;
  final String? notes;
  final String? serviceId;
  final String? serviceName;
  final String? customServiceName;
  final String? categoryId;
  final String? categoryName;
  final double price;
  final String? status;
  final bool saveCustomerNotes;

  UpdateOrderItem({
    required this.localId,
    this.clothesFor,
    this.notes,
    this.serviceId,
    this.serviceName,
    this.customServiceName,
    this.categoryId,
    this.categoryName,
    required this.price,
    this.status,
    this.saveCustomerNotes = false,
  });

  UpdateOrderItem copyWith({
    String? localId,
    String? clothesFor,
    String? notes,
    String? serviceId,
    String? serviceName,
    String? customServiceName,
    String? categoryId,
    String? categoryName,
    double? price,
    String? status,
    bool? saveCustomerNotes,
  }) {
    return UpdateOrderItem(
      localId: localId ?? this.localId,
      clothesFor: clothesFor ?? this.clothesFor,
      notes: notes ?? this.notes,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      customServiceName: customServiceName ?? this.customServiceName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      status: status ?? this.status,
      saveCustomerNotes: saveCustomerNotes ?? this.saveCustomerNotes,
    );
  }

  factory UpdateOrderItem.fromDetailOrderItem(DetailOrderItem item, String localId) {
    return UpdateOrderItem(
      localId: localId,
      clothesFor: item.clothesFor,
      notes: item.notes,
      serviceId: item.serviceTypeId?.toString(),
      serviceName: item.serviceTypeName,
      customServiceName: item.customServiceName,
      categoryId: item.clothesCategoryId?.toString(),
      categoryName: item.clothesCategoryName,
      price: item.price,
      status: item.status ?? 'pending',
      saveCustomerNotes: false,
    );
  }

  Map<String, dynamic> toPayloadJson() {
    return {
      "clothes_for": clothesFor ?? "",
      "notes": notes ?? "",
      "service_id": serviceId ?? "",
      "custom_service_name": customServiceName ?? "",
      "category_id": categoryId ?? "",
      "price": price.toInt(),
      "save_customer_notes": saveCustomerNotes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateOrderItem &&
          runtimeType == other.runtimeType &&
          clothesFor == other.clothesFor &&
          notes == other.notes &&
          serviceId == other.serviceId &&
          serviceName == other.serviceName &&
          customServiceName == other.customServiceName &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          price == other.price &&
          status == other.status &&
          saveCustomerNotes == other.saveCustomerNotes;

  @override
  int get hashCode =>
      clothesFor.hashCode ^
      notes.hashCode ^
      serviceId.hashCode ^
      serviceName.hashCode ^
      customServiceName.hashCode ^
      categoryId.hashCode ^
      categoryName.hashCode ^
      price.hashCode ^
      status.hashCode ^
      saveCustomerNotes.hashCode;
}

class UpdateDetailOrder {
  final String orderId;
  final String? name;
  final int? customerId;
  final String customerName;
  final DateTime? deadline;
  final List<UpdateOrderItem> orderItems;

  UpdateDetailOrder({
    required this.orderId,
    this.name,
    this.customerId,
    required this.customerName,
    this.deadline,
    required this.orderItems,
  });

  UpdateDetailOrder copyWith({
    String? orderId,
    String? name,
    int? customerId,
    String? customerName,
    DateTime? deadline,
    List<UpdateOrderItem>? orderItems,
  }) {
    return UpdateDetailOrder(
      orderId: orderId ?? this.orderId,
      name: name ?? this.name,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      deadline: deadline ?? this.deadline,
      orderItems: orderItems ?? this.orderItems,
    );
  }

  factory UpdateDetailOrder.fromDetailOrder(DetailOrder detailOrder) {
    return UpdateDetailOrder(
      orderId: detailOrder.orderId,
      name: detailOrder.name,
      customerId: detailOrder.customerId,
      customerName: detailOrder.customerName,
      deadline: detailOrder.deadline,
      orderItems: detailOrder.items
          .asMap()
          .entries
          .map((entry) => UpdateOrderItem.fromDetailOrderItem(
                entry.value,
                'item_${entry.key}_${DateTime.now().millisecondsSinceEpoch}',
              ))
          .toList(),
    );
  }

  List<Map<String, dynamic>> toPayloadJson() {
    return orderItems.map((e) => e.toPayloadJson()).toList();
  }

  double get totalPrice =>
      orderItems.fold(0.0, (sum, item) => sum + item.price);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateDetailOrder &&
          runtimeType == other.runtimeType &&
          orderId == other.orderId &&
          name == other.name &&
          customerId == other.customerId &&
          customerName == other.customerName &&
          deadline == other.deadline &&
          _isItemsEqual(orderItems, other.orderItems);

  static bool _isItemsEqual(List<UpdateOrderItem> a, List<UpdateOrderItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      orderId.hashCode ^
      name.hashCode ^
      customerId.hashCode ^
      customerName.hashCode ^
      deadline.hashCode ^
      orderItems.hashCode;
}
