import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';

class InvoicesListPage extends StatelessWidget {
  const InvoicesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.createInvoice);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No invoices yet',
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

