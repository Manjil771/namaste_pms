import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../config/theme.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  String _selectedTab = 'rooms';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }
  
  Future<void> _loadData() async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;
    await ref.read(maintenanceProvider.notifier).fetchMaintenanceUnits(businessId);
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceState = ref.watch(maintenanceProvider);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        title: const Text('Maintenance & Cleaning'),
        bottom: TabBar(
          tabs: const [
            Tab(text: 'Rooms', icon: Icon(Icons.meeting_room)),
            Tab(text: 'Tables', icon: Icon(Icons.table_restaurant)),
          ],
          onTap: (index) {
            setState(() {
              _selectedTab = index == 0 ? 'rooms' : 'tables';
            });
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(maintenanceState),
      ),
    ),
    );
  }
  
  Widget _buildBody(MaintenanceState state) {
    if (state.isLoading) {
      return const LoadingWidget();
    }
    
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final items = _selectedTab == 'rooms' ? state.rooms : state.tables;
    
    if (items.isEmpty) {
      return EmptyStateWidget(
        icon: _selectedTab == 'rooms' ? Icons.meeting_room_outlined : Icons.table_restaurant_outlined,
        title: 'No Items in Maintenance',
        message: 'All units are currently operational',
        actionLabel: null,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _selectedTab == 'rooms'
            ? _buildRoomCard(item)
            : _buildTableCard(item);
      },
    );
  }
  
  Color _statusColor(String? statusName) {
    if (statusName == 'Cleaning') return Colors.blue;
    return Colors.orange; // Maintenance
  }

  Widget _buildRoomCard(Map<String, dynamic> item) {
    final color = _statusColor(item['status_name'] as String?);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(Icons.meeting_room, color: color),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room ${item['room_number']}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item['type_name'] ?? '',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['status_name'] ?? '',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.people_outline,
                    '${item['capacity']} persons'),
                const SizedBox(width: 16),
                _infoChip(Icons.currency_rupee,
                    '₹${item['price']} / night'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark as Available'),
                onPressed: () => _markAvailable(item['id'] as int),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(Map<String, dynamic> item) {
    final color = _statusColor(item['status_name'] as String?);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(Icons.table_restaurant, color: color),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Table ${item['table_number']}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['status_name'] ?? '',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _infoChip(Icons.people_outline, '${item['capacity']} persons'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark as Available'),
                onPressed: () => _markAvailable(item['id'] as int),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  Future<void> _markAvailable(int id) async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;
    final success = await ref.read(maintenanceProvider.notifier).markUnitAvailable(
      _selectedTab,
      id,
      businessId,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unit marked as available'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      await _loadData();
    }
  }
}