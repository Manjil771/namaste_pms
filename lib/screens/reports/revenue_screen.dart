import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nhpms/screens/dashboard/dashboard_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../config/theme.dart';

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  String _selectedPeriod = 'today';
  
  @override
  void initState() {
    super.initState();
    _loadRevenue();
  }
  
  Future<void> _loadRevenue() async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;
    await ref.read(revenueProvider.notifier).fetchRevenue(businessId);
  }

  @override
  Widget build(BuildContext context) {
    final revenueState = ref.watch(revenueProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Report'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadRevenue();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('Today')),
              const PopupMenuItem(value: 'week', child: Text('This Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month')),
              const PopupMenuItem(value: 'year', child: Text('This Year')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRevenue,
        child: _buildBody(revenueState),
      ),
    );
  }
  
  Widget _buildBody(RevenueState state) {
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
              onPressed: _loadRevenue,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final revenue = state.revenueData;
    final roomRevenue = (revenue['room_revenue'] ?? 0).toDouble();
    final cafeRevenue = (revenue['cafe_revenue'] ?? 0).toDouble();
    final totalRevenue = (revenue['total_revenue'] ?? 0).toDouble();
    final date = revenue['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Display
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reporting Date',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Total Revenue Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${NumberFormat('#,##0').format(totalRevenue)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Revenue Breakdown
          const Text(
            'Revenue Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBreakdownCard(
                  'Room Revenue',
                  roomRevenue,
                  Colors.blue,
                  Icons.meeting_room,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBreakdownCard(
                  'Cafe Revenue',
                  cafeRevenue,
                  Colors.orange,
                  Icons.restaurant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Revenue Chart
          const Text(
            'Revenue Chart',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
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
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: totalRevenue > 0 ? totalRevenue * 1.2 : 10000,
                barGroups: _getChartData(roomRevenue, cafeRevenue),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
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
                        const categories = ['Room', 'Cafe'];
                        return Text(
                          categories[value.toInt()],
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Insights
          const Text(
            'Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Revenue Distribution',
            'Room revenue contributes ${((roomRevenue / totalRevenue) * 100).toStringAsFixed(1)}% of total revenue',
            Icons.pie_chart,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Performance',
            roomRevenue > cafeRevenue 
                ? 'Room bookings are generating more revenue than cafe orders'
                : 'Cafe orders are generating more revenue than room bookings',
            Icons.trending_up,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBreakdownCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${NumberFormat('#,##0').format(amount)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  List<BarChartGroupData> _getChartData(double roomRevenue, double cafeRevenue) {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: roomRevenue,
            color: Colors.blue,
            width: 40,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: cafeRevenue,
            color: Colors.orange,
            width: 40,
          ),
        ],
      ),
    ];
  }
  
  Widget _buildInsightCard(String title, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}