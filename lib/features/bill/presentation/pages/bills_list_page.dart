import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';

class BillsListPage extends StatelessWidget {
  const BillsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.createBill);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Bill'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt,
              size: 64,
              color: AppColors.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No bills yet',
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

