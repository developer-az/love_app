import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/utils/haptics.dart';
import 'package:my_special_app/utils/memory_dates.dart';
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
  static const _titleLimit = 80;
  static const _storyLimit = 2000;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _pickedImage;
  bool _isLoading = false;
  bool _isPickingImage = false;
  bool _allowPop = false;

  bool get _isEditing => widget.existingMemory != null;

  String? get _previewImageUrl {
    if (_pickedImage != null && _pickedImage!.isNotEmpty) return _pickedImage;
    final url = _imageUrlController.text.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return null;
  }

  bool get _isDirty {
    final existing = widget.existingMemory;
    if (existing == null) {
      return _titleController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _locationController.text.trim().isNotEmpty ||
          _imageUrlController.text.trim().isNotEmpty ||
          _pickedImage != null;
    }
    final existingPicked =
        existing.imageUrl.startsWith('data:image') ? existing.imageUrl : null;
    final existingUrl =
        existing.imageUrl.startsWith('http') ? existing.imageUrl : '';
    return _titleController.text.trim() != existing.title ||
        _descriptionController.text.trim() != existing.description ||
        _locationController.text.trim() != existing.location ||
        _selectedDate != existing.date ||
        _pickedImage != existingPicked ||
        _imageUrlController.text.trim() != existingUrl;
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
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _locationController.addListener(_onFormChanged);
    _imageUrlController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_onFormChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_onFormChanged)
      ..dispose();
    _locationController
      ..removeListener(_onFormChanged)
      ..dispose();
    _imageUrlController
      ..removeListener(_onFormChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _leave([Object? result]) async {
    _allowPop = true;
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  Future<void> _confirmPop(bool didPop) async {
    if (didPop) return;
    if (!_isDirty) {
      await _leave();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved edits. If you leave now, they will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      await _leave();
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
          backgroundColor: Theme.of(context).colorScheme.error,
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
        isFavorite: existing?.isFavorite ?? false,
      );

      if (existing == null) {
        await widget.memoryService.addMemory(memory);
      } else {
        await widget.memoryService.updateMemory(memory);
      }

      if (!mounted) return;
      mediumHaptic();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Memory saved successfully!'
                : 'Memory updated successfully!',
          ),
        ),
      );
      await _leave(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving memory: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_isDirty || _allowPop,
      onPopInvokedWithResult: (didPop, _) => _confirmPop(didPop),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Memory' : 'Add New Memory'),
          ),
          body: Column(
            children: [
              Expanded(
                child: AutofillGroup(
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
                          counter:
                              '${_titleController.text.characters.length}/$_titleLimit',
                          child: _buildTextField(
                            controller: _titleController,
                            hintText: 'Give your memory a beautiful title...',
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            autofillHints: const [AutofillHints.name],
                            maxLength: _titleLimit,
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
                          counter:
                              '${_descriptionController.text.characters.length}/$_storyLimit',
                          child: _buildTextField(
                            controller: _descriptionController,
                            hintText:
                                'Tell the story behind this special moment...',
                            maxLines: 5,
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: _storyLimit,
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
                            autofillHints: const [AutofillHints.addressCity],
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
                            color: Theme.of(context).cardTheme.color ??
                                colorScheme.surface,
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
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        MemoryDates.full(_selectedDate),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: colorScheme.onSurfaceVariant,
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
              ),
              _buildSaveBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveBar() {
    return Material(
      color: Theme.of(context).cardTheme.color ??
          Theme.of(context).colorScheme.surface,
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
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
    final colorScheme = Theme.of(context).colorScheme;

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
                  foregroundColor: colorScheme.primary,
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
                  foregroundColor: colorScheme.primary,
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
            autofillHints: const [AutofillHints.url],
          ),
        ],
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    required IconData icon,
    required Widget child,
    String? counter,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (counter != null)
              Text(
                counter,
                style: Theme.of(context).textTheme.bodyMedium,
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
    int? maxLength,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText, counterText: ''),
      style: Theme.of(context).textTheme.bodyLarge,
      maxLines: maxLines,
      minLines: maxLines > 1 ? 4 : 1,
      maxLength: maxLength,
      validator: validator,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      inputFormatters: maxLines == 1
          ? [FilteringTextInputFormatter.singleLineFormatter]
          : null,
    );
  }
}
