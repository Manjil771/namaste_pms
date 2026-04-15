class GuestModel {
  final int id;
  final int businessId;
  final String name;
  final String phone;
  final int verifyId;
  final int statusId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  GuestModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.phone,
    required this.verifyId,
    required this.statusId,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      phone: json['phone'],
      verifyId: json['verify_id'],
      statusId: json['status_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'name': name,
      'phone': phone,
      'verify_id': verifyId,
      'status_id': statusId,
    };
  }
}