class ServiceTypeModel {
  final int id;
  final String name;
  final DateTime? createdAt;

  ServiceTypeModel({required this.id, required this.name, this.createdAt});

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'created_at': createdAt?.toIso8601String()};
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
