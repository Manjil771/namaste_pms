import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../providers/guest_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../config/theme.dart';

class GuestFormScreen extends ConsumerStatefulWidget {
  final int? guestId;
  const GuestFormScreen({super.key, this.guestId});

  @override
  ConsumerState<GuestFormScreen> createState() => _GuestFormScreenState();
}

class _GuestFormScreenState extends ConsumerState<GuestFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.guestId != null;
    if (_isEditing) {
      _loadGuestData();
    }
  }
  
  Future<void> _loadGuestData() async {
    await ref.read(guestProvider.notifier).fetchGuests();
    final guestState = ref.read(guestProvider);
    final guest = guestState.guests.firstWhere(
      (g) => g.id == widget.guestId,
      orElse: () => throw Exception('Guest not found'),
    );
    
    _formKey.currentState?.patchValue({
      'name': guest.name,
      'phone': guest.phone,
    });
  }

  @override
  Widget build(BuildContext context) {
    final guestState = ref.watch(guestProvider);
    
    return LoadingOverlay(
      isLoading: guestState.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Guest' : 'Add Guest'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name Field
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                
                // Phone Field - FIXED: Custom validator instead of match
                FormBuilderTextField(
                  name: 'phone',
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    hintText: '10-digit mobile number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Optional: Add Email Field
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Optional: Add Address Field
                FormBuilderTextField(
                  name: 'address',
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                
                if (guestState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      guestState.error!,
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
                    _isEditing ? 'Update Guest' : 'Create Guest',
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
  
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = Map<String, dynamic>.from(_formKey.currentState!.value);
      final businessId = ref.read(authProvider).user?.businessId ?? 1;
      
      data['business_id'] = businessId;
      data['verify_id'] = 1;
      data['status_id'] = 1;
      
      // Remove empty email and address if not provided
      if (data['email'] == null || data['email'].toString().isEmpty) {
        data.remove('email');
      }
      if (data['address'] == null || data['address'].toString().isEmpty) {
        data.remove('address');
      }
      
      bool success;
      if (_isEditing) {
        success = await ref.read(guestProvider.notifier).updateGuest(
          widget.guestId!,
          data,
        );
      } else {
        success = await ref.read(guestProvider.notifier).createGuest(data);
      }
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Guest updated successfully' : 'Guest created successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }
}