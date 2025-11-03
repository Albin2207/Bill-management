import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../../domain/entities/invoice_entity.dart';
import 'create_indirect_income_page.dart';
import 'invoice_detail_page.dart';

class IndirectIncomeListPage extends StatefulWidget {
  const IndirectIncomeListPage({super.key});

  @override
  State<IndirectIncomeListPage> createState() => _IndirectIncomeListPageState();
}

class _IndirectIncomeListPageState extends State<IndirectIncomeListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIncome();
    });
  }

  void _loadIncome() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final income = invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.indirectIncome).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Income'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: income.isEmpty
          ? const Center(child: Text('No other income yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: income.length,
              itemBuilder: (context, index) {
                final item = income[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InvoiceDetailPage(invoice: item)),
                    ).then((_) => _loadIncome()),
                    title: Text(item.invoiceNumber),
                    subtitle: Text('${item.partyName} • ${DateFormat('dd MMM yyyy').format(item.invoiceDate)}'),
                    trailing: Text(
                      '₹${item.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateIndirectIncomePage()),
          );
          if (result == true) _loadIncome();
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text('Add Income'),
      ),
    );
  }
}


