import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../providers/staff_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lookup_provider.dart' hide staffLookupProvider;
import '../../widgets/common/loading_overlay.dart';
import '../../config/theme.dart';

class StaffFormScreen extends ConsumerStatefulWidget {
  final int? staffId;
  const StaffFormScreen({super.key, this.staffId});

  @override
  ConsumerState<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends ConsumerState<StaffFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.staffId != null;
    // Use addPostFrameCallback to safely call ref after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadLookupData();
      if (_isEditing) {
        await _loadStaffData();
      }
    });
  }

  Future<void> _loadLookupData() async {
    await ref.read(staffLookupProvider.notifier).fetchLookupData();
  }

  Future<void> _loadStaffData() async {
    final businessId = ref.read(authProvider).user?.businessId ?? 1;
    await ref.read(staffProvider.notifier).fetchStaff(businessId);

    if (!mounted) return;

    final staffState = ref.read(staffProvider);
    try {
      final staff = staffState.staff.firstWhere(
        (s) => s.id == widget.staffId,
      );

      // Wait for form to be ready before patching
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.patchValue({
          'name': staff.name,
          'phone': staff.phone,
          'role': staff.role,
          'shift': staff.shift,
          'status': staff.status,
        });
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Staff member not found'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffProvider);
    final lookupState = ref.watch(staffLookupProvider);

    return LoadingOverlay(
      isLoading: staffState.isLoading || lookupState.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Staff' : 'Add Staff'),
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

                // Phone Field
               FormBuilderTextField(
  name: 'phone',
  decoration: const InputDecoration(
    labelText: 'Phone Number',
    prefixIcon: Icon(Icons.phone),
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.phone,
  validator: FormBuilderValidators.compose([
  FormBuilderValidators.required(),
  (value) {
    if (value == null || !RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Enter valid 10-digit number';
    }
    return null;
  },
]),
),
                const SizedBox(height: 16),

                // Role Dropdown
                FormBuilderDropdown<int>(
                  name: 'role',
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                  items: lookupState.roles.map((role) {
                    return DropdownMenuItem<int>(
                      value: role['id'] as int,
                      child: Text(role['name'] as String),
                    );
                  }).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),

                // Shift Dropdown
                FormBuilderDropdown<int>(
                  name: 'shift',
                  decoration: const InputDecoration(
                    labelText: 'Shift',
                    prefixIcon: Icon(Icons.schedule),
                    border: OutlineInputBorder(),
                  ),
                  items: lookupState.shifts.map((shift) {
                    return DropdownMenuItem<int>(
                      value: shift['id'] as int,
                      child: Text(shift['name'] as String),
                    );
                  }).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                FormBuilderDropdown<int>(
                  name: 'status',
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                  items: lookupState.staffStatuses.map((status) {
                    return DropdownMenuItem<int>(
                      value: status['id'] as int,
                      child: Text(status['name'] as String),
                    );
                  }).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),

                // Password Field (only for new staff)
                if (!_isEditing) ...[
                  FormBuilderTextField(
                    name: 'password',
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: _obscurePassword,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(8),
                    ]),
                  ),
                  const SizedBox(height: 24),
                ],

                // Error Message
                if (staffState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      staffState.error!,
                      style: const TextStyle(color: AppTheme.errorColor),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Lookup Error Message
                if (lookupState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      lookupState.error!,
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
                    _isEditing ? 'Update Staff' : 'Create Staff',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

      bool success;
      if (_isEditing) {
        success = await ref.read(staffProvider.notifier).updateStaff(
              businessId,
              widget.staffId!,
              data,
            );
      } else {
        success = await ref.read(staffProvider.notifier).createStaff(
              businessId,
              data,
            );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Staff updated successfully'
                  : 'Staff created successfully',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}