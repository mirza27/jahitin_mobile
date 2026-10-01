import 'package:jahitin_mobile/features/create_order/model/customer_contact.dart';

class CreateOrderRequest {
  final String name;
  final String deadline;
  final CustomerContact customerContact;
  final List<CreateOrderItemRequest> orderItems;

  CreateOrderRequest({
    required this.name,
    required this.deadline,
    required this.customerContact,
    required this.orderItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'deadline': deadline,
      'customer': customerContact.toPayloadJson(),
      'order_items': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}

class CreateOrderItemRequest {
  final String clothesFor;
  final String notes;
  final int categoryId;
  final int? serviceId;
  final String? customServiceName;
  final num? price;
  final bool saveCustomerNotes;

  CreateOrderItemRequest({
    required this.clothesFor,
    required this.notes,
    required this.categoryId,
    this.serviceId,
    this.customServiceName,
    this.price,
    required this.saveCustomerNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'clothes_for': clothesFor,
      'notes': notes,
      'clothes_category_id': categoryId,
      'service_type_id': serviceId,
      'custom_service_name': customServiceName ?? '',
      'price': price != null ? price!.toInt() : 0,
      'is_save_customer_notes': saveCustomerNotes,
    };
  }
}
