import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/constants.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

class HotelPMSApp extends ConsumerStatefulWidget {
  const HotelPMSApp({super.key});

  @override
  ConsumerState<HotelPMSApp> createState() => _HotelPMSAppState();
}

class _HotelPMSAppState extends ConsumerState<HotelPMSApp> {
  @override
void initState() {
  super.initState();

  Future.microtask(() {
    _checkAuthStatus();
  });
}

  Future<void> _checkAuthStatus() async {
    await ref.read(authProvider.notifier).checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: _getInitialScreen(authState),
    );
  }

  Widget _getInitialScreen(AuthState authState) {
    if (authState.isLoading) {
      return const SplashScreen();
    }
    
    if (authState.isAuthenticated && authState.accessToken != null) {
      return const DashboardScreen();
    }
    
    return const LoginScreen();
  }
}