import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';
import '../models/business/business_model.dart';

final businessProvider = FutureProvider<BusinessModel?>((ref) async {
  final apiService = ApiService();
  // TODO: Fetch business data from API
  return null;
});

final businessTypeProvider = StateNotifierProvider<BusinessTypeNotifier, List<Map<String, dynamic>>>((ref) {
  return BusinessTypeNotifier();
});

class BusinessTypeNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  BusinessTypeNotifier() : super([]);
  
  final _apiService = ApiService();
  
  Future<void> fetchBusinessTypes() async {
    // TODO: Implement API call to get business types
    // For now, return mock data
    state = [
      {'id': 1, 'name': 'Hotel'},
      {'id': 2, 'name': 'Restaurant'},
      {'id': 3, 'name': 'Cafe'},
      {'id': 4, 'name': 'Resort'},
    ];
  }
}