import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  }) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RoomNotifier extends StateNotifier<RoomState> {
  RoomNotifier() : super(RoomState());
  
  final _apiService = ApiService();
  
  Future<void> fetchRooms() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.getRoles();
      final rooms = (response as List).map((json) => RoomModel.fromJson(json)).toList();
      state = state.copyWith(rooms: rooms, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<bool> createRoom(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.createRoom(data);
      final newRoom = RoomModel.fromJson(response['room']);
      state = state.copyWith(
        rooms: [...state.rooms, newRoom],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> updateRoom(int roomId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.updateRoom(roomId, data);
      final updatedRoom = RoomModel.fromJson(response['room']);
      
      final updatedRooms = state.rooms.map((room) {
        return room.id == roomId ? updatedRoom : room;
      }).toList();
      
      state = state.copyWith(rooms: updatedRooms, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> deleteRoom(int roomId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiService.deleteRoom(roomId);
      final updatedRooms = state.rooms.where((room) => room.id != roomId).toList();
      state = state.copyWith(rooms: updatedRooms, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}