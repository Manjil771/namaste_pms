import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../providers/room_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class RoomFormScreen extends ConsumerStatefulWidget {
  final int? roomId;
  const RoomFormScreen({super.key, this.roomId});

  @override
  ConsumerState<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends ConsumerState<RoomFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditing = false;
  final List<Map<String, dynamic>> _roomTypes = [
    {'id': 1, 'name': 'Standard'},
    {'id': 2, 'name': 'Deluxe'},
    {'id': 3, 'name': 'Suite'},
    {'id': 4, 'name': 'Presidential'},
    {'id': 5, 'name': 'Family Room'},
    {'id': 6, 'name': 'Single'},
    {'id': 7, 'name': 'Double'},
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.roomId != null;
    if (_isEditing) {
      _loadRoomData();
    }
  }

  Future<void> _loadRoomData() async {
    await ref.read(roomProvider.notifier).fetchRooms();
    final roomState = ref.read(roomProvider);
    final room = roomState.rooms.firstWhere(
      (r) => r.id == widget.roomId,
      orElse: () => throw Exception('Room not found'),
    );

    _formKey.currentState?.patchValue({
      'room_number': room.roomNumber,
      'type_id': room.typeId,
      'capacity': room.capacity,
      'price': room.price,
      'floor': room.floor,
      'status_id': room.statusId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomProvider);

    return LoadingOverlay(
      isLoading: roomState.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Room' : 'Add Room'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Room Number
                FormBuilderTextField(
                  name: 'room_number',
                  decoration: const InputDecoration(
                    labelText: 'Room Number *',
                    prefixIcon: Icon(Icons.meeting_room),
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 101, 202, 305',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Room number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Room Type - FIXED: Added explicit DropdownMenuItem type
                FormBuilderDropdown<int>(
                  name: 'type_id',
                  decoration: const InputDecoration(
                    labelText: 'Room Type *',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: _roomTypes.map<DropdownMenuItem<int>>((type) {
                    return DropdownMenuItem<int>(
                      value: type['id'] as int,
                      child: Text(type['name'] as String),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Room type is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Capacity - Using Dropdown instead of Slider
                FormBuilderDropdown<int>(
                  name: 'capacity',
                  decoration: const InputDecoration(
                    labelText: 'Capacity',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 person')),
                    DropdownMenuItem(value: 2, child: Text('2 persons')),
                    DropdownMenuItem(value: 3, child: Text('3 persons')),
                    DropdownMenuItem(value: 4, child: Text('4 persons')),
                    DropdownMenuItem(value: 5, child: Text('5 persons')),
                    DropdownMenuItem(value: 6, child: Text('6 persons')),
                  ],
                  initialValue: 2,
                ),
                const SizedBox(height: 16),

                // Price
                FormBuilderTextField(
                  name: 'price',
                  decoration: const InputDecoration(
                    labelText: 'Price per Night (₹) *',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 2500',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Price is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    if (double.parse(value) < 0) {
                      return 'Price cannot be negative';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Floor - Using Dropdown instead of Slider
                FormBuilderDropdown<int>(
                  name: 'floor',
                  decoration: const InputDecoration(
                    labelText: 'Floor',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Ground Floor')),
                    DropdownMenuItem(value: 2, child: Text('1st Floor')),
                    DropdownMenuItem(value: 3, child: Text('2nd Floor')),
                    DropdownMenuItem(value: 4, child: Text('3rd Floor')),
                    DropdownMenuItem(value: 5, child: Text('4th Floor')),
                    DropdownMenuItem(value: 6, child: Text('5th Floor')),
                    DropdownMenuItem(value: 7, child: Text('6th Floor')),
                    DropdownMenuItem(value: 8, child: Text('7th Floor')),
                    DropdownMenuItem(value: 9, child: Text('8th Floor')),
                    DropdownMenuItem(value: 10, child: Text('9th Floor')),
                  ],
                  initialValue: 1,
                ),
                const SizedBox(height: 16),

                // Status
                FormBuilderDropdown<int>(
                  name: 'status_id',
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info),
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.roomStatus.entries.map<DropdownMenuItem<int>>((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Status is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Preview Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Room Preview',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPreview(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (roomState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      roomState.error!,
                      style: const TextStyle(color: AppTheme.errorColor),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Submit Button
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(
                    _isEditing ? 'Update Room' : 'Create Room',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final roomNumber = _formKey.currentState?.value['room_number'] ?? 'XXX';
    final typeId = _formKey.currentState?.value['type_id'] ?? 1;
    final typeName = _roomTypes.firstWhere((t) => t['id'] == typeId)['name'] as String;
    final capacity = _formKey.currentState?.value['capacity'] ?? 2;
    final price = _formKey.currentState?.value['price'] ?? '0';
    final floor = _formKey.currentState?.value['floor'] ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                roomNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              typeName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.person, size: 16),
            const SizedBox(width: 4),
            Text('Capacity: $capacity persons'),
            const SizedBox(width: 16),
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 4),
            Text('Floor: ${floor == 1 ? 'Ground' : floor - 1}${floor == 1 ? '' : floor == 2 ? 'st' : floor == 3 ? 'rd' : 'th'} Floor'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '₹${double.tryParse(price.toString())?.toStringAsFixed(0) ?? '0'}/night',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = Map<String, dynamic>.from(_formKey.currentState!.value);
      final businessId = ref.read(authProvider).user?.businessId ?? 1;
      
      data['business_id'] = businessId;
      data['price'] = double.parse(data['price'].toString());

      bool success;
      if (_isEditing) {
        success = await ref.read(roomProvider.notifier).updateRoom(
          widget.roomId!,
          data,
        );
      } else {
        success = await ref.read(roomProvider.notifier).createRoom(data);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Room updated successfully' : 'Room created successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }
}