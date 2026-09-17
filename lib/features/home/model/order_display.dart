enum OrderStatus { pending, inProgress, completed, pickedUp }

class OrderDisplay {
  final String orderId;
  final String? name;
  final String customerName;
  final DateTime? deadline;
  final OrderStatus orderStatus;
  final int itemCount;
  final List<OrderItemDisplay>? orderDisplayItems;

  OrderDisplay({
    required this.orderId,
    required this.customerName,
    required this.name,
    required this.orderStatus,
    this.deadline,
    this.itemCount = 0,
    this.orderDisplayItems,
  });

  factory OrderDisplay.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['Items'] ?? json['items'];
    List<OrderItemDisplay>? items;
    if (itemsJson is List) {
      items = itemsJson
          .whereType<Map>()
          .map((i) => OrderItemDisplay.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }

    final rawStatus = (json['Status'] ?? json['status'] ?? '').toString();
    final parsedStatus = _parseOrderStatus(rawStatus);

    DateTime? deadlineDate;
    final rawDeadline = json['Deadline'] ?? json['deadline'];
    if (rawDeadline != null && rawDeadline.toString().isNotEmpty) {
      deadlineDate = DateTime.tryParse(rawDeadline.toString());
    }

    return OrderDisplay(
      orderId: (json['OrderID'] ?? json['order_id'] ?? json['id'] ?? '')
          .toString(),
      customerName: (json['CustomerName'] ?? json['customer_name'] ?? '-')
          .toString(),
      name: json['Name'] as String? ?? json['name'] as String?,
      orderStatus: parsedStatus,
      deadline: deadlineDate,
      itemCount:
          items?.length ??
          (json['ItemCount'] ?? json['item_count'] ?? 0) as int,
      orderDisplayItems: items,
    );
  }

  static OrderStatus _parseOrderStatus(String status) {
    final normalized = status.trim().toLowerCase().replaceAll('_', '');
    switch (normalized) {
      case 'inprogress':
        return OrderStatus.inProgress;
      case 'completed':
      case 'selesai':
        return OrderStatus.completed;
      case 'pickedup':
      case 'diambil':
        return OrderStatus.pickedUp;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderItemDisplay {
  final String? clothesFor;
  final String? customServiceName;

  OrderItemDisplay({this.clothesFor, this.customServiceName});

  factory OrderItemDisplay.fromJson(Map<String, dynamic> json) {
    return OrderItemDisplay(
      clothesFor:
          json['ClothesFor'] as String? ?? json['clothes_for'] as String?,
      customServiceName:
          json['CustomServiceName'] as String? ??
          json['custom_service_name'] as String?,
    );
  }
}
