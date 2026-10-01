enum ServiceType { jahitBaru, permak }

enum GarmentCategory {
  gamis,
  kemeja,
  celana,
  rok,
  jas,
  kebaya,
  kaos,
  lainnya,
}

class BodyMeasurement {
  final double? lingkarDada;
  final double? panjangLengan;
  final double? panjangBaju;
  final double? lingkarPinggang;
  final double? lingkarPinggul;
  final double? lebarBahu;
  final Map<String, double> customMeasurements;

  const BodyMeasurement({
    this.lingkarDada,
    this.panjangLengan,
    this.panjangBaju,
    this.lingkarPinggang,
    this.lingkarPinggul,
    this.lebarBahu,
    this.customMeasurements = const {},
  });

  bool get isEmpty =>
      lingkarDada == null &&
      panjangLengan == null &&
      panjangBaju == null &&
      lingkarPinggang == null &&
      lingkarPinggul == null &&
      lebarBahu == null &&
      customMeasurements.isEmpty;

  int get filledCount {
    int count = 0;
    if (lingkarDada != null) count++;
    if (panjangLengan != null) count++;
    if (panjangBaju != null) count++;
    if (lingkarPinggang != null) count++;
    if (lingkarPinggul != null) count++;
    if (lebarBahu != null) count++;
    count += customMeasurements.length;
    return count;
  }
}

class JobItem {
  final String id;
  // Legacy enum fields (dipertahankan untuk kompatibilitas dengan kode lama)
  final ServiceType? serviceType;
  final GarmentCategory? category;
  final String recipientName;
  final String? customCategoryName;
  final BodyMeasurement measurements;
  final double estimatedCost;
  final String? notes;
  final List<String> referencePhotoPaths;
  // Dynamic API-based fields
  final int? categoryId;
  final String? categoryName;
  final int? serviceTypeId;
  final String? serviceNameExplicit;
  final String? customServiceName;

  const JobItem({
    required this.id,
    this.serviceType,
    this.category,
    required this.recipientName,
    this.customCategoryName,
    required this.measurements,
    required this.estimatedCost,
    this.notes,
    this.referencePhotoPaths = const [],
    this.categoryId,
    this.categoryName,
    this.serviceTypeId,
    this.serviceNameExplicit,
    this.customServiceName,
  });

  /// Nama tampilan kategori pakaian.
  /// Prioritas: nama kategori dari API → customCategoryName → 'Pakaian'
  String get displayName {
    if (categoryName != null && categoryName!.isNotEmpty) return categoryName!;
    if (category == null) {
      return (customCategoryName != null && customCategoryName!.isNotEmpty)
          ? customCategoryName!
          : 'Pakaian';
    }
    switch (category!) {
      case GarmentCategory.gamis:
        return 'Gamis';
      case GarmentCategory.kemeja:
        return 'Kemeja';
      case GarmentCategory.celana:
        return 'Celana';
      case GarmentCategory.rok:
        return 'Rok';
      case GarmentCategory.jas:
        return 'Jas';
      case GarmentCategory.kebaya:
        return 'Kebaya';
      case GarmentCategory.kaos:
        return 'Kaos';
      case GarmentCategory.lainnya:
        return (customCategoryName != null && customCategoryName!.isNotEmpty)
            ? customCategoryName!
            : 'Lainnya';
    }
  }

  /// Nama tampilan jenis layanan.
  /// Prioritas: customServiceName → nama dari API → enum lokal → ''
  String get serviceName {
    if (customServiceName != null && customServiceName!.isNotEmpty) {
      return customServiceName!;
    }
    if (serviceNameExplicit != null && serviceNameExplicit!.isNotEmpty) {
      return serviceNameExplicit!;
    }
    if (serviceType == null) return '';
    return serviceType == ServiceType.jahitBaru ? 'Jahit Baru' : 'Permak';
  }

  int get resolvedCategoryId {
    if (categoryId != null) return categoryId!;
    if (category != null) return category!.index + 1;
    return 1;
  }

  int? get resolvedServiceTypeId {
    if (serviceTypeId != null) return serviceTypeId!;
    if (serviceType != null) return serviceType!.index + 1;
    return null;
  }
}
