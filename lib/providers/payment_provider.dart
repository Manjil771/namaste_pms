import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier();
});

class PaymentState {
  final List<PaymentModel> payments;
  final bool isLoading;
  final String? error;
  
  PaymentState({
    this.payments = const [],
    this.isLoading = false,
    this.error,
  });
  
  PaymentState copyWith({
    List<PaymentModel>? payments,
    bool? isLoading,
    String? error,
  }) {
    return PaymentState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PaymentModel {
  final int id;
  final int? bookingId;
  final String paymentMethod;
  final double amount;
  final DateTime paidAt;
  final int statusId;
  final String statusName;
  final bool isAdvance;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  PaymentModel({
    required this.id,
    this.bookingId,
    required this.paymentMethod,
    required this.amount,
    required this.paidAt,
    required this.statusId,
    required this.statusName,
    required this.isAdvance,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      paymentMethod: json['payment_method'] ?? json['method_name'] ?? 'Cash',
      amount: double.parse(json['amount'].toString()),
      paidAt: DateTime.parse(json['paid_at'] ?? json['payment_date']),
      statusId: json['status_id'] ?? 1,
      statusName: json['status_name'] ?? 'Pending',
      isAdvance: json['is_advance'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(PaymentState());
  
  final _apiService = ApiService();
  
  Future<void> fetchPayments() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getPayments();
      final payments = (response as List).map((json) => PaymentModel.fromJson(json)).toList();
      state = state.copyWith(payments: payments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<bool> createPayment(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.createPayment(data);
      final newPayment = PaymentModel.fromJson(response['payment']);
      state = state.copyWith(
        payments: [newPayment, ...state.payments],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> updatePayment(int paymentId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.updatePayment(paymentId, data);
      final updatedPayment = PaymentModel.fromJson(response['payment']);
      final updatedPayments = state.payments.map((p) => p.id == paymentId ? updatedPayment : p).toList();
      state = state.copyWith(payments: updatedPayments, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> deletePayment(int paymentId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiService.deletePayment(paymentId);
      final updatedPayments = state.payments.where((p) => p.id != paymentId).toList();
      state = state.copyWith(payments: updatedPayments, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}