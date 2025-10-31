import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CreateInvoicePage extends StatelessWidget {
  const CreateInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: const Center(
        child: Text('Invoice Creation - Coming Soon'),
      ),
    );
  }
}

