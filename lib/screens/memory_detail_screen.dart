import 'package:flutter/material.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/models/memory.dart';

class MemoryDetailScreen extends StatelessWidget {
  final Memory memory;

  const MemoryDetailScreen({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              memory.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(memory.title, style: AppTheme.headingStyle),
                  const SizedBox(height: 8),
                  Text(
                    '${memory.date.day}/${memory.date.month}/${memory.date.year}',
                    style: AppTheme.bodyStyle.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Location: ${memory.location}',
                    style: AppTheme.subheadingStyle,
                  ),
                  const SizedBox(height: 16),
                  Text(memory.description, style: AppTheme.bodyStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
