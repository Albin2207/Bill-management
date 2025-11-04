import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/business_provider.dart';

class BusinessLogoPage extends StatefulWidget {
  const BusinessLogoPage({super.key});

  @override
  State<BusinessLogoPage> createState() => _BusinessLogoPageState();
}

class _BusinessLogoPageState extends State<BusinessLogoPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBusiness();
    });
  }

  void _loadBusiness() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    if (authProvider.user != null) {
      businessProvider.loadBusiness(authProvider.user!.uid);
    }
  }

  Future<void> _pickAndUploadLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      // Upload to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(
        imageFile: File(image.path),
        folder: 'business_logos',
      );

      if (!mounted) return;

      // Update business profile
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      final success = await businessProvider.updateLogo(imageUrl);

      setState(() => _isUploading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logo updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload logo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadSignature() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      // Upload to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(
        imageFile: File(image.path),
        folder: 'signatures',
      );

      if (!mounted) return;

      // Update business profile
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      final success = await businessProvider.updateSignature(imageUrl);

      setState(() => _isUploading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signature updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload signature: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Logo & Signature'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, businessProvider, child) {
          if (businessProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (businessProvider.business == null) {
            return const Center(child: Text('No business profile found'));
          }

          final business = businessProvider.business!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Logo Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Business Logo',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        if (business.logoUrl != null)
                          Image.network(
                            business.logoUrl!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.contain,
                          )
                        else
                          Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.business, size: 64, color: Colors.grey),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickAndUploadLogo,
                          icon: _isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload),
                          label: Text(business.logoUrl != null ? 'Change Logo' : 'Upload Logo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Signature Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Authorized Signature',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        if (business.signatureUrl != null)
                          Image.network(
                            business.signatureUrl!,
                            height: 100,
                            width: 200,
                            fit: BoxFit.contain,
                          )
                        else
                          Container(
                            height: 100,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.draw, size: 48, color: Colors.grey),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickAndUploadSignature,
                          icon: _isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload),
                          label: Text(business.signatureUrl != null ? 'Change Signature' : 'Upload Signature'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

