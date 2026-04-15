import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/staff/staff_list_screen.dart';
import '../screens/staff/staff_form_screen.dart';
import '../screens/guests/guest_list_screen.dart';
import '../screens/guests/guest_form_screen.dart';
import '../screens/rooms/room_list_screen.dart';
import '../screens/rooms/room_form_screen.dart';
import '../screens/bookings/booking_list_screen.dart';
import '../screens/bookings/booking_form_screen.dart';
import '../screens/orders/order_list_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/menu/menu_list_screen.dart';
import '../screens/menu/menu_form_screen.dart';
import '../screens/payments/payment_list_screen.dart';
import '../screens/payments/payment_form_screen.dart';
import '../screens/maintenance/maintenance_screen.dart';
import '../screens/reports/revenue_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  
  // Staff
  static const String staffList = '/staff';
  static const String staffForm = '/staff/form';
  
  // Guests
  static const String guestList = '/guests';
  static const String guestForm = '/guests/form';
  
  // Rooms
  static const String roomList = '/rooms';
  static const String roomForm = '/rooms/form';
  
  // Bookings
  static const String bookingList = '/bookings';
  static const String bookingForm = '/bookings/form';
  
  // Orders
  static const String orderList = '/orders';
  static const String orderDetail = '/orders/detail';
  
  // Menu
  static const String menuList = '/menu';
  static const String menuForm = '/menu/form';
  
  // Payments
  static const String paymentList = '/payments';
  static const String paymentForm = '/payments/form';
  
  // Maintenance
  static const String maintenance = '/maintenance';
  
  // Reports
  static const String revenue = '/reports/revenue';
  
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case staffList:
        return MaterialPageRoute(builder: (_) => const StaffListScreen());
      case staffForm:
        final args = settings.arguments as Map?;
        return MaterialPageRoute(
          builder: (_) => StaffFormScreen(staffId: args?['id']),
        );
      case guestList:
        return MaterialPageRoute(builder: (_) => const GuestListScreen());
      case guestForm:
        final args = settings.arguments as Map?;
        return MaterialPageRoute(
          builder: (_) => GuestFormScreen(guestId: args?['id']),
        );
      case roomList:
        return MaterialPageRoute(builder: (_) => const RoomListScreen());
      case roomForm:
        final args = settings.arguments as Map?;
        return MaterialPageRoute(
          builder: (_) => RoomFormScreen(roomId: args?['id']),
        );
      case bookingList:
        return MaterialPageRoute(builder: (_) => const BookingListScreen());
      case bookingForm:
        final args = settings.arguments as Map?;
        return MaterialPageRoute(
          builder: (_) => BookingFormScreen(bookingId: args?['id']),
        );
      case orderList:
        return MaterialPageRoute(builder: (_) => const OrderListScreen());
      case orderDetail:
        final args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: args['id']),
        );
      case menuList:
        return MaterialPageRoute(builder: (_) => const MenuListScreen());
      case menuForm:
        final args = settings.arguments as Map?;
        return MaterialPageRoute(
          builder: (_) => MenuFormScreen(itemId: args?['id']),
        );
      case paymentList:
        return MaterialPageRoute(builder: (_) => const PaymentListScreen());
      case paymentForm:
        final args = settings.arguments as Map?;
        return MaterialPageRoute(
          builder: (_) => PaymentFormScreen(paymentId: args?['id']),
        );
      case maintenance:
        return MaterialPageRoute(builder: (_) => const MaintenanceScreen());
      case revenue:
        return MaterialPageRoute(builder: (_) => const RevenueScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}