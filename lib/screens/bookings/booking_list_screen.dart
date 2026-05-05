import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nhpms/models/booking/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class BookingListScreen extends ConsumerStatefulWidget {
  const BookingListScreen({super.key});

  @override
  ConsumerState<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends ConsumerState<BookingListScreen> {
  String _filterStatus = 'all';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookings());
  }
  
  Future<void> _loadBookings() async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;
    await ref.read(bookingProvider.notifier).fetchBookings(businessId);
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final filteredBookings = _getFilteredBookings(bookingState.bookings);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        title: const Text('Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/bookings/form');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildFilterTabs(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: _buildBody(bookingState, filteredBookings),
      ),
    );
  }
  
  Widget _buildFilterTabs() {
    final tabs = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Booked', 'value': '3'},
      {'label': 'Checked In', 'value': '1'},
      {'label': 'Checked Out', 'value': '2'},
      {'label': 'Cancelled', 'value': '5'},
    ];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = _filterStatus == tab['value'];
          return FilterChip(
            label: Text(tab['label']!),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _filterStatus = tab['value']!;
              });
            },
            backgroundColor: Colors.grey[200],
            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
          );
        },
      ),
    );
  }
  
  List<BookingModel> _getFilteredBookings(List<BookingModel> bookings) {
    if (_filterStatus == 'all') return bookings;
    final statusId = int.parse(_filterStatus);
    return bookings.where((booking) => booking.statusId == statusId).toList();
  }
  
  Widget _buildBody(BookingState state, List<BookingModel> bookings) {
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
              onPressed: _loadBookings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (bookings.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.book_online_outlined,
        title: 'No Bookings Found',
        message: _filterStatus == 'all' 
            ? 'Create your first booking to get started'
            : 'No bookings with this status',
        actionLabel: _filterStatus == 'all' ? 'New Booking' : null,
        onAction: _filterStatus == 'all' 
            ? () => Navigator.pushNamed(context, '/bookings/form')
            : null,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }
  
  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/bookings/form',
            arguments: {'id': booking.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.guestName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Room ${booking.roomNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.statusId).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.statusName ?? AppConstants.bookingStatus[booking.statusId] ?? 'Unknown',
                      style: TextStyle(
                        color: _getStatusColor(booking.statusId),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('MMM d, yyyy').format(booking.checkIn)} - ${DateFormat('MMM d, yyyy').format(booking.checkOut)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nights_stay, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${booking.nights} nights',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    '₹${NumberFormat('#,##0').format(booking.amount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              if (booking.advancePayment != null && booking.advancePayment! > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment, size: 14, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Advance: ₹${NumberFormat('#,##0').format(booking.advancePayment)}',
                        style: TextStyle(fontSize: 12, color: Colors.amber[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1: return Colors.green;
      case 2: return Colors.orange;
      case 3: return Colors.blue;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }
}