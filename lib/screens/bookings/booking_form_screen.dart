import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/guest_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  final int? bookingId;
  final int? roomId;
  
  const BookingFormScreen({super.key, this.bookingId, this.roomId});

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditing = false;
  DateTime? _checkIn;
  DateTime? _checkOut;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.bookingId != null;
    _loadData();
  }
  
  Future<void> _loadData() async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;
    await Future.wait([
      ref.read(roomProvider.notifier).fetchRooms(businessId),
      ref.read(guestProvider.notifier).fetchGuests(),
    ]);
    
    if (_isEditing) {
      await ref.read(bookingProvider.notifier).fetchBookings(businessId);
      final bookingState = ref.read(bookingProvider);
      final booking = bookingState.bookings.firstWhere(
        (b) => b.id == widget.bookingId,
        orElse: () => throw Exception('Booking not found'),
      );
      
      _checkIn = booking.checkIn;
      _checkOut = booking.checkOut;
      
      _formKey.currentState?.patchValue({
        'room_id': booking.roomId,
        'guest_id': booking.guestId,
        'check_in': booking.checkIn,
        'check_out': booking.checkOut,
        'advance_payment': booking.advancePayment,
        'advance_date': booking.advanceDate,
        'advance_payment_method': booking.advancePaymentMethod,
      });
    } else if (widget.roomId != null) {
      _formKey.currentState?.patchValue({
        'room_id': widget.roomId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final roomState = ref.watch(roomProvider);
    final guestState = ref.watch(guestProvider);
    
    return LoadingOverlay(
      isLoading: bookingState.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Booking' : 'New Booking'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Room Selection
                FormBuilderDropdown<int>(
                  name: 'room_id',
                  decoration: const InputDecoration(
                    labelText: 'Select Room',
                    prefixIcon: Icon(Icons.meeting_room),
                    border: OutlineInputBorder(),
                  ),
                  items: roomState.rooms.map((room) {
                    return DropdownMenuItem(
                      value: room.id,
                      child: Text(
                        '${room.roomNumber} - ${room.roomTypeName} (₹${room.price}/night)',
                      ),
                    );
                  }).toList(),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) {
                    // Update amount based on room price
                    _updateAmount();
                  },
                ),
                const SizedBox(height: 16),
                
                // Guest Selection
                FormBuilderDropdown<int>(
                  name: 'guest_id',
                  decoration: const InputDecoration(
                    labelText: 'Select Guest',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  items: guestState.guests.map((guest) {
                    return DropdownMenuItem(
                      value: guest.id,
                      child: Text('${guest.name} - ${guest.phone}'),
                    );
                  }).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                
                // Or create new guest
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(context, '/guests/form');
                    if (result == true) {
                      await ref.read(guestProvider.notifier).fetchGuests();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Guest'),
                ),
                const SizedBox(height: 16),
                
                // Check-in Date
                FormBuilderDateTimePicker(
                  name: 'check_in',
                  decoration: const InputDecoration(
                    labelText: 'Check-in Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  inputType: InputType.date,
                  format: DateFormat('yyyy-MM-dd'),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onChanged: (value) {
                    _checkIn = value;
                    _updateAmount();
                  },
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                
                // Check-out Date
                FormBuilderDateTimePicker(
                  name: 'check_out',
                  decoration: const InputDecoration(
                    labelText: 'Check-out Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  inputType: InputType.date,
                  format: DateFormat('yyyy-MM-dd'),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onChanged: (value) {
                    _checkOut = value;
                    _updateAmount();
                  },
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                
                // Nights and Amount Display
                if (_checkIn != null && _checkOut != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Nights',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_checkOut!.difference(_checkIn!).inDays} nights',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${NumberFormat('#,##0').format(_calculateAmount())}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Advance Payment Section
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Advance Payment (Optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                // Advance Amount
                FormBuilderTextField(
                  name: 'advance_payment',
                  decoration: const InputDecoration(
                    labelText: 'Advance Amount',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // Advance Date
                FormBuilderDateTimePicker(
                  name: 'advance_date',
                  decoration: const InputDecoration(
                    labelText: 'Advance Payment Date',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                  inputType: InputType.date,
                  format: DateFormat('yyyy-MM-dd'),
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                ),
                const SizedBox(height: 16),
                
                // Payment Method
                FormBuilderDropdown<int>(
                  name: 'advance_payment_method',
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    prefixIcon: Icon(Icons.payment),
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.paymentMethods.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                // Error Message
                if (bookingState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      bookingState.error!,
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
                    _isEditing ? 'Update Booking' : 'Create Booking',
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
  
  void _updateAmount() {
    setState(() {});
  }
  
  double _calculateAmount() {
    if (_checkIn == null || _checkOut == null) return 0;
    
    final roomId = _formKey.currentState?.value['room_id'];
    if (roomId == null) return 0;
    
    final roomState = ref.read(roomProvider);
    final room = roomState.rooms.firstWhere((r) => r.id == roomId, orElse: () => throw Exception('Room not found'));
    
    final nights = _checkOut!.difference(_checkIn!).inDays;
    return room.price * nights;
  }
  
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = Map<String, dynamic>.from(_formKey.currentState!.value);
      final businessId = ref.read(authProvider).user?.businessId ?? 1;
      
      // Remove fields that are computed by server
      data.remove('nights');
      data.remove('amount');
      
      // Add check-in and check-out as ISO strings
      data['check_in'] = (data['check_in'] as DateTime).toIso8601String();
      data['check_out'] = (data['check_out'] as DateTime).toIso8601String();
      
      if (data['advance_date'] != null) {
        data['advance_date'] = (data['advance_date'] as DateTime).toIso8601String();
      }
      
      bool success;
      if (_isEditing) {
        success = await ref.read(bookingProvider.notifier).updateBooking(
          businessId,
          widget.bookingId!,
          data,
        );
      } else {
        success = await ref.read(bookingProvider.notifier).createBooking(
          businessId,
          data,
        );
      }
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Booking updated successfully' : 'Booking created successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}