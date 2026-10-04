class CreateOrderItem {
  final String id;
  final String clothesFor;
  final int? clothesCategoryId;
  final String? clothesCategoryName;
  final int? serviceTypeId;
  final String? serviceTypeName;
  final String? customServiceName;
  final double price;
  final String? notes;
  final bool saveCustomerNotes;

  const CreateOrderItem({
    required this.id,
    required this.clothesFor,
    this.clothesCategoryId,
    this.clothesCategoryName,
    this.serviceTypeId,
    this.serviceTypeName,
    this.customServiceName,
    required this.price,
    this.notes,
    this.saveCustomerNotes = false,
  });

  /// Nama tampilan kategori pakaian.
  /// Prioritas: clothesCategoryName → 'Pakaian'
  String get displayCategoryName {
    if (clothesCategoryName != null && clothesCategoryName!.isNotEmpty) {
      return clothesCategoryName!;
    }
    return 'Pakaian';
  }

  /// Nama tampilan jenis layanan.
  /// Prioritas: customServiceName → serviceTypeName → ''
  String get displayServiceName {
    if (customServiceName != null && customServiceName!.isNotEmpty) {
      return customServiceName!;
    }
    if (serviceTypeName != null && serviceTypeName!.isNotEmpty) {
      return serviceTypeName!;
    }
    return '';
  }
}
