import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';
import '../models/staff/staff_model.dart';

final staffProvider = StateNotifierProvider<StaffNotifier, StaffState>((ref) {
  return StaffNotifier();
});

class StaffState {
  final List<StaffModel> staff;
  final bool isLoading;
  final String? error;
  
  StaffState({
    this.staff = const [],
    this.isLoading = false,
    this.error,
  });
  
  StaffState copyWith({
    List<StaffModel>? staff,
    bool? isLoading,
    String? error,
  }) {
    return StaffState(
      staff: staff ?? this.staff,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class StaffNotifier extends StateNotifier<StaffState> {
  StaffNotifier() : super(StaffState());
  
  final _apiService = ApiService();
  
  Future<void> fetchStaff(int businessId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getStaff(businessId);
      final staff = (response as List).map((json) => StaffModel.fromJson(json)).toList();
      state = state.copyWith(staff: staff, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<bool> createStaff(int businessId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.createStaff(businessId, data);
      final newStaff = StaffModel.fromJson(response['staff']);
      state = state.copyWith(
        staff: [newStaff, ...state.staff],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> updateStaff(int businessId, int staffId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.updateStaff(businessId, staffId, data);
      final updatedStaff = StaffModel.fromJson(response['staff']);
      final updatedStaffList = state.staff.map((s) => s.id == staffId ? updatedStaff : s).toList();
      state = state.copyWith(staff: updatedStaffList, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> deleteStaff(int businessId, int staffId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiService.deleteStaff(businessId, staffId);
      final updatedStaff = state.staff.where((s) => s.id != staffId).toList();
      state = state.copyWith(staff: updatedStaff, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

// Lookup Provider for Staff
final staffLookupProvider = StateNotifierProvider<StaffLookupNotifier, StaffLookupState>((ref) {
  return StaffLookupNotifier();
});

class StaffLookupState {
  final List<Map<String, dynamic>> roles;
  final List<Map<String, dynamic>> shifts;
  final List<Map<String, dynamic>> staffStatuses;
  final bool isLoading;
  
  StaffLookupState({
    this.roles = const [],
    this.shifts = const [],
    this.staffStatuses = const [],
    this.isLoading = false,
  });

  get error => null;
  
  StaffLookupState copyWith({
    List<Map<String, dynamic>>? roles,
    List<Map<String, dynamic>>? shifts,
    List<Map<String, dynamic>>? staffStatuses,
    bool? isLoading,
  }) {
    return StaffLookupState(
      roles: roles ?? this.roles,
      shifts: shifts ?? this.shifts,
      staffStatuses: staffStatuses ?? this.staffStatuses,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StaffLookupNotifier extends StateNotifier<StaffLookupState> {
  StaffLookupNotifier() : super(StaffLookupState());
  
  Future<void> fetchLookupData() async {
    state = state.copyWith(isLoading: true);
    // Mock data - replace with actual API calls
    state = state.copyWith(
      roles: [
        {'id': 1, 'name': 'Manager'},
        {'id': 2, 'name': 'Receptionist'},
        {'id': 3, 'name': 'Housekeeping'},
        {'id': 4, 'name': 'Chef'},
        {'id': 5, 'name': 'Waiter'},
      ],
      shifts: [
        {'id': 1, 'name': 'Morning (6AM-2PM)'},
        {'id': 2, 'name': 'Evening (2PM-10PM)'},
        {'id': 3, 'name': 'Night (10PM-6AM)'},
      ],
      staffStatuses: [
        {'id': 1, 'name': 'Active'},
        {'id': 2, 'name': 'On Leave'},
        {'id': 3, 'name': 'Inactive'},
      ],
      isLoading: false,
    );
  }
}