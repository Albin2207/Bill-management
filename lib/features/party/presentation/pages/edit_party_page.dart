import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/image_picker_widget.dart';
import '../providers/party_provider.dart';
import '../../domain/entities/party_entity.dart';
import '../../data/models/party_model.dart';

class EditPartyPage extends StatefulWidget {
  final PartyEntity party;

  const EditPartyPage({super.key, required this.party});

  @override
  State<EditPartyPage> createState() => _EditPartyPageState();
}

class _EditPartyPageState extends State<EditPartyPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _gstinController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _pincodeController;
  late TextEditingController _openingBalanceController;

  late PartyType _partyType;
  String? _selectedState;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.party.name);
    _phoneController = TextEditingController(text: widget.party.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.party.email ?? '');
    _gstinController = TextEditingController(text: widget.party.gstin ?? '');
    _addressController = TextEditingController(text: widget.party.address ?? '');
    _cityController = TextEditingController(text: widget.party.city ?? '');
    _pincodeController = TextEditingController(text: widget.party.pincode ?? '');
    _openingBalanceController = TextEditingController(
      text: widget.party.openingBalance.toString(),
    );
    _partyType = widget.party.partyType;
    _selectedState = widget.party.state;
    _imageUrl = widget.party.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _saveParty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final partyProvider = Provider.of<PartyProvider>(context, listen: false);

    final updatedParty = PartyModel(
      id: widget.party.id,
      userId: widget.party.userId,
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      gstin: _gstinController.text.trim().isEmpty
          ? null
          : _gstinController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      state: _selectedState,
      pincode: _pincodeController.text.trim().isEmpty
          ? null
          : _pincodeController.text.trim(),
      country: 'India',
      partyType: _partyType,
      openingBalance: double.tryParse(_openingBalanceController.text) ?? 0,
      imageUrl: _imageUrl,
      createdAt: widget.party.createdAt,
      updatedAt: DateTime.now(),
    );

    final success = await partyProvider.updateParty(updatedParty);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Party updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(partyProvider.errorMessage ?? 'Failed to update party'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Party'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Party Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Party Type *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<PartyType>(
                      segments: const [
                        ButtonSegment(
                          value: PartyType.customer,
                          label: Text('Customer'),
                          icon: Icon(Icons.person),
                        ),
                        ButtonSegment(
                          value: PartyType.vendor,
                          label: Text('Vendor'),
                          icon: Icon(Icons.store),
                        ),
                        ButtonSegment(
                          value: PartyType.both,
                          label: Text('Both'),
                          icon: Icon(Icons.people),
                        ),
                      ],
                      selected: {_partyType},
                      onSelectionChanged: (Set<PartyType> newSelection) {
                        setState(() {
                          _partyType = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Basic Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Party Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // GST Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GST Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gstinController,
                      decoration: const InputDecoration(
                        labelText: 'GSTIN',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                        hintText: '22AAAAA0000A1Z5',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 15,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Address Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                      isExpanded: true,
                      items: AppConstants.indianStates
                          .map((state) => DropdownMenuItem(
                                value: state,
                                child: Text(
                                  state,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pincodeController,
                      decoration: const InputDecoration(
                        labelText: 'Pincode',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pin_drop),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _openingBalanceController,
                      decoration: const InputDecoration(
                        labelText: 'Opening Balance',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance_wallet),
                        prefixText: '₹ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Party Image
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ImagePickerWidget(
                  label: 'Party Image/Logo',
                  currentImageUrl: _imageUrl,
                  onImageSelected: (url) {
                    setState(() {
                      _imageUrl = url;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            Consumer<PartyProvider>(
              builder: (context, partyProvider, child) {
                return ElevatedButton(
                  onPressed: partyProvider.isSaving ? null : _saveParty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: partyProvider.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Update Party',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

