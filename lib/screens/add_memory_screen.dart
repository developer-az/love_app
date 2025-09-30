import 'package:flutter/material.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class AddMemoryScreen extends StatefulWidget {
  final MemoryService memoryService;

  const AddMemoryScreen({super.key, required this.memoryService});

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
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMemory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final memory = Memory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isEmpty
              ? 'https://picsum.photos/600/800?random=${DateTime.now().millisecondsSinceEpoch}'
              : _imageUrlController.text.trim(),
          date: _selectedDate,
          location: _locationController.text.trim(),
        );

        await widget.memoryService.addMemory(memory);
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Memory saved successfully!',
                    style: AppTheme.bodyStyle.copyWith(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error saving memory: $e',
                style: AppTheme.bodyStyle.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        color: AppTheme.textColor,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Add New Memory',
                          style: AppTheme.titleStyle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.3, end: 0),
              
              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title Field
                        _buildSectionHeader('Title', Icons.title),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _titleController,
                          hintText: 'Give your memory a beautiful title...',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ).animate(delay: const Duration(milliseconds: 100))
                            .fadeIn().slideX(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 24),
                        
                        // Description Field
                        _buildSectionHeader('Story', Icons.auto_stories),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descriptionController,
                          hintText: 'Tell the story behind this special moment...',
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ).animate(delay: const Duration(milliseconds: 200))
                            .fadeIn().slideX(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 24),
                        
                        // Location Field
                        _buildSectionHeader('Location', Icons.location_on),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _locationController,
                          hintText: 'Where did this happen?',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a location';
                            }
                            return null;
                          },
                        ).animate(delay: const Duration(milliseconds: 300))
                            .fadeIn().slideX(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 24),
                        
                        // Date Selector
                        _buildSectionHeader('Date', Icons.calendar_today),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected Date',
                                        style: AppTheme.captionStyle,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat('MMMM d, yyyy').format(_selectedDate),
                                        style: AppTheme.bodyStyle.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppTheme.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ).animate(delay: const Duration(milliseconds: 400))
                            .fadeIn().slideX(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 24),
                        
                        // Image URL Field
                        _buildSectionHeader('Photo (Optional)', Icons.photo),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _imageUrlController,
                          hintText: 'Enter image URL or leave blank for random photo',
                        ).animate(delay: const Duration(milliseconds: 500))
                            .fadeIn().slideX(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 40),
                        
                        // Save Button
                        Container(
                          decoration: AppTheme.gradientButtonDecoration,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveMemory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Save Memory',
                                    style: AppTheme.bodyStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        ).animate(delay: const Duration(milliseconds: 600))
                            .fadeIn().slideY(begin: 0.3, end: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.subheadingStyle.copyWith(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: AppTheme.textFieldDecoration.copyWith(
          hintText: hintText,
          hintStyle: AppTheme.captionStyle.copyWith(
            color: Colors.grey[500],
          ),
        ),
        style: AppTheme.bodyStyle,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }
}
