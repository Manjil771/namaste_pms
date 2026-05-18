import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../config/theme.dart';

class PaymentListScreen extends ConsumerStatefulWidget {
  const PaymentListScreen({super.key});

  @override
  ConsumerState<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends ConsumerState<PaymentListScreen> {
  String _filterType = 'all';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPayments());
  }

  Future<void> _loadPayments() async {
    await ref.read(paymentProvider.notifier).fetchPayments();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final filteredPayments = _getFilteredPayments(paymentState.payments);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/payments/form');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildFilterChips(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child: _buildBody(paymentState, filteredPayments),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Advance', 'value': 'advance'},
      {'label': 'Room', 'value': 'room'},
      {'label': 'Cafe', 'value': 'cafe'},
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
          final isSelected = _filterType == filter['value'];
          return FilterChip(
            label: Text(filter['label']!),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _filterType = filter['value']!;
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

  List<PaymentModel> _getFilteredPayments(List<PaymentModel> payments) {
    if (_filterType == 'all') return payments;
    if (_filterType == 'advance') {
      return payments.where((p) => p.isAdvance).toList();
    }
    return payments;
  }

  Widget _buildBody(PaymentState state, List<PaymentModel> payments) {
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
              onPressed: _loadPayments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (payments.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.payment_outlined,
        title: 'No Payments',
        message: 'No payment records found',
        actionLabel: 'New Payment',
        onAction: () {
          Navigator.pushNamed(context, '/payments/form');
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    final isAdvance = payment.isAdvance;
    
    var advanced = Icons.money_sharp;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/payments/form',
            arguments: {'id': payment.id},
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isAdvance 
                              ? Colors.amber.withOpacity(0.2)
                              : AppTheme.successColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isAdvance ? advanced : Icons.payment,
                          color: isAdvance ? Colors.amber : AppTheme.successColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAdvance ? 'Advance Payment' : 'Payment',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            payment.paymentMethod,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(payment.statusId).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      payment.statusName,
                      style: TextStyle(
                        color: _getStatusColor(payment.statusId),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '₹${NumberFormat('#,##0').format(payment.amount)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy h:mm a').format(payment.paidAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (payment.bookingId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Booking #${payment.bookingId}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1: return Colors.orange;
      case 2: return Colors.green;
      case 3: return Colors.red;
      default: return Colors.grey;
    }
  }
}