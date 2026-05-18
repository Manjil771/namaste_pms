import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';
import '../models/guest/guest_model.dart';

final guestProvider = StateNotifierProvider<GuestNotifier, GuestState>((ref) {
  return GuestNotifier();
});

class GuestState {
  final List<GuestModel> guests;
  final bool isLoading;
  final String? error;
  
  GuestState({
    this.guests = const [],
    this.isLoading = false,
    this.error,
  });
  
  GuestState copyWith({
    List<GuestModel>? guests,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return GuestState(
      guests: guests ?? this.guests,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class GuestNotifier extends StateNotifier<GuestState> {
  GuestNotifier() : super(GuestState());
  
  final _apiService = ApiService();
  
  Future<void> fetchGuests() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.getGuests();
      final list = response as List? ?? [];
      final guests = list.map((json) => GuestModel.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(guests: guests, isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createGuest(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.createGuest(data);
      final newGuest = GuestModel.fromJson(response['guest'] as Map<String, dynamic>);
      state = state.copyWith(
        guests: [newGuest, ...state.guests],
        isLoading: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateGuest(int guestId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.updateGuest(guestId, data);
      final updatedGuest = GuestModel.fromJson(response['guest'] as Map<String, dynamic>);
      final updatedGuests = state.guests.map((g) => g.id == guestId ? updatedGuest : g).toList();
      state = state.copyWith(guests: updatedGuests, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteGuest(int guestId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _apiService.deleteGuest(guestId);
      final updatedGuests = state.guests.where((g) => g.id != guestId).toList();
      state = state.copyWith(guests: updatedGuests, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}