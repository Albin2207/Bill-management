import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/invoice_entity.dart';

class InvoiceActionsWidget extends StatelessWidget {
  final InvoiceEntity invoice;
  final VoidCallback onShare;
  final VoidCallback onDownloadPDF;
  final VoidCallback onPrint;
  final VoidCallback? onDuplicate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onEmail;

  const InvoiceActionsWidget({
    super.key,
    required this.invoice,
    required this.onShare,
    required this.onDownloadPDF,
    required this.onPrint,
    this.onDuplicate,
    this.onEdit,
    this.onDelete,
    this.onWhatsApp,
    this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary Actions
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  color: Colors.blue,
                  onTap: onShare,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF',
                  color: Colors.red,
                  onTap: onDownloadPDF,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.print,
                  label: 'Print',
                  color: Colors.purple,
                  onTap: onPrint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Secondary Actions
          Row(
            children: [
              if (onWhatsApp != null)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.chat,
                    label: 'WhatsApp',
                    color: Colors.green,
                    onTap: onWhatsApp!,
                  ),
                ),
              if (onWhatsApp != null && onEmail != null)
                const SizedBox(width: 12),
              if (onEmail != null)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.email,
                    label: 'Email',
                    color: Colors.orange,
                    onTap: onEmail!,
                  ),
                ),
              if (onDuplicate != null) ...[
                if (onWhatsApp != null || onEmail != null)
                  const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.copy,
                    label: 'Duplicate',
                    color: Colors.teal,
                    onTap: onDuplicate!,
                  ),
                ),
              ],
            ],
          ),
          
          // Destructive Actions
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onEdit != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: 12),
                if (onDelete != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

