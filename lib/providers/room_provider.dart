import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';
import '../models/room/room_model.dart';

final roomProvider = StateNotifierProvider<RoomNotifier, RoomState>((ref) {
  return RoomNotifier();
});

class RoomState {
  final List<RoomModel> rooms;
  final bool isLoading;
  final String? error;
  
  RoomState({
    this.rooms = const [],
    this.isLoading = false,
    this.error,
  });
  
  RoomState copyWith({
    List<RoomModel>? rooms,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RoomNotifier extends StateNotifier<RoomState> {
  RoomNotifier() : super(RoomState());
  
  final _apiService = ApiService();
  
  Future<void> fetchRooms(int businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.getRooms(businessId);
      final rooms = response.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(rooms: rooms, isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createRoom(int businessId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.createRoom(businessId, data);
      final newRoom = RoomModel.fromJson(response['room'] as Map<String, dynamic>);
      state = state.copyWith(
        rooms: [...state.rooms, newRoom],
        isLoading: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateRoom(int businessId, int roomId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.updateRoom(businessId, roomId, data);
      final updatedRoom = RoomModel.fromJson(response['room'] as Map<String, dynamic>);

      final updatedRooms = state.rooms.map((room) {
        return room.id == roomId ? updatedRoom : room;
      }).toList();

      state = state.copyWith(rooms: updatedRooms, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteRoom(int businessId, int roomId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _apiService.deleteRoom(businessId, roomId);
      final updatedRooms = state.rooms.where((room) => room.id != roomId).toList();
      state = state.copyWith(rooms: updatedRooms, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}