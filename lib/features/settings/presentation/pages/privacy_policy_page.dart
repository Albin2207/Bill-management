import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly to us when you:\n'
              '• Create an account\n'
              '• Use our billing and GST management features\n'
              '• Upload business documents and logos\n'
              '• Contact our support team\n\n'
              'This includes your business details, GSTIN, contact information, '
              'invoices, payment records, and other data you enter into the app.',
            ),
            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to:\n'
              '• Provide, maintain, and improve our services\n'
              '• Generate invoices, receipts, and reports\n'
              '• Calculate GST and maintain compliance records\n'
              '• Sync your data across devices\n'
              '• Send you important updates about the service\n'
              '• Respond to your support requests',
            ),
            _buildSection(
              'Data Storage and Security',
              'Your data is stored securely on Firebase Cloud Services with:\n'
              '• End-to-end encryption in transit\n'
              '• Secure cloud storage with restricted access\n'
              '• Regular security audits and updates\n'
              '• Biometric authentication for app access\n'
              '• Automatic backups to prevent data loss\n\n'
              'We implement industry-standard security measures to protect '
              'your information from unauthorized access, alteration, or disclosure.',
            ),
            _buildSection(
              'Data Sharing',
              'We do NOT sell or rent your personal information to third parties. '
              'Your data may be accessed by:\n'
              '• Firebase Cloud Services (Google) - for data storage and authentication\n'
              '• Cloudinary - for image storage (business logos, signatures)\n\n'
              'These service providers are bound by strict data protection agreements.',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to:\n'
              '• Access your personal data stored in the app\n'
              '• Update or correct your information at any time\n'
              '• Delete your account and all associated data\n'
              '• Export your data in PDF or other formats\n'
              '• Opt-out of non-essential communications',
            ),
            _buildSection(
              'Data Retention',
              'We retain your data for as long as your account is active. '
              'When you delete your account:\n'
              '• All personal data is permanently deleted within 30 days\n'
              '• Backups are removed from all servers\n'
              '• Some data may be retained for legal compliance (e.g., GST records)',
            ),
            _buildSection(
              'Children\'s Privacy',
              'Our service is not intended for users under the age of 18. '
              'We do not knowingly collect information from children. '
              'If you believe we have collected data from a minor, please contact us immediately.',
            ),
            _buildSection(
              'Cookies and Tracking',
              'We use minimal tracking for:\n'
              '• Analytics to improve app performance\n'
              '• Authentication sessions\n'
              '• Crash reporting and bug fixes\n\n'
              'You can control analytics through your device settings.',
            ),
            _buildSection(
              'Changes to Privacy Policy',
              'We may update this Privacy Policy from time to time. '
              'We will notify you of any material changes via:\n'
              '• In-app notification\n'
              '• Email to your registered address\n'
              '• Update notice in the app\n\n'
              'Continued use of the app after changes indicates acceptance.',
            ),
            _buildSection(
              'Contact Us',
              'If you have questions or concerns about this Privacy Policy or '
              'your data, please contact us:\n\n'
              '📧 Email: support@growblic.com\n'
              '📱 WhatsApp: +91-XXXXXXXXXX\n'
              '🌐 Website: www.growblic.com',
            ),
            const SizedBox(height: 16),
            _buildFooter(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip, color: AppColors.primary, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your Privacy Matters',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'We are committed to protecting your personal information and '
            'your right to privacy. This policy explains how we collect, '
            'use, and safeguard your data.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Last Updated: November 5, 2025',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onBackground.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'By using Billing Management app, you agree to this Privacy Policy.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

