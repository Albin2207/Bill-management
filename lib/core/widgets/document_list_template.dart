import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DocumentListTemplate extends StatelessWidget {
  final String title;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final String createButtonLabel;
  final VoidCallback onCreatePressed;
  final List<Map<String, dynamic>> documents;
  final Widget Function(Map<String, dynamic>)? itemBuilder;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onFilterPressed;

  const DocumentListTemplate({
    super.key,
    required this.title,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.createButtonLabel,
    required this.onCreatePressed,
    required this.documents,
    this.itemBuilder,
    this.onSearchPressed,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          if (onSearchPressed != null)
            IconButton(
              onPressed: onSearchPressed,
              icon: const Icon(Icons.search),
            ),
          if (onFilterPressed != null)
            IconButton(
              onPressed: onFilterPressed,
              icon: const Icon(Icons.filter_list),
            ),
        ],
      ),
      body: documents.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                if (itemBuilder != null) {
                  return itemBuilder!(documents[index]);
                }
                return _buildDefaultCard(documents[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onCreatePressed,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(createButtonLabel),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            emptyIcon,
            size: 120,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            emptyTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            emptySubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onCreatePressed,
            icon: const Icon(Icons.add),
            label: Text(createButtonLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCard(Map<String, dynamic> doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(doc['title'] ?? 'Document'),
        subtitle: Text(doc['subtitle'] ?? ''),
        trailing: Text(
          doc['amount'] ?? '₹0.00',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

