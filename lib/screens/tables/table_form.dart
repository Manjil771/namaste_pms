import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/table_provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class TableFormScreen extends ConsumerStatefulWidget {
  final int? tableId; // null = create, non-null = edit

  const TableFormScreen({super.key, this.tableId});

  @override
  ConsumerState<TableFormScreen> createState() => _TableFormScreenState();
}

class _TableFormScreenState extends ConsumerState<TableFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tableNumberController = TextEditingController();
  final _seatController = TextEditingController();
  final _locationNameController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  bool get isEditing => widget.tableId != null;

  @override
  void dispose() {
    _tableNumberController.dispose();
    _seatController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final businessId = ref.read(authProvider).user?.businessId;
    if (businessId == null) {
      setState(() => _error = 'Business ID not found. Please log in again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = {
        'table_number': _tableNumberController.text.trim(),
        'seat': int.parse(_seatController.text.trim()),
        'location_name': _locationNameController.text.trim(),
        'status_id': 1, // Available by default
      };

      // POST /api/table/b{business_id}/
      await ApiService().createTable(businessId, data);

      // Refresh table list so the bottom sheet shows the new table
      await ref.read(tableProvider.notifier).fetchTables();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Table created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Table' : 'Create Table'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Table Number ──────────────────────────────────────────
              TextFormField(
                controller: _tableNumberController,
                decoration: const InputDecoration(
                  labelText: 'Table Number *',
                  hintText: 'e.g. T-01',
                  prefixIcon: Icon(Icons.table_restaurant),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Table number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Seats ─────────────────────────────────────────────────
              TextFormField(
                controller: _seatController,
                decoration: const InputDecoration(
                  labelText: 'Number of Seats *',
                  hintText: 'e.g. 4',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Number of seats is required';
                  }
                  if (int.tryParse(v.trim()) == null) {
                    return 'Please enter a valid number';
                  }
                  if (int.parse(v.trim()) < 1) {
                    return 'Seats must be at least 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Location ──────────────────────────────────────────────
              TextFormField(
                controller: _locationNameController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  hintText: 'e.g. Main Hall, Balcony, Outdoor',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Error ─────────────────────────────────────────────────
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Submit ────────────────────────────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditing ? 'Update Table' : 'Create Table',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}