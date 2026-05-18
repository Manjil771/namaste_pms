import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class DrawerWidget extends ConsumerWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      child: Column(
        children: [
          // Header
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.business,
                        size: 40, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.businessName ?? 'Hotel PMS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.username ?? 'User',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () => _navigateAndClose(context, '/dashboard'),
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.people,
                  title: 'Staff Management',
                  onTap: () => _navigateAndClose(context, '/staff'),
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Guest Management',
                  onTap: () => _navigateAndClose(context, '/guests'),
                ),
                _buildDrawerItem(
                  icon: Icons.meeting_room,
                  title: 'Room Management',
                  onTap: () => _navigateAndClose(context, '/rooms'),
                ),
              
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.restaurant_menu,
                  title: 'Menu Management',
                  onTap: () => _navigateAndClose(context, '/menu'),
                ),
                 _buildDrawerItem(
                  icon: Icons.table_restaurant,
                  title: 'Table Management',
                  onTap: () => _navigateAndClose(context, '/tables'),
                ),
                _buildDrawerItem(
                  icon: Icons.receipt,
                  title: 'Orders',
                  onTap: () => _navigateAndClose(context, '/orders'),
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.payment,
                  title: 'Payments',
                  onTap: () => _navigateAndClose(context, '/payments'),
                ),
                _buildDrawerItem(
                  icon: Icons.build,
                  title: 'Maintenance',
                  onTap: () => _navigateAndClose(context, '/maintenance'),
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart,
                  title: 'Revenue Report',
                  onTap: () => _navigateAndClose(context, '/reports/revenue'),
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () => _logout(ref, context),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(title, style: TextStyle(color: color ?? Colors.grey[800])),
      onTap: onTap,
      hoverColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }

  void _navigateAndClose(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _logout(WidgetRef ref, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}
