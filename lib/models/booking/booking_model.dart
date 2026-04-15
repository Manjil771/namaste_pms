class BookingModel {
  final int id;
  final int businessId;
  final String? businessName;
  final int roomId;
  final String roomNumber;
  final int guestId;
  final String guestName;
  final String? guestPhone;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final double amount;
  final int statusId;
  final String? statusName;
  final double? advancePayment;
  final DateTime? advanceDate;
  final int? advancePaymentMethod;
  final String? paymentMethodName;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  BookingModel({
    required this.id,
    required this.businessId,
    this.businessName,
    required this.roomId,
    required this.roomNumber,
    required this.guestId,
    required this.guestName,
    this.guestPhone,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.amount,
    required this.statusId,
    this.statusName,
    this.advancePayment,
    this.advanceDate,
    this.advancePaymentMethod,
    this.paymentMethodName,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      businessId: json['business_id'],
      businessName: json['business_name'],
      roomId: json['room_id'],
      roomNumber: json['room_number'],
      guestId: json['guest_id'],
      guestName: json['guest_name'],
      guestPhone: json['guest_phone'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      nights: json['nights'],
      amount: double.parse(json['amount'].toString()),
      statusId: json['status_id'],
      statusName: json['status_name'],
      advancePayment: json['advance_payment'] != null 
          ? double.parse(json['advance_payment'].toString()) 
          : null,
      advanceDate: json['advance_date'] != null 
          ? DateTime.parse(json['advance_date']) 
          : null,
      advancePaymentMethod: json['advance_payment_method'],
      paymentMethodName: json['payment_method_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}