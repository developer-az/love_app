import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/widgets/memory_photo.dart';
import 'package:uuid/uuid.dart';

class AddMemoryScreen extends StatefulWidget {
  final MemoryService memoryService;
  final Memory? existingMemory;

  const AddMemoryScreen({
    super.key,
    required this.memoryService,
    this.existingMemory,
  });

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _pickedImage;
  bool _isLoading = false;
  bool _isPickingImage = false;

  bool get _isEditing => widget.existingMemory != null;

  String? get _previewImageUrl {
    if (_pickedImage != null && _pickedImage!.isNotEmpty) return _pickedImage;
    final url = _imageUrlController.text.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return null;
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMemory;
    if (existing != null) {
      _titleController.text = existing.title;
      _descriptionController.text = existing.description;
      _locationController.text = existing.location;
      _selectedDate = existing.date;
      if (existing.imageUrl.startsWith('data:image')) {
        _pickedImage = existing.imageUrl;
      } else if (existing.imageUrl.startsWith('http')) {
        _imageUrlController.text = existing.imageUrl;
      }
    }
    _imageUrlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(_onUrlChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 60,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return;
      final mime = file.mimeType ?? 'image/jpeg';
      setState(() {
        _pickedImage = 'data:$mime;base64,${base64Encode(bytes)}';
        _imageUrlController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not pick image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _clearPhoto() {
    setState(() {
      _pickedImage = null;
      _imageUrlController.clear();
    });
  }

  Future<void> _saveMemory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final existing = widget.existingMemory;
      final typedUrl = _imageUrlController.text.trim();
      final imageUrl = _pickedImage ?? typedUrl;

      final memory = Memory(
        id: existing?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        date: _selectedDate,
        location: _locationController.text.trim(),
      );

      if (existing == null) {
        await widget.memoryService.addMemory(memory);
      } else {
        await widget.memoryService.updateMemory(memory);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Memory saved successfully!'
                : 'Memory updated successfully!',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving memory: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: Text(_isEditing ? 'Edit Memory' : 'Add New Memory'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _buildLabeledField(
                    label: 'Title',
                    icon: Icons.title,
                    child: _buildTextField(
                      controller: _titleController,
                      hintText: 'Give your memory a beautiful title...',
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabeledField(
                    label: 'Story',
                    icon: Icons.auto_stories,
                    child: _buildTextField(
                      controller: _descriptionController,
                      hintText: 'Tell the story behind this special moment...',
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabeledField(
                    label: 'Location',
                    icon: Icons.location_on,
                    child: _buildTextField(
                      controller: _locationController,
                      hintText: 'Where did this happen?',
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabeledField(
                    label: 'Date',
                    icon: Icons.calendar_today,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  DateFormat('MMMM d, yyyy')
                                      .format(_selectedDate),
                                  style: AppTheme.bodyStyle.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppTheme.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabeledField(
                    label: 'Photo',
                    icon: Icons.photo,
                    child: _buildPhotoPicker(),
                  ),
                ],
              ),
            ),
          ),
          _buildSaveBar(),
        ],
      ),
    );
  }

  Widget _buildSaveBar() {
    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: AppTheme.gradientButtonDecoration,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMemory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isEditing ? 'Update Memory' : 'Save Memory',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    final preview = _previewImageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (preview != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MemoryPhoto(imageUrl: preview, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Remove photo',
                        onPressed: _clearPhoto,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isPickingImage
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 20),
                label: Text(_isPickingImage ? 'Loading...' : 'Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isPickingImage
                    ? null
                    : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined, size: 20),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_pickedImage == null) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _imageUrlController,
            hintText: 'Or paste an image URL (optional)',
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),
        ],
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: AppTheme.textFieldDecoration.copyWith(
        hintText: hintText,
        hintStyle: AppTheme.captionStyle.copyWith(color: Colors.grey[500]),
      ),
      style: AppTheme.bodyStyle,
      maxLines: maxLines,
      minLines: maxLines > 1 ? 4 : 1,
      validator: validator,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      inputFormatters: maxLines == 1
          ? [FilteringTextInputFormatter.singleLineFormatter]
          : null,
    );
  }
}
