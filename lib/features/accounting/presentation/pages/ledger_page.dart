import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../invoice/presentation/providers/invoice_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../party/presentation/providers/party_provider.dart';
import '../providers/accounting_provider.dart';

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key});

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  String? _selectedPartyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final partyProvider = Provider.of<PartyProvider>(context, listen: false);

    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
      paymentProvider.loadAllPayments(userId);
      partyProvider.loadParties(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final partyProvider = Provider.of<PartyProvider>(context);
    final accountingProvider = Provider.of<AccountingProvider>(context);

    final parties = partyProvider.parties;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Ledger'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Column(
        children: [
          // Party Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: DropdownButtonFormField<String>(
              value: _selectedPartyId,
              decoration: InputDecoration(
                labelText: 'Select Party',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2C)
                    : Colors.white,
              ),
              dropdownColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2C2C2C)
                  : Colors.white,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
              hint: Text(
                'Select a party to view ledger',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
              items: parties.map((party) {
                return DropdownMenuItem(
                  value: party.id,
                  child: Text(party.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedPartyId = value);
              },
            ),
          ),

          // Ledger Content
          Expanded(
            child: _selectedPartyId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a party to view ledger',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildLedgerTable(
                    _selectedPartyId!,
                    invoiceProvider,
                    paymentProvider,
                    partyProvider,
                    accountingProvider,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerTable(
    String partyId,
    InvoiceProvider invoiceProvider,
    PaymentProvider paymentProvider,
    PartyProvider partyProvider,
    AccountingProvider accountingProvider,
  ) {
    final party = partyProvider.parties.firstWhere((p) => p.id == partyId);
    final entries = accountingProvider.getPartyLedger(
      partyId,
      invoiceProvider.invoices,
      paymentProvider.allPayments,
      party.openingBalance,
    );

    if (entries.isEmpty) {
      return const Center(child: Text('No transactions found'));
    }

    final closingBalance = entries.isNotEmpty ? entries.last['balance'] as double : 0.0;

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: Column(
        children: [
          // Party Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      party.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      party.partyType.toString().split('.').last.toUpperCase(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Closing Balance', style: TextStyle(fontSize: 12)),
                    Text(
                      '₹${closingBalance.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: closingBalance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      closingBalance >= 0 ? 'Dr' : 'Cr',
                      style: TextStyle(
                        fontSize: 12,
                        color: closingBalance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ledger Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Particulars', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Debit', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Credit', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: entries.map((entry) {
                    final isOpening = entry['type'] == 'opening';
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            isOpening
                                ? '-'
                                : DateFormat('dd/MM/yy').format(entry['date'] as DateTime),
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entry['documentNumber'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              if (entry['description'] != null)
                                Text(
                                  entry['description'] as String,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            (entry['debit'] as double) > 0
                                ? '₹${(entry['debit'] as double).toStringAsFixed(2)}'
                                : '-',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataCell(
                          Text(
                            (entry['credit'] as double) > 0
                                ? '₹${(entry['credit'] as double).toStringAsFixed(2)}'
                                : '-',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${(entry['balance'] as double).abs().toStringAsFixed(2)} ${(entry['balance'] as double) >= 0 ? "Dr" : "Cr"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (entry['balance'] as double) >= 0 ? Colors.orange : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

