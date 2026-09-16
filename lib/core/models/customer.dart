class Customer {
  final String id;
  final String name;
  final String phone;
  final String? address;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        address: json['address'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
      };
}
