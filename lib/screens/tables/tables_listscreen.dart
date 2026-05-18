import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nhpms/models/table_model.dart';
import '../../providers/table_provider.dart';


class TableListScreen extends ConsumerStatefulWidget {
  const TableListScreen({super.key});

  @override
  ConsumerState<TableListScreen> createState() => _TableListScreenState();
}

class _TableListScreenState extends ConsumerState<TableListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(tableProvider.notifier).fetchTables(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tableState = ref.watch(tableProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        title: const Text('Tables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Table',
            onPressed: () async {
              await Navigator.pushNamed(context, '/tables/form');
              // Refresh after returning from form
              ref.read(tableProvider.notifier).fetchTables();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(tableProvider.notifier).fetchTables(),
        child: _buildBody(tableState),
      ),
      // FAB as a second entry point
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/tables/form');
          ref.read(tableProvider.notifier).fetchTables();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Table'),
      ),
    );
  }

  Widget _buildBody(TableState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(tableProvider.notifier).fetchTables(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_restaurant_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tables yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first table to get started',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, '/tables/form');
                ref.read(tableProvider.notifier).fetchTables();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Table'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.tables.length,
      itemBuilder: (context, index) => _buildTableCard(state.tables[index]),
    );
  }

  Widget _buildTableCard(TableModel table) {
    final statusColor = table.isAvailable ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor, width: 1.5),
          ),
          child: Icon(Icons.table_restaurant, color: statusColor),
        ),
        title: Text(
          table.tableNumber,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          table.statusName,
          style: TextStyle(color: statusColor, fontSize: 12),
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            table.statusName,
            style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}