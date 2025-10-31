import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CreateBillPage extends StatelessWidget {
  const CreateBillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Bill'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: const Center(
        child: Text('Bill Creation - Coming Soon'),
      ),
    );
  }
}

