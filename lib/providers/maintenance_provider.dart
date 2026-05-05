import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';

final maintenanceProvider = StateNotifierProvider<MaintenanceNotifier, MaintenanceState>((ref) {
  return MaintenanceNotifier();
});

class MaintenanceState {
  final List<Map<String, dynamic>> rooms;
  final List<Map<String, dynamic>> tables;
  final bool isLoading;
  final String? error;
  
  MaintenanceState({
    this.rooms = const [],
    this.tables = const [],
    this.isLoading = false,
    this.error,
  });
  
  MaintenanceState copyWith({
    List<Map<String, dynamic>>? rooms,
    List<Map<String, dynamic>>? tables,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MaintenanceState(
      rooms: rooms ?? this.rooms,
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MaintenanceNotifier extends StateNotifier<MaintenanceState> {
  MaintenanceNotifier() : super(MaintenanceState());
  
  final _apiService = ApiService();
  
  Future<void> fetchMaintenanceUnits(int businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.getMaintenanceUnits(businessId);
      state = state.copyWith(
        rooms: List<Map<String, dynamic>>.from(response['rooms'] ?? []),
        tables: List<Map<String, dynamic>>.from(response['tables'] ?? []),
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> markUnitAvailable(String type, int id, int businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _apiService.markUnitAvailable(type, id, businessId);
      
      if (type == 'room') {
        final updatedRooms = state.rooms.where((r) => r['id'] != id).toList();
        state = state.copyWith(rooms: updatedRooms, isLoading: false, clearError: true);
      } else {
        final updatedTables = state.tables.where((t) => t['id'] != id).toList();
        state = state.copyWith(tables: updatedTables, isLoading: false, clearError: true);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}