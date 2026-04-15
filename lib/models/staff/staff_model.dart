class StaffModel {
  final int id;
  final int businessId;
  final String businessName;
  final int role;
  final String roleName;
  final int shift;
  final String shiftName;
  final int status;
  final String statusName;
  final String name;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  StaffModel({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.role,
    required this.roleName,
    required this.shift,
    required this.shiftName,
    required this.status,
    required this.statusName,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      businessId: json['business_id'],
      businessName: json['business_name'] ?? '',
      role: json['role'],
      roleName: json['role_name'] ?? '',
      shift: json['shift'],
      shiftName: json['shift_name'] ?? '',
      status: json['status'],
      statusName: json['status_name'] ?? '',
      name: json['name'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}