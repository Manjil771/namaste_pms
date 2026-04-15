import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../services/api_service.dart';
import '../../models/booking/booking_model.dart';

// Room Status Provider
final roomStatusProvider = StateNotifierProvider<RoomStatusNotifier, RoomStatusState>((ref) {
  return RoomStatusNotifier();
});

class RoomStatusState {
  final Map<String, dynamic> roomStatus;
  final bool isLoading;
  final String? error;
  
  RoomStatusState({
    this.roomStatus = const {},
    this.isLoading = false,
    this.error,
  });
  
  RoomStatusState copyWith({
    Map<String, dynamic>? roomStatus,
    bool? isLoading,
    String? error,
  }) {
    return RoomStatusState(
      roomStatus: roomStatus ?? this.roomStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RoomStatusNotifier extends StateNotifier<RoomStatusState> {
  RoomStatusNotifier() : super(RoomStatusState());
  
  final _apiService = ApiService();
  
  Future<void> fetchRoomStatus(int businessId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getRoomStatus(businessId);
      state = state.copyWith(roomStatus: response['room_status'], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Menu Status Provider
final menuStatusProvider = StateNotifierProvider<MenuStatusNotifier, MenuStatusState>((ref) {
  return MenuStatusNotifier();
});

class MenuStatusState {
  final Map<String, dynamic> menuStatus;
  final bool isLoading;
  final String? error;
  
  MenuStatusState({
    this.menuStatus = const {},
    this.isLoading = false,
    this.error,
  });
  
  MenuStatusState copyWith({
    Map<String, dynamic>? menuStatus,
    bool? isLoading,
    String? error,
  }) {
    return MenuStatusState(
      menuStatus: menuStatus ?? this.menuStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MenuStatusNotifier extends StateNotifier<MenuStatusState> {
  MenuStatusNotifier() : super(MenuStatusState());
  
  final _apiService = ApiService();
  
  Future<void> fetchMenuStatus(int businessId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getMenuStatus(businessId);
      state = state.copyWith(menuStatus: response['menu_status'], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Staff Status Provider
final staffStatusProvider = StateNotifierProvider<StaffStatusNotifier, StaffStatusState>((ref) {
  return StaffStatusNotifier();
});

class StaffStatusState {
  final Map<String, dynamic> staffStatus;
  final bool isLoading;
  final String? error;
  
  StaffStatusState({
    this.staffStatus = const {},
    this.isLoading = false,
    this.error,
  });
  
  StaffStatusState copyWith({
    Map<String, dynamic>? staffStatus,
    bool? isLoading,
    String? error,
  }) {
    return StaffStatusState(
      staffStatus: staffStatus ?? this.staffStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class StaffStatusNotifier extends StateNotifier<StaffStatusState> {
  StaffStatusNotifier() : super(StaffStatusState());
  
  final _apiService = ApiService();
  
  Future<void> fetchStaffStatus(int businessId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getStaffStatus(businessId, getAll: true);
      state = state.copyWith(staffStatus: response['staff_status'], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Recent Bookings Provider
final recentBookingsProvider = StateNotifierProvider<RecentBookingsNotifier, RecentBookingsState>((ref) {
  return RecentBookingsNotifier();
});

class RecentBookingsState {
  final List<BookingModel> bookings;
  final bool isLoading;
  final String? error;
  
  RecentBookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });
  
  RecentBookingsState copyWith({
    List<BookingModel>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return RecentBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RecentBookingsNotifier extends StateNotifier<RecentBookingsState> {
  RecentBookingsNotifier() : super(RecentBookingsState());
  
  final _apiService = ApiService();
  
  Future<void> fetchRecentBookings(int businessId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getBookings(businessId);
      final bookings = (response as List).map((json) => BookingModel.fromJson(json)).toList();
      // Sort by created_at descending and take first 5
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(bookings: bookings.take(5).toList(), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Revenue Provider
final revenueProvider = StateNotifierProvider<RevenueNotifier, RevenueState>((ref) {
  return RevenueNotifier();
});

class RevenueState {
  final Map<String, dynamic> revenueData;
  final bool isLoading;
  final String? error;
  
  RevenueState({
    this.revenueData = const {},
    this.isLoading = false,
    this.error,
  });
  
  RevenueState copyWith({
    Map<String, dynamic>? revenueData,
    bool? isLoading,
    String? error,
  }) {
    return RevenueState(
      revenueData: revenueData ?? this.revenueData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RevenueNotifier extends StateNotifier<RevenueState> {
  RevenueNotifier() : super(RevenueState());
  
  final _apiService = ApiService();
  
  Future<void> fetchRevenue(int businessId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getRevenue(businessId);
      state = state.copyWith(revenueData: response, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}