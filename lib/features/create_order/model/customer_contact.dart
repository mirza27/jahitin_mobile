class CustomerContact {
  final String displayName;
  final String phoneNumber;
  final String contactId;

  CustomerContact({
    required this.displayName,
    required this.phoneNumber,
    required this.contactId,
  });

  factory CustomerContact.fromJson(Map<String, dynamic> json) {
    return CustomerContact(
      displayName: json['displayName'] ?? json['customer_name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['customer_phone'] ?? '',
      contactId: json['contactId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'contactId': contactId,
      };

  Map<String, dynamic> toPayloadJson() => {
        'customer_name': displayName,
        'customer_phone': phoneNumber,
      };

  CustomerContact copyWith({
    String? displayName,
    String? phoneNumber,
    String? contactId,
  }) {
    return CustomerContact(
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactId: contactId ?? this.contactId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerContact &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          phoneNumber == other.phoneNumber &&
          contactId == other.contactId;

  @override
  int get hashCode =>
      displayName.hashCode ^ phoneNumber.hashCode ^ contactId.hashCode;
}
