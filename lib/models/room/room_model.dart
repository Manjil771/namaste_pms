class RoomModel {
  final int id;
  final int businessId;
  final String roomNumber;
  final int typeId;
  final String? roomTypeName;
  final int capacity;
  final double price;
  final int floor;
  final int statusId;
  final String? statusName;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  RoomModel({
    required this.id,
    required this.businessId,
    required this.roomNumber,
    required this.typeId,
    this.roomTypeName,
    required this.capacity,
    required this.price,
    required this.floor,
    required this.statusId,
    this.statusName,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      businessId: json['business_id'],
      roomNumber: json['room_number'],
      typeId: json['type_id'],
      roomTypeName: json['room_type_name'],
      capacity: json['capacity'] ?? 1,
      price: double.parse(json['price'].toString()),
      floor: json['floor'] ?? 1,
      statusId: json['status_id'],
      statusName: json['status_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'room_number': roomNumber,
      'type_id': typeId,
      'capacity': capacity,
      'price': price.toString(),
      'floor': floor,
      'status_id': statusId,
    };
  }
}