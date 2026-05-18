class TableModel {
  final int id;
  final int businessId;
  final String tableNumber;
  final int? location;
  final int statusId;
  final int? reservedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TableModel({
    required this.id,
    required this.businessId,
    required this.tableNumber,
    this.location,
    required this.statusId,
    this.reservedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      businessId: json['business_id'],
      tableNumber: json['table_number'],
      location: json['location'],
      statusId: json['status_id'],
      reservedBy: json['reserved_by'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  // status_id: 1 = Available, 2 = Occupied/Cleaning, 3 = Maintenance
  bool get isAvailable => statusId == 1;

  String get statusName {
    switch (statusId) {
      case 1:
        return 'Available';
      case 2:
        return 'Occupied';
      case 3:
        return 'Maintenance';
      default:
        return 'Unknown';
    }
  }
}