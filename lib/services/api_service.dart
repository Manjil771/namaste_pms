import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _init();
  }

  Dio get dio => _dio;


  void _init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout:
          const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout:
          const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token =
              await _storage.read(key: AppConstants.accessTokenKey);

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();

            if (refreshed) {
              final response = await _retry(error.requestOptions);
              return handler.resolve(response);
            }
          }

          handler.next(error);
        },
      ),
    );
  }


  Future<Map<String, dynamic>> login(
      String phoneNumber, String password) async {
    final response = await _dio.post('/login/', data: {
      'phone_number': phoneNumber,
      'password': password,
    });

    return response.data;
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    final response = await _dio.post('/signup/', data: data);
    return response.data;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout/');
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<List<dynamic>> getStaff(int businessId) async {
    final response = await _dio.get('/staff/b$businessId/');
    return response.data['staff'];
  }

  Future<Map<String, dynamic>> createStaff(
      int businessId, Map<String, dynamic> data) async {
    final response =
        await _dio.post('/staff/b$businessId/', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateStaff(
      int businessId, int staffId, Map<String, dynamic> data) async {
    final response =
        await _dio.put('/staff/b$businessId/s$staffId/', data: data);
    return response.data;
  }

  Future<void> deleteStaff(int businessId, int staffId) async {
    await _dio.delete('/staff/b$businessId/s$staffId/');
  }

  // =========================
  // STAFF STATUS
  // =========================
  Future<Map<String, dynamic>> getStaffStatus(
    int businessId, {
    required bool getAll,
  }) async {
    final response = await _dio.get(
      '/staff-status/',
      queryParameters: {
        'bid': businessId,
        'get_all': getAll,
      },
    );

    return response.data;
  }

  // =========================
  // DASHBOARD
  // =========================
  Future<Map<String, dynamic>> getRoomStatus(int businessId) async {
    final response = await _dio.get(
      '/dashboard/room-status/',
      queryParameters: {'bid': businessId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMenuStatus(int businessId) async {
    final response = await _dio.get(
      '/dashboard/menu-status/',
      queryParameters: {'bid': businessId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getBookings(int businessId) async {
    final response = await _dio.get(
      '/dashboard/bookings/',
      queryParameters: {'bid': businessId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getRevenue(int businessId) async {
    final response = await _dio.get(
      '/dashboard/revenue/',
      queryParameters: {'bid': businessId},
    );
    return response.data;
  }

  // =========================
  // ROLES & SHIFTS
  // =========================
  Future<List<dynamic>> getRoles() async {
    final response = await _dio.get('/roles/');
    return response.data;
  }

  Future<List<dynamic>> getShifts() async {
    final response = await _dio.get('/shifts/');
    return response.data;
  }

  // =========================
  // TOKEN REFRESH
  // =========================
  Future<bool> _refreshToken() async {
    try {
      final refreshToken =
          await _storage.read(key: AppConstants.refreshTokenKey);

      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/refresh-token/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];

        await _storage.write(
          key: AppConstants.accessTokenKey,
          value: newAccessToken,
        );

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // RETRY REQUEST
  // =========================
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final newToken =
        await _storage.read(key: AppConstants.accessTokenKey);

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newToken',
      },
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }


  Future<dynamic> getPayments() async {
    throw UnimplementedError();
  }

  Future<dynamic> createPayment(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  Future<dynamic> updatePayment(
      int paymentId, Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  Future<void> deletePayment(int paymentId) async {
    throw UnimplementedError();
  }

  Future<void> deleteGuest(int guestId) async {}

  Future<dynamic> updateGuest(int guestId, Map<String, dynamic> data) async {}

  Future<dynamic> getGuests() async {}

  Future<dynamic> createGuest(Map<String, dynamic> data) async {}

  Future<dynamic> getCategories(int businessId) async {}

  Future<dynamic> getFoodItems() async {}

  Future<dynamic> updateFoodItem(int id, Map<String, dynamic> data) async {}

  Future<dynamic> createFoodItem(Map<String, dynamic> data) async {}

  Future<dynamic> createOrder(int businessId, Map<String, dynamic> data) async {}

  Future<dynamic> getOrders(int? tableId) async {}

  Future<dynamic> createRoom(Map<String, dynamic> data) async {}

  Future<dynamic> updateRoom(int roomId, Map<String, dynamic> data) async {}

  Future<void> deleteRoom(int roomId) async {}

  Future<dynamic> getMaintenanceUnits(int businessId) async {}

  Future<void> markUnitAvailable(String type, int id, int businessId) async {}

  Future<void> deleteBooking(int businessId, int bookingId) async {}

  Future<dynamic> createBooking(int businessId, Map<String, dynamic> data) async {}

  Future<dynamic> updateBooking(int businessId, int bookingId, Map<String, dynamic> data) async {}
}