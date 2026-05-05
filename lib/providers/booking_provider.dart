import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';
import '../models/booking/booking_model.dart';

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});

class BookingState {
  final List<BookingModel> bookings;
  final bool isLoading;
  final String? error;
  
  BookingState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });
  
  BookingState copyWith({
    List<BookingModel>? bookings,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState());
  
  final _apiService = ApiService();
  int? _currentBusinessId;
  
  Future<void> fetchBookings(int businessId) async {
    _currentBusinessId = businessId;
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final response = await _apiService.getBookings(businessId);
      final bookings = (response as List).map((json) => BookingModel.fromJson(json)).toList();
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<bool> createBooking(int businessId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final response = await _apiService.createBooking(businessId, data);
      final newBooking = BookingModel.fromJson(response['booking']);
      state = state.copyWith(
        bookings: [newBooking, ...state.bookings],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> updateBooking(int businessId, int bookingId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final response = await _apiService.updateBooking(businessId, bookingId, data);
      final updatedBooking = BookingModel.fromJson(response['booking']);
      
      final updatedBookings = state.bookings.map((booking) {
        return booking.id == bookingId ? updatedBooking : booking;
      }).toList();
      
      state = state.copyWith(bookings: updatedBookings, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> deleteBooking(int businessId, int bookingId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await _apiService.deleteBooking(businessId, bookingId);
      final updatedBookings = state.bookings.where((booking) => booking.id != bookingId).toList();
      state = state.copyWith(bookings: updatedBookings, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> updateBookingStatus(int businessId, int bookingId, int statusId) async {
    return updateBooking(businessId, bookingId, {'status_id': statusId});
  }
}