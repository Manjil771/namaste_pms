import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nhpms/models/room/room_model.dart';
import '../../providers/room_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class RoomListScreen extends ConsumerStatefulWidget {
  const RoomListScreen({super.key});

  @override
  ConsumerState<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends ConsumerState<RoomListScreen> {
  String _filterStatus = 'all';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRooms());
  }
  
  Future<void> _loadRooms() async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;
    await ref.read(roomProvider.notifier).fetchRooms(businessId);
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomProvider);
    final filteredRooms = _getFilteredRooms(roomState.rooms);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        title: const Text('Room Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/rooms/form');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildFilterChips(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRooms,
        child: _buildBody(roomState, filteredRooms),
      ),
    );
  }
  
  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Available', 'value': '1'},
      {'label': 'Occupied', 'value': '2'},
      {'label': 'Maintenance', 'value': '3'},
    ];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _filterStatus == filter['value'];
          return FilterChip(
            label: Text(filter['label']!),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _filterStatus = filter['value']!;
              });
            },
            backgroundColor: Colors.grey[200],
            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
            checkmarkColor: AppTheme.primaryColor,
          );
        },
      ),
    );
  }
  
  List<RoomModel> _getFilteredRooms(List<RoomModel> rooms) {
    if (_filterStatus == 'all') return rooms;
    final statusId = int.parse(_filterStatus);
    return rooms.where((room) => room.statusId == statusId).toList();
  }
  
  Widget _buildBody(RoomState state, List<RoomModel> rooms) {
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
              onPressed: _loadRooms,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (rooms.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.meeting_room_outlined,
        title: 'No Rooms Found',
        message: _filterStatus == 'all' 
            ? 'Add your first room to get started'
            : 'No rooms with this status',
        actionLabel: _filterStatus == 'all' ? 'Add Room' : null,
        onAction: _filterStatus == 'all' 
            ? () => Navigator.pushNamed(context, '/rooms/form')
            : null,
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return _buildRoomCard(room);
      },
    );
  }
  
  Widget _buildRoomCard(RoomModel room) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/rooms/form',
            arguments: {'id': room.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Number Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(room.statusId).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.roomNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(room.statusId),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          room.statusName ?? AppConstants.roomStatus[room.statusId] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.roomTypeName ?? 'Standard',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Room Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Capacity: ${room.capacity} persons',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.currency_rupee, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '₹${room.price.toStringAsFixed(0)}/night',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Floor ${room.floor}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (room.statusId == 1) // Available
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/bookings/form',
                                arguments: {'roomId': room.id},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('Book Now', style: TextStyle(fontSize: 12)),
                          ),
                        if (room.statusId == 2) // Occupied
                          OutlinedButton(
                            onPressed: () {
                              // Navigate to check-out
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('Check Out', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1: return AppTheme.successColor;
      case 2: return AppTheme.warningColor;
      case 3: return AppTheme.errorColor;
      default: return Colors.grey;
    }
  }
}