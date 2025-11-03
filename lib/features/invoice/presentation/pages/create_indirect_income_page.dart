import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/document_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../../domain/entities/invoice_entity.dart';

class CreateIndirectIncomePage extends StatefulWidget {
  const CreateIndirectIncomePage({super.key});

  @override
  State<CreateIndirectIncomePage> createState() => _CreateIndirectIncomePageState();
}

class _CreateIndirectIncomePageState extends State<CreateIndirectIncomePage> {
  final _partyController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _prefix = DocumentConstants.indirectIncomePrefixes.first;
  DateTime _date = DateTime.now();

  Future<void> _saveIncome() async {
    if (_partyController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId == null) return;

    final income = InvoiceEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: '$_prefix-${DateTime.now().millisecondsSinceEpoch}',
      invoiceType: InvoiceType.indirectIncome,
      invoiceDate: _date,
      partyId: 'income',
      partyName: _partyController.text,
      items: [],
      subtotal: double.parse(_amountController.text),
      totalDiscount: 0,
      taxableAmount: double.parse(_amountController.text),
      cgst: 0,
      sgst: 0,
      igst: 0,
      totalTax: 0,
      grandTotal: double.parse(_amountController.text),
      paymentStatus: PaymentStatus.paid,
      paidAmount: double.parse(_amountController.text),
      balanceAmount: 0,
      notes: _notesController.text,
      isInterState: false,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await invoiceProvider.addInvoice(income);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Income added!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Other Income'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _partyController,
              decoration: const InputDecoration(labelText: 'Received From', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder(), prefixText: '₹'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (Interest, Rent received, etc.)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveIncome,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.all(16)),
                child: const Text('Save Income', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


