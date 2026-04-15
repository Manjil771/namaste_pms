class BusinessModel {
  final int id;
  final String name;
  final String? uid;
  final String phoneNumber;
  final String panNumber;
  final String address;
  final String email;
  final int businessTypeId;
  final String? businessTypeName;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  BusinessModel({
    required this.id,
    required this.name,
    this.uid,
    required this.phoneNumber,
    required this.panNumber,
    required this.address,
    required this.email,
    required this.businessTypeId,
    this.businessTypeName,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      name: json['name'] ?? json['business_name'] ?? '',
      uid: json['uid'],
      phoneNumber: json['phone_number'] ?? '',
      panNumber: json['pan_number'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      businessTypeId: json['business_type_id'] ?? 1,
      businessTypeName: json['business_type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}