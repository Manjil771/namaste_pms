import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../config/theme.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrder();
  }
  
  Future<void> _loadOrder() async {
    await ref.read(orderProvider.notifier).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.orders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => throw Exception('Order not found'),
    );
    
    if (orderState.isLoading) {
      return const Scaffold(body: LoadingWidget());
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('Order Number', order.orderNumber),
                    const Divider(),
                    _buildInfoRow('Status', order.statusName ?? 'Unknown'),
                    const Divider(),
                    _buildInfoRow('Table', 'Table ${order.tableId}'),
                    const Divider(),
                    _buildInfoRow('Guest', order.guestName),
                    const Divider(),
                    _buildInfoRow('Date', DateFormat('MMM d, yyyy h:mm a').format(order.createdAt)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Order Items
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.foodItemName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (item.note != null && item.note!.isNotEmpty)
                                Text(
                                  'Note: ${item.note}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              Text(
                                'Qty: ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Total Amount
            Card(
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('Subtotal', '₹${order.subtotal.toStringAsFixed(0)}'),
                    _buildInfoRow('Tax', '₹${order.tax.toStringAsFixed(0)}'),
                    _buildInfoRow('Discount', '-₹${order.discount.toStringAsFixed(0)}'),
                    const Divider(),
                    _buildInfoRow(
                      'Total',
                      '₹${order.totalAmount.toStringAsFixed(0)}',
                      isBold: true,
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
  
  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}