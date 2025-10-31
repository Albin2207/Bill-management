import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GstReturnsPage extends StatelessWidget {
  const GstReturnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Returns'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 64,
              color: AppColors.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'GST Returns - Coming Soon',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

