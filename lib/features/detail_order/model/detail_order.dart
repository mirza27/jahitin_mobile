class DetailOrderItem {
  final String? clothesFor;
  final int? clothesCategoryId;
  final String? clothesCategoryName;
  final int? serviceTypeId;
  final String? serviceTypeName;
  final String? customServiceName;
  final double price;
  final String? notes;
  final String? status;

  DetailOrderItem({
    this.clothesFor,
    this.clothesCategoryId,
    this.clothesCategoryName,
    this.serviceTypeId,
    this.serviceTypeName,
    this.customServiceName,
    required this.price,
    this.notes,
    this.status,
  });

  factory DetailOrderItem.fromJson(Map<String, dynamic> json) {
    return DetailOrderItem(
      clothesFor: json['ClothesFor'] as String? ?? json['clothes_for'] as String?,
      clothesCategoryId: json['ClothesCategoryID'] is int
          ? json['ClothesCategoryID'] as int
          : int.tryParse(json['ClothesCategoryID']?.toString() ?? ''),
      clothesCategoryName: json['ClothesCategoryName'] as String? ?? json['clothes_category_name'] as String?,
      serviceTypeId: json['ServiceTypeID'] is int
          ? json['ServiceTypeID'] as int
          : int.tryParse(json['ServiceTypeID']?.toString() ?? ''),
      serviceTypeName: json['ServiceTypeName'] as String? ?? json['service_type_name'] as String?,
      customServiceName: json['CustomServiceName'] as String? ?? json['custom_service_name'] as String?,
      price: double.tryParse(json['Price']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      notes: json['Notes'] as String? ?? json['notes'] as String?,
      status: json['Status'] as String? ?? json['status'] as String?,
    );
  }
}

class DetailOrder {
  final String orderId;
  final String? name;
  final DateTime? deadline;
  final String customerName;
  final String? customerPhone;
  final int? customerId;
  final String status;
  final double totalPrice;
  final List<DetailOrderItem> items;

  DetailOrder({
    required this.orderId,
    this.name,
    this.deadline,
    required this.customerName,
    this.customerPhone,
    this.customerId,
    required this.status,
    required this.totalPrice,
    required this.items,
  });

  factory DetailOrder.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['Items'] ?? json['items'];
    List<DetailOrderItem> parsedItems = [];
    if (itemsRaw is List) {
      parsedItems = itemsRaw
          .whereType<Map>()
          .map((e) => DetailOrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return DetailOrder(
      orderId: (json['OrderID'] ?? json['order_id'] ?? json['id'] ?? '').toString(),
      name: json['Name'] as String? ?? json['name'] as String?,
      deadline: json['Deadline'] != null && json['Deadline'].toString().isNotEmpty
          ? DateTime.tryParse(json['Deadline'].toString())
          : (json['deadline'] != null && json['deadline'].toString().isNotEmpty
              ? DateTime.tryParse(json['deadline'].toString())
              : null),
      customerName: (json['CustomerName'] ?? json['customer_name'] ?? '-').toString(),
      customerPhone: json['CustomerPhone'] as String? ??
          json['customer_phone'] as String? ??
          json['Phone'] as String? ??
          json['phone'] as String?,
      customerId: json['CustomerId'] is int
          ? json['CustomerId'] as int
          : int.tryParse(json['CustomerId']?.toString() ?? ''),
      status: (json['Status'] ?? json['status'] ?? 'pending').toString(),
      totalPrice: double.tryParse(json['TotalPrice']?.toString() ?? json['total_price']?.toString() ?? '0') ?? 0.0,
      items: parsedItems,
    );
  }
}
