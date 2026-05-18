import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier();
});

class MenuState {
  final List<CategoryModel> categories;
  final List<FoodItemModel> foodItems;
  final bool isLoading;
  final String? error;
  
  MenuState({
    this.categories = const [],
    this.foodItems = const [],
    this.isLoading = false,
    this.error,
  });
  
  MenuState copyWith({
    List<CategoryModel>? categories,
    List<FoodItemModel>? foodItems,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      foodItems: foodItems ?? this.foodItems,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final int businessId;
  
  CategoryModel({
    required this.id,
    required this.name,
    required this.businessId,
  });
  
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      businessId: json['business_id'],
    );
  }
}

class FoodItemModel {
  final int id;
  final int businessId;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final int preparationTime;
  final int spiceLevelId;
  final bool isAvailable;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  FoodItemModel({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    required this.preparationTime,
    required this.spiceLevelId,
    required this.isAvailable,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'],
      businessId: json['business_id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      preparationTime: json['preparation_time'] ?? 15,
      spiceLevelId: json['spice_level_id'] ?? 1,
      isAvailable: json['is_available'] ?? true,
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class MenuNotifier extends StateNotifier<MenuState> {
  MenuNotifier() : super(MenuState());
  
  final _apiService = ApiService();
  
  Future<void> fetchCategories() async {
    const businessId = 1;
    state = state.copyWith(clearError: true);
    try {
      final response = await _apiService.getCategories(businessId);
      final list = response as List? ?? [];
      final categories = list.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(categories: categories);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchFoodItems() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.getFoodItems();
      final list = response as List? ?? [];
      final items = list.map((json) => FoodItemModel.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(foodItems: items, isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateFoodItem(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.updateFoodItem(id, data);
      final updatedItem = FoodItemModel.fromJson(response as Map<String, dynamic>);
      final updatedItems = state.foodItems.map((item) {
        return item.id == id ? updatedItem : item;
      }).toList();
      state = state.copyWith(foodItems: updatedItems, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> createFoodItem(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.createFoodItem(data);
      final newItem = FoodItemModel.fromJson(response as Map<String, dynamic>);
      final updatedItems = [...state.foodItems, newItem];
      state = state.copyWith(foodItems: updatedItems, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<dynamic> deleteFoodItem(int itemId) async {}}