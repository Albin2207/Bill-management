import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PartiesListPage extends StatelessWidget {
  const PartiesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parties'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Party'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 64,
              color: AppColors.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No parties yet',
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

