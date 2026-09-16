class User {
  final String userId;
  final String name;
  final String? username;
  final String? email;
  final String? phone;
  final String? userType;

  User({
    required this.userId,
    required this.name,
    this.username,
    this.email,
    this.phone,
    this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['userType'] ?? '',
    );
  }
}
