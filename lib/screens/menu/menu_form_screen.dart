import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/menu_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../config/theme.dart';

class MenuFormScreen extends ConsumerStatefulWidget {
  final int? itemId;
  const MenuFormScreen({super.key, this.itemId});

  @override
  ConsumerState<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends ConsumerState<MenuFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditing = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  final List<Map<String, dynamic>> _spiceLevels = [
    {'id': 1, 'name': 'Mild', 'icon': Icons.thermostat},
    {'id': 2, 'name': 'Medium', 'icon': Icons.thermostat_auto_outlined},
    {'id': 3, 'name': 'Hot', 'icon': Icons.thermostat_auto},
    {'id': 4, 'name': 'Extra Hot', 'icon': Icons.local_fire_department},
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.itemId != null;
    _loadData();
    if (_isEditing) {
      _loadMenuItemData();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      ref.read(menuProvider.notifier).fetchCategories(),
    ]);
  }

  Future<void> _loadMenuItemData() async {
    await ref.read(menuProvider.notifier).fetchFoodItems();
    final menuState = ref.read(menuProvider);
    final item = menuState.foodItems.firstWhere(
      (i) => i.id == widget.itemId,
      orElse: () => throw Exception('Item not found'),
    );

    _formKey.currentState?.patchValue({
      'name': item.name,
      'category_id': item.categoryId,
      'description': item.description,
      'price': item.price,
      'preparation_time': item.preparationTime,
      'spice_level_id': item.spiceLevelId,
      'is_available': item.isAvailable,
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);

    return LoadingOverlay(
      isLoading: menuState.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Menu Item' : 'Add Menu Item'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Picker
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload image',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'JPG, PNG, or GIF',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Item Name
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    prefixIcon: Icon(Icons.restaurant),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),

                // Category
                FormBuilderDropdown<int>(
                  name: 'category_id',
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: menuState.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),

                // Description
                FormBuilderTextField(
                  name: 'description',
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Price
                FormBuilderTextField(
                  name: 'price',
                  decoration: const InputDecoration(
                    labelText: 'Price (₹) *',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
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

                // Preparation Time - Using Dropdown instead of Slider for better UX
                FormBuilderDropdown<int>(
                  name: 'preparation_time',
                  decoration: const InputDecoration(
                    labelText: 'Preparation Time (minutes)',
                    prefixIcon: Icon(Icons.timer),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 minutes')),
                    DropdownMenuItem(value: 10, child: Text('10 minutes')),
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                    DropdownMenuItem(value: 20, child: Text('20 minutes')),
                    DropdownMenuItem(value: 25, child: Text('25 minutes')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                    DropdownMenuItem(value: 45, child: Text('45 minutes')),
                    DropdownMenuItem(value: 60, child: Text('60 minutes')),
                  ],
                  initialValue: 15,
                ),
                const SizedBox(height: 16),

                // Spice Level - Using Dropdown instead of Segmented for simplicity
                FormBuilderDropdown<int>(
                  name: 'spice_level_id',
                  decoration: const InputDecoration(
                    labelText: 'Spice Level',
                    prefixIcon: Icon(Icons.local_fire_department),
                    border: OutlineInputBorder(),
                  ),
                  items: _spiceLevels.map((level) {
                    return DropdownMenuItem<int>(
                      value: level['id'],
                      child: Row(
                        children: [
                          Icon(level['icon'], size: 20),
                          const SizedBox(width: 8),
                          Text(level['name']),
                        ],
                      ),
                    );
                  }).toList(),
                  initialValue: 1,
                ),
                const SizedBox(height: 16),

                // Available Switch
                FormBuilderSwitch(
                  name: 'is_available',
                  title: const Text('Item Available'),
                  initialValue: true,
                  activeColor: AppTheme.successColor,
                ),
                const SizedBox(height: 24),

                if (menuState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      menuState.error!,
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
                    _isEditing ? 'Update Item' : 'Create Item',
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
      data['price'] = double.parse(data['price'].toString());
      data['is_available'] = data['is_available'] ?? true;

      bool success;
      if (_isEditing) {
        success = await ref.read(menuProvider.notifier).updateFoodItem(
          widget.itemId!,
          data,
        );
      } else {
        success = await ref.read(menuProvider.notifier).createFoodItem(data);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Menu item updated successfully' : 'Menu item created successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }
}