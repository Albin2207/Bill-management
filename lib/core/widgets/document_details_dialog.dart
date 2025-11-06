import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/document_constants.dart';

class DocumentDetailsDialog extends StatefulWidget {
  final String? prefix;
  final String? documentNumber;
  final DateTime? documentDate;
  final DateTime? dueDate;
  final String? documentTitle;
  final double? discount;
  final String? discountType;
  final List<String> prefixOptions;
  final bool showDueDate;
  final Function(Map<String, dynamic>) onSave;

  const DocumentDetailsDialog({
    super.key,
    this.prefix,
    this.documentNumber,
    this.documentDate,
    this.dueDate,
    this.documentTitle,
    this.discount,
    this.discountType,
    required this.prefixOptions,
    this.showDueDate = true,
    required this.onSave,
  });

  @override
  State<DocumentDetailsDialog> createState() => _DocumentDetailsDialogState();
}

class _DocumentDetailsDialogState extends State<DocumentDetailsDialog> {
  late TextEditingController _documentNumberController;
  late TextEditingController _documentTitleController;
  late TextEditingController _discountController;
  
  late String _selectedPrefix;
  late DateTime _documentDate;
  late DateTime? _dueDate;
  late String _selectedDiscountType;

  @override
  void initState() {
    super.initState();
    _selectedPrefix = widget.prefix ?? widget.prefixOptions.first;
    _documentNumberController = TextEditingController(
      text: widget.documentNumber ?? _generateDocumentNumber(),
    );
    _documentTitleController = TextEditingController(
      text: widget.documentTitle ?? '',
    );
    _discountController = TextEditingController(
      text: widget.discount?.toString() ?? '0',
    );
    _documentDate = widget.documentDate ?? DateTime.now();
    _dueDate = widget.dueDate;
    _selectedDiscountType = widget.discountType ?? DocumentConstants.discountTypes.first;
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    _documentTitleController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  String _generateDocumentNumber() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}001';
  }

  Future<void> _selectDate(bool isDocumentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDocumentDate ? _documentDate : (_dueDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        if (isDocumentDate) {
          _documentDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _save() {
    final data = {
      'prefix': _selectedPrefix,
      'documentNumber': _documentNumberController.text,
      'documentDate': _documentDate,
      'dueDate': _dueDate,
      'documentTitle': _documentTitleController.text,
      'discount': double.tryParse(_discountController.text) ?? 0,
      'discountType': _selectedDiscountType,
    };
    widget.onSave(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Document Details',
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
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prefix & Document Number
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedPrefix,
                            decoration: const InputDecoration(
                              labelText: 'Prefix',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: widget.prefixOptions.map((prefix) {
                              return DropdownMenuItem(
                                value: prefix,
                                child: Text(
                                  prefix,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPrefix = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _documentNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Document Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Document Title
                    TextFormField(
                      controller: _documentTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Document Title (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Tax Invoice',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Document Date
                    InkWell(
                      onTap: () => _selectDate(true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Document Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('dd MMM yyyy').format(_documentDate),
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Due Date (if applicable)
                    if (widget.showDueDate) ...[
                      InkWell(
                        onTap: () => _selectDate(false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Due Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _dueDate != null
                                ? DateFormat('dd MMM yyyy').format(_dueDate!)
                                : 'Select due date',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Discount
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _discountController,
                            decoration: const InputDecoration(
                              labelText: 'Discount',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _selectedDiscountType,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: DocumentConstants.discountTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDiscountType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2C)
                    : Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

