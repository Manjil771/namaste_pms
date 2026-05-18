import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';

final staffLookupProvider =
    StateNotifierProvider<StaffLookupNotifier, StaffLookupState>((ref) {
  return StaffLookupNotifier();
});

class StaffLookupState {
  final List<Map<String, dynamic>> roles;
  final List<Map<String, dynamic>> shifts;
  final List<Map<String, dynamic>> staffStatuses;
  final bool isLoading;
  final String? error;

  StaffLookupState({
    this.roles = const [],
    this.shifts = const [],
    this.staffStatuses = const [],
    this.isLoading = false,
    this.error,
  });

  StaffLookupState copyWith({
    List<Map<String, dynamic>>? roles,
    List<Map<String, dynamic>>? shifts,
    List<Map<String, dynamic>>? staffStatuses,
    bool? isLoading,
    String? error,
  }) {
    return StaffLookupState(
      roles: roles ?? this.roles,
      shifts: shifts ?? this.shifts,
      staffStatuses: staffStatuses ?? this.staffStatuses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class StaffLookupNotifier extends StateNotifier<StaffLookupState> {
  StaffLookupNotifier() : super(StaffLookupState());

  final _apiService = ApiService();

  Future<void> fetchLookupData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _apiService.getRoles(),
        _apiService.getShifts(),
        _apiService.getStaffStatus(0, getAll: true),
      ] as Iterable<Future<dynamic>>);

      final roles = (results[0] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final shifts = (results[1] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final staffStatuses = (results[2] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      state = state.copyWith(
        roles: roles,
        shifts: shifts,
        staffStatuses: staffStatuses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}