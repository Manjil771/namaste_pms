import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;
  
  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });
  
  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class OrderModel {
  final int id;
  final int businessId;
  final String orderNumber;
  final int tableId;
  final int guestId;
  final String guestName;
  final int orderTypeId;
  final int statusId;
  final String? statusName;
  final double subtotal;
  final double tax;
  final double discount;
  final double totalAmount;
  final String? notes;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  OrderModel({
    required this.id,
    required this.businessId,
    required this.orderNumber,
    required this.tableId,
    required this.guestId,
    required this.guestName,
    required this.orderTypeId,
    required this.statusId,
    this.statusName,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      businessId: json['business_id'],
      orderNumber: json['order_number'],
      tableId: json['table_id'],
      guestId: json['guest_id'],
      guestName: json['guest_name'],
      orderTypeId: json['order_type_id'],
      statusId: json['status_id'],
      statusName: json['status_name'],
      subtotal: double.parse(json['subtotal'].toString()),
      tax: double.parse(json['tax'].toString()),
      discount: double.parse(json['discount'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      notes: json['notes'],
      items: (json['items'] as List).map((i) => OrderItemModel.fromJson(i)).toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class OrderItemModel {
  final int id;
  final int orderId;
  final int foodItemId;
  final String foodItemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? note;
  final int statusId;
  final String? statusName;
  
  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.foodItemId,
    required this.foodItemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.note,
    required this.statusId,
    this.statusName,
  });
  
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      foodItemId: json['food_item_id'],
      foodItemName: json['food_item_name'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      note: json['note'],
      statusId: json['status_id'],
      statusName: json['status_name'],
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(OrderState());
  
  final _apiService = ApiService();
  
  Future<void> fetchOrders([int? tableId]) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getOrders(tableId);
      final orders = (response as List).map((json) => OrderModel.fromJson(json)).toList();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<bool> createOrder(int businessId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.createOrder(businessId, data);
      final newOrder = OrderModel.fromJson(response['order']);
      state = state.copyWith(
        orders: [newOrder, ...state.orders],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}