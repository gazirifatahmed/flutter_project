class User {
  final int? id; // Nullable for registration
  final String username;
  final String password;
  final String? email;
  final String? phone;
  final String? address;
  final String role;

  User({
    this.id,
    required this.username,
    required this.password,
    this.email,
    this.phone,
    this.address,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password': password,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
    };
  }
}
