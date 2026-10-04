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
  final int? categoryId;
  final int? serviceId;
  final String? customServiceName;
  final int price;
  final bool saveCustomerNotes;

  CreateOrderItemRequest({
    required this.clothesFor,
    required this.notes,
    this.categoryId,
    this.serviceId,
    this.customServiceName,
    required this.price,
    required this.saveCustomerNotes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'clothes_for': clothesFor,
      'notes': notes,
      'price': price,
      'is_save_customer_notes': saveCustomerNotes,
    };

    if (categoryId != null) {
      map['clothes_category_id'] = categoryId;
    }

    if (serviceId != null) {
      map['service_type_id'] = serviceId;
    } else if (customServiceName != null && customServiceName!.isNotEmpty) {
      map['custom_service_name'] = customServiceName;
    }

    return map;
  }
}
