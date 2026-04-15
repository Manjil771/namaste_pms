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
    _loadData();
  }
  
  Future<void> _loadData() async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;
    await ref.read(maintenanceProvider.notifier).fetchMaintenanceUnits(businessId);
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceState = ref.watch(maintenanceProvider);
    
    return Scaffold(
      appBar: AppBar(
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
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.2),
              child: Icon(
                _selectedTab == 'rooms' ? Icons.meeting_room : Icons.table_restaurant,
                color: Colors.orange,
              ),
            ),
            title: Text(
              _selectedTab == 'rooms' 
                  ? 'Room ${item['room_number']}' 
                  : 'Table ${item['table_number']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedTab == 'rooms') ...[
                  Text('Type: ${item['type_name']}'),
                  Text('Capacity: ${item['capacity']} persons'),
                ] else ...[
                  Text('Capacity: ${item['capacity']} persons'),
                ],
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['status_name'],
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _markAvailable(item['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Mark Available'),
            ),
          ),
        );
      },
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