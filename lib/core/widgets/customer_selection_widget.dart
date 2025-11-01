import 'package:flutter/material.dart';
import '../../features/party/domain/entities/party_entity.dart';
import '../constants/app_colors.dart';

class CustomerSelectionWidget extends StatelessWidget {
  final PartyEntity? selectedCustomer;
  final List<PartyEntity> customers;
  final Function(PartyEntity?) onCustomerSelected;
  final VoidCallback onAddNew;

  const CustomerSelectionWidget({
    super.key,
    required this.selectedCustomer,
    required this.customers,
    required this.onCustomerSelected,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Customer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddNew,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (selectedCustomer != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        selectedCustomer!.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedCustomer!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (selectedCustomer!.phoneNumber != null)
                            Text(
                              selectedCustomer!.phoneNumber!,
                              style: TextStyle(
                                color: AppColors.onBackground.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          if (selectedCustomer!.gstin != null)
                            Text(
                              'GSTIN: ${selectedCustomer!.gstin}',
                              style: TextStyle(
                                color: AppColors.onBackground.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onCustomerSelected(null),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              )
            else
              InkWell(
                onTap: () => _showCustomerSelector(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to select customer',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCustomerSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Customer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text('No customers found'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                onAddNew();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Customer'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                customer.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(customer.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (customer.phoneNumber != null)
                                  Text(customer.phoneNumber!),
                                if (customer.gstin != null)
                                  Text('GSTIN: ${customer.gstin}'),
                              ],
                            ),
                            onTap: () {
                              onCustomerSelected(customer);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

