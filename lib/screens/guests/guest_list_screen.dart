import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/guest_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../config/theme.dart';

class GuestListScreen extends ConsumerStatefulWidget {
  const GuestListScreen({super.key});

  @override
  ConsumerState<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends ConsumerState<GuestListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGuests());
  }
  
  Future<void> _loadGuests() async {
    await ref.read(guestProvider.notifier).fetchGuests();
  }

  @override
  Widget build(BuildContext context) {
    final guestState = ref.watch(guestProvider);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        title: const Text('Guest Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/guests/form');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGuests,
        child: _buildBody(guestState),
      ),
    );
  }
  
  Widget _buildBody(GuestState state) {
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
              onPressed: _loadGuests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (state.guests.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'No Guests',
        message: 'Add your first guest to get started',
        actionLabel: 'Add Guest',
        onAction: () {
          Navigator.pushNamed(context, '/guests/form');
        },
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.guests.length,
      itemBuilder: (context, index) {
        final guest = state.guests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              child: Text(
                guest.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              guest.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(guest.phone),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/guests/form',
                  arguments: {'id': guest.id},
                );
              },
            ),
          ),
        );
      },
    );
  }
}