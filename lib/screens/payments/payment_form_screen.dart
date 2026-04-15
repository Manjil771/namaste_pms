import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import '../../providers/payment_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  final int? paymentId;
  const PaymentFormScreen({super.key, this.paymentId});

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditing = false;
  bool _isAdvance = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.paymentId != null;
    _loadData();
    if (_isEditing) {
      _loadPaymentData();
    }
  }

  Future<void> _loadData() async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;
    await ref.read(bookingProvider.notifier).fetchBookings(businessId);
  }

  Future<void> _loadPaymentData() async {
    await ref.read(paymentProvider.notifier).fetchPayments();
    final paymentState = ref.read(paymentProvider);
    final payment = paymentState.payments.firstWhere(
      (p) => p.id == widget.paymentId,
      orElse: () => throw Exception('Payment not found'),
    );

    _isAdvance = payment.isAdvance;
    _formKey.currentState?.patchValue({
      'booking_id': payment.bookingId,
      'amount': payment.amount,
      'payment_method': payment.paymentMethod,
      'paid_at': payment.paidAt,
      'status_id': payment.statusId,
      'is_advance': payment.isAdvance,
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final bookingState = ref.watch(bookingProvider);

    return LoadingOverlay(
      isLoading: paymentState.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Payment' : 'Record Payment'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Payment Type
                FormBuilderSwitch(
                  name: 'is_advance',
                  title: const Text('Advance Payment'),
                  onChanged: (value) {
                    setState(() {
                      _isAdvance = value ?? false;
                    });
                  },
                  activeColor: Colors.amber,
                ),
                const SizedBox(height: 16),

                // Booking Selection (if not advance)
                if (!_isAdvance)
                  FormBuilderDropdown<int>(
                    name: 'booking_id',
                    decoration: const InputDecoration(
                      labelText: 'Select Booking *',
                      prefixIcon: Icon(Icons.book_online),
                      border: OutlineInputBorder(),
                    ),
                    items: bookingState.bookings.map((booking) {
                      return DropdownMenuItem(
                        value: booking.id,
                        child: Text(
                          '${booking.guestName} - Room ${booking.roomNumber} (₹${booking.amount.toStringAsFixed(0)})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    validator: FormBuilderValidators.required(),
                  ),
                if (!_isAdvance) const SizedBox(height: 16),

                // Amount
                FormBuilderTextField(
                  name: 'amount',
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹) *',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
                    hintText: 'Enter payment amount',
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.min(1),
                  ]),
                ),
                const SizedBox(height: 16),

                // Payment Method
                FormBuilderDropdown<String>(
                  name: 'payment_method',
                  decoration: const InputDecoration(
                    labelText: 'Payment Method *',
                    prefixIcon: Icon(Icons.payment),
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.paymentMethods.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),

                // Payment Date
                FormBuilderDateTimePicker(
                  name: 'paid_at',
                  decoration: const InputDecoration(
                    labelText: 'Payment Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  inputType: InputType.date,
                  format: DateFormat('yyyy-MM-dd'),
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                  initialValue: DateTime.now(),
                  validator: FormBuilderValidators.required(),
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
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Pending')),
                    DropdownMenuItem(value: 2, child: Text('Completed')),
                    DropdownMenuItem(value: 3, child: Text('Failed')),
                    DropdownMenuItem(value: 4, child: Text('Refunded')),
                  ],
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 24),

                // Summary Card (for non-advance payments)
                if (!_isAdvance && _formKey.currentState?.value['booking_id'] != null)
                  _buildBookingSummary(_formKey.currentState!.value['booking_id'], bookingState),

                if (paymentState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      paymentState.error!,
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
                    _isEditing ? 'Update Payment' : 'Record Payment',
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

  Widget _buildBookingSummary(int? bookingId, BookingState bookingState) {
    if (bookingId == null) return const SizedBox.shrink();
    
    final booking = bookingState.bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => throw Exception('Booking not found'),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Guest', booking.guestName),
          _buildSummaryRow('Room', booking.roomNumber),
          _buildSummaryRow('Check-in', DateFormat('MMM d, yyyy').format(booking.checkIn)),
          _buildSummaryRow('Check-out', DateFormat('MMM d, yyyy').format(booking.checkOut)),
          _buildSummaryRow('Nights', '${booking.nights} nights'),
          const Divider(),
          _buildSummaryRow(
            'Total Amount',
            '₹${NumberFormat('#,##0').format(booking.amount)}',
            isBold: true,
          ),
          if (booking.advancePayment != null && booking.advancePayment! > 0)
            _buildSummaryRow(
              'Advance Paid',
              '₹${NumberFormat('#,##0').format(booking.advancePayment)}',
              color: Colors.amber,
            ),
          _buildSummaryRow(
            'Balance Due',
            '₹${NumberFormat('#,##0').format(booking.amount - (booking.advancePayment ?? 0))}',
            isBold: true,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
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
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = Map<String, dynamic>.from(_formKey.currentState!.value);
      final businessId = ref.read(authProvider).user?.businessId ?? 1;
      
      data['business_id'] = businessId;
      data['amount'] = double.parse(data['amount'].toString());
      data['paid_at'] = (data['paid_at'] as DateTime).toIso8601String();
      
      if (!_isAdvance) {
        data['is_advance'] = false;
      } else {
        data['is_advance'] = true;
        data['booking_id'] = null;
      }

      bool success;
      if (_isEditing) {
        success = await ref.read(paymentProvider.notifier).updatePayment(
          widget.paymentId!,
          data,
        );
      } else {
        success = await ref.read(paymentProvider.notifier).createPayment(data);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Payment updated successfully' : 'Payment recorded successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }
}