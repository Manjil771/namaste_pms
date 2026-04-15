class AppConstants {
  static const String appName = 'Hotel PMS';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://your-api-domain.com/api/';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String businessDataKey = 'business_data';
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ssZ';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Order Status
  static const Map<int, String> orderStatus = {
    1: 'Pending',
    2: 'In Progress',
    3: 'Completed',
    4: 'Cancelled',
  };
  
  // Booking Status
  static const Map<int, String> bookingStatus = {
    1: 'Checked In',
    2: 'Checked Out',
    3: 'Booked',
    5: 'Cancelled',
  };
  
  // Room Status
  static const Map<int, String> roomStatus = {
    1: 'Available',
    2: 'Occupied',
    3: 'Maintenance',
  };
  
  // Table Status
  static const Map<int, String> tableStatus = {
    1: 'Available',
    2: 'Occupied',
    3: 'Reserved',
    4: 'Cleaning',
  };
  
  // Payment Methods
  static const Map<int, String> paymentMethods = {
    1: 'Cash',
    2: 'Card',
    3: 'Bank Transfer',
    4: 'Mobile Payment',
  };
}