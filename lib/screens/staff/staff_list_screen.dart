import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/staff_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
// import '../../config/theme.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key});

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStaff());
  }

  Future<void> _loadStaff() async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;

    await ref.read(staffProvider.notifier).fetchStaff(businessId);
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/staff/form');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStaff,
        child: _buildBody(staffState),
      ),
    );
  }

  Widget _buildBody(StaffState state) {
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
              onPressed: _loadStaff,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.staff.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'No Staff Members',
        message: 'Add your first staff member to get started',
        actionLabel: 'Add Staff',
        onAction: () {
          Navigator.pushNamed(context, '/staff/form');
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.staff.length,
      itemBuilder: (context, index) {
        final staff = state.staff[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(staff.role).withOpacity(0.2),
              child: Icon(
                _getRoleIcon(staff.role),
                color: _getRoleColor(staff.role),
              ),
            ),
            title: Text(
              staff.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${staff.roleName} • ${staff.shiftName}'),
                const SizedBox(height: 4),
                Text(
                  staff.phone,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(staff.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                staff.statusName,
                style: TextStyle(
                  color: _getStatusColor(staff.status),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/staff/form',
                arguments: {'id': staff.id},
              );
            },
          ),
        );
      },
    );
  }

  Color _getRoleColor(int roleId) {
    switch (roleId) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(int roleId) {
    switch (roleId) {
      case 1:
        return Icons.manage_accounts;
      case 2:
        return Icons.support_agent;
      case 3:
        return Icons.cleaning_services;
      default:
        return Icons.person;
    }
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
