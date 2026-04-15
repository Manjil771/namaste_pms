class UserModel {
  final int? id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? role;
  final int? businessId;
  final String? businessName;
  
  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.role,
    this.businessId,
    this.businessName,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      role: json['role'],
      businessId: json['business_id'],
      businessName: json['business_name'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'business_id': businessId,
      'business_name': businessName,
    };
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });
  
  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access'] ?? json['tokens']['access'],
      refreshToken: json['refresh'] ?? json['tokens']['refresh'],
    );
  }
}