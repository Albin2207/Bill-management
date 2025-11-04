import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../../domain/entities/invoice_entity.dart';
import 'create_debit_note_page.dart';
import 'invoice_detail_page.dart';

class DebitNotesListPage extends StatefulWidget {
  const DebitNotesListPage({super.key});

  @override
  State<DebitNotesListPage> createState() => _DebitNotesListPageState();
}

class _DebitNotesListPageState extends State<DebitNotesListPage> {
  PaymentStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDebitNotes();
    });
  }

  void _loadDebitNotes() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
    }
  }
  
  List<InvoiceEntity> _getFilteredDebitNotes(List<InvoiceEntity> invoices) {
    final debitNotes = invoices.where((i) => i.invoiceType == InvoiceType.debitNote).toList();
    
    if (_selectedFilter == null) return debitNotes;
    return debitNotes.where((i) => i.paymentStatus == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final filteredDebitNotes = _getFilteredDebitNotes(invoiceProvider.invoices);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debit Notes'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null, invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.debitNote).length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Paid',
                    PaymentStatus.paid,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.debitNote && i.paymentStatus == PaymentStatus.paid).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    PaymentStatus.pending,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.debitNote && i.paymentStatus == PaymentStatus.pending).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Unpaid',
                    PaymentStatus.unpaid,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.debitNote && i.paymentStatus == PaymentStatus.unpaid).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Cancelled',
                    PaymentStatus.cancelled,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.debitNote && i.paymentStatus == PaymentStatus.cancelled).length,
                  ),
                ],
              ),
            ),
          ),
          
          // Debit Notes List
          Expanded(
            child: invoiceProvider.status == InvoiceListStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : invoiceProvider.status == InvoiceListStatus.error
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(invoiceProvider.errorMessage ?? 'Error loading debit notes'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDebitNotes,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredDebitNotes.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredDebitNotes.length,
                            itemBuilder: (context, index) {
                              final debitNote = filteredDebitNotes[index];
                              return _buildDebitNoteCard(debitNote);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'debit_notes_fab',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateDebitNotePage()),
          );
          if (result == true) {
            _loadDebitNotes();
          }
        },
        backgroundColor: Colors.pink,
        icon: const Icon(Icons.add),
        label: const Text('Create Debit Note'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Debit Notes Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Issue debit notes for returns to suppliers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateDebitNotePage()),
              );
              if (result == true) {
                _loadDebitNotes();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Debit Note'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebitNoteCard(InvoiceEntity debitNote) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceDetailPage(invoice: debitNote),
            ),
          ).then((_) => _loadDebitNotes());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      debitNote.invoiceNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(debitNote.paymentStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      debitNote.paymentStatus.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.store, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    debitNote.partyName,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(debitNote.invoiceDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '-₹${debitNote.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, PaymentStatus? status, int count) {
    final isSelected = _selectedFilter == status;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? status : null;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.unpaid:
      case PaymentStatus.pending:
        return Colors.red;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }
}


