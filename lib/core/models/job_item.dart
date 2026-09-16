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
  final ServiceType serviceType;
  final GarmentCategory category;
  final String recipientName;
  final String? customCategoryName;
  final BodyMeasurement measurements;
  final double estimatedCost;
  final String? notes;
  final List<String> referencePhotoPaths;

  const JobItem({
    required this.id,
    required this.serviceType,
    required this.category,
    required this.recipientName,
    this.customCategoryName,
    required this.measurements,
    required this.estimatedCost,
    this.notes,
    this.referencePhotoPaths = const [],
  });

  String get displayName {
    switch (category) {
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

  String get serviceName =>
      serviceType == ServiceType.jahitBaru ? 'Jahit Baru' : 'Permak';
}
