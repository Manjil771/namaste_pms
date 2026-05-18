import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nhpms/models/table_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/table_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
      ref.read(tableProvider.notifier).fetchTables();
    });
  }

  Future<void> _loadOrders() async {
    await ref.read(orderProvider.notifier).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showTableSelection,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _buildBody(orderState),
      ),
    );
  }

  // ── Table Selection Bottom Sheet ────────────────────────────────────────────

  void _showTableSelection() {
    ref.read(tableProvider.notifier).fetchTables();

    final parentContext = context; // ✅ capture OrderListScreen's context

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _TableSelectionSheet(
          onTableSelected: (TableModel table) {
            Navigator.pop(sheetContext); // ✅ close sheet using sheet's context
            Navigator.pushNamed(
              parentContext,            // ✅ navigate using parent's context
              '/orders/form',
              arguments: {
                'table_id': table.id,
                'table_number': table.tableNumber,
              },
            );
          },
        );
      },
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────

  Widget _buildBody(OrderState state) {
    if (state.isLoading) return const LoadingWidget();

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
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.orders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_outlined,
        title: 'No Orders',
        message: 'Create your first order to get started',
        actionLabel: 'New Order',
        onAction: _showTableSelection,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.orders.length,
      itemBuilder: (context, index) => _buildOrderCard(state.orders[index]),
    );
  }

  // ── Order Card ───────────────────────────────────────────────────────────────

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/orders/detail',
          arguments: {'id': order.id},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order number + status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.statusId).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.statusName ??
                          AppConstants.orderStatus[order.statusId] ??
                          'Unknown',
                      style: TextStyle(
                        color: _getStatusColor(order.statusId),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Table + guest row
              Row(
                children: [
                  Icon(Icons.table_restaurant,
                      size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Table ${order.tableId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    order.guestName ?? 'Guest #${order.guestId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items count + total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} items',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '₹${NumberFormat('#,##0.00').format(double.tryParse(order.totalAmount.toString()) ?? 0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                DateFormat('MMM d, yyyy h:mm a').format(order.createdAt),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ── Separate widget so it can watch tableProvider independently ────────────────

class _TableSelectionSheet extends ConsumerWidget {
  const _TableSelectionSheet({required this.onTableSelected});

  final void Function(TableModel table) onTableSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select a Table',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context), // ✅ just dismiss the sheet
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Only available tables are shown',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),

          // Loading
          if (tableState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )

          // Error
          else if (tableState.error != null)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 40, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(tableState.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(tableProvider.notifier).fetchTables(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )

          // No available tables
          else if (tableState.availableTables.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No available tables right now.\nAll tables are occupied or under maintenance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )

          // Table grid
          else
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.4,
                ),
                itemCount: tableState.availableTables.length,
                itemBuilder: (context, index) {
                  final table = tableState.availableTables[index];
                  return _TableChip(
                    table: table,
                    onTap: () => onTableSelected(table),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Single table chip ─────────────────────────────────────────────────────────

class _TableChip extends StatelessWidget {
  const _TableChip({required this.table, required this.onTap});

  final TableModel table;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          border: Border.all(color: Colors.green, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.table_restaurant, color: Colors.green, size: 22),
            const SizedBox(height: 4),
            Text(
              table.tableNumber,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}