import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nhpms/screens/dashboard/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/drawer_widget.dart';
import '../../widgets/cards/stats_card.dart';
import '../../config/theme.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadDashboardData());
  }
  
  Future<void> _loadDashboardData() async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;
    await Future.wait([
      ref.read(roomStatusProvider.notifier).fetchRoomStatus(businessId),
      ref.read(menuStatusProvider.notifier).fetchMenuStatus(businessId),
      ref.read(staffStatusProvider.notifier).fetchStaffStatus(businessId),
      ref.read(recentBookingsProvider.notifier).fetchRecentBookings(businessId),
      ref.read(revenueProvider.notifier).fetchRevenue(businessId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final roomStatus = ref.watch(roomStatusProvider);
    final menuStatus = ref.watch(menuStatusProvider);
    final staffStatus = ref.watch(staffStatusProvider);
    final recentBookings = ref.watch(recentBookingsProvider);
    final revenue = ref.watch(revenueProvider);
    
    final user = authState.user;
    final today = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.username ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      today,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Total Rooms',
                      value: roomStatus.roomStatus['total']?.toString() ?? '0',
                      icon: Icons.meeting_room,
                      color: Colors.blue,
                      isLoading: roomStatus.isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Available',
                      value: roomStatus.roomStatus['available']?.toString() ?? '0',
                      icon: Icons.check_circle,
                      color: Colors.green,
                      isLoading: roomStatus.isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Occupied',
                      value: roomStatus.roomStatus['occupied']?.toString() ?? '0',
                      icon: Icons.person,
                      color: Colors.orange,
                      isLoading: roomStatus.isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Menu Items',
                      value: menuStatus.menuStatus['total_food_items']?.toString() ?? '0',
                      icon: Icons.restaurant_menu,
                      color: Colors.purple,
                      isLoading: menuStatus.isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Staff',
                      value: staffStatus.staffStatus['total_staff_count']?.toString() ?? '0',
                      icon: Icons.people,
                      color: Colors.teal,
                      isLoading: staffStatus.isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Revenue',
                      value: '₹${NumberFormat('#,##0').format(revenue.revenueData['total_revenue'] ?? 0)}',
                      icon: Icons.currency_rupee,
                      color: Colors.amber,
                      isLoading: revenue.isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Revenue Chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100000,
                          barGroups: _getRevenueChartData(),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '₹${(value / 1000).toInt()}k',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  return Text(
                                    days[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Recent Bookings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Bookings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/bookings');
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (recentBookings.isLoading)
                      _buildShimmerList()
                    else if (recentBookings.bookings.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No recent bookings',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentBookings.bookings.take(5).length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final booking = recentBookings.bookings[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(booking.statusId).withOpacity(0.2),
                              child: Icon(
                                _getStatusIcon(booking.statusId),
                                color: _getStatusColor(booking.statusId),
                                size: 20,
                              ),
                            ),
                            title: Text(booking.guestName),
                            subtitle: Text(
                              'Room ${booking.roomNumber} • ${DateFormat('MMM d').format(booking.checkIn)} - ${DateFormat('MMM d').format(booking.checkOut)}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${NumberFormat('#,##0').format(booking.amount)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(booking.statusId).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    booking.statusName ?? '',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _getStatusColor(booking.statusId),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/bookings/form',
                                arguments: {'id': booking.id},
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<BarChartGroupData> _getRevenueChartData() {
    // Mock data - replace with actual revenue data
    return [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 45000, color: AppTheme.primaryColor)]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 52000, color: AppTheme.primaryColor)]),
      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 48000, color: AppTheme.primaryColor)]),
      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 61000, color: AppTheme.primaryColor)]),
      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 58000, color: AppTheme.primaryColor)]),
      BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 72000, color: AppTheme.primaryColor)]),
      BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 68000, color: AppTheme.primaryColor)]),
    ];
  }
  
  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(5, (index) => 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      default: return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(int statusId) {
    switch (statusId) {
      case 1: return Icons.input_rounded;
      case 2: return Icons.input_outlined;
      case 3: return Icons.book_online;
      default: return Icons.info;
    }
  }
}