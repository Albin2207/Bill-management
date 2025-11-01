import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/document_constants.dart';

class ExportSectionWidget extends StatefulWidget {
  final bool isExport;
  final Map<String, dynamic>? exportData;
  final Function(Map<String, dynamic>?) onChanged;

  const ExportSectionWidget({
    super.key,
    required this.isExport,
    this.exportData,
    required this.onChanged,
  });

  @override
  State<ExportSectionWidget> createState() => _ExportSectionWidgetState();
}

class _ExportSectionWidgetState extends State<ExportSectionWidget> {
  late bool _isExport;
  late TextEditingController _shippingBillNumberController;
  late TextEditingController _portCodeController;
  late TextEditingController _conversionRateController;
  
  String? _exportType;
  DateTime? _shippingBillDate;
  String? _countryOfSupply;
  String? _currency;

  @override
  void initState() {
    super.initState();
    _isExport = widget.isExport;
    _shippingBillNumberController = TextEditingController(
      text: widget.exportData?['shippingBillNumber'] ?? '',
    );
    _portCodeController = TextEditingController(
      text: widget.exportData?['portCode'] ?? '',
    );
    _conversionRateController = TextEditingController(
      text: widget.exportData?['conversionRate']?.toString() ?? '1.0',
    );
    _exportType = widget.exportData?['exportType'];
    _shippingBillDate = widget.exportData?['shippingBillDate'];
    _countryOfSupply = widget.exportData?['countryOfSupply'];
    _currency = widget.exportData?['currency'];
  }

  @override
  void dispose() {
    _shippingBillNumberController.dispose();
    _portCodeController.dispose();
    _conversionRateController.dispose();
    super.dispose();
  }

  void _updateData() {
    if (_isExport) {
      widget.onChanged({
        'exportType': _exportType,
        'shippingBillNumber': _shippingBillNumberController.text,
        'shippingBillDate': _shippingBillDate,
        'portCode': _portCodeController.text,
        'countryOfSupply': _countryOfSupply,
        'currency': _currency,
        'conversionRate': double.tryParse(_conversionRateController.text) ?? 1.0,
      });
    } else {
      widget.onChanged(null);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _shippingBillDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _shippingBillDate = picked;
      });
      _updateData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          CheckboxListTile(
            title: const Text(
              'Export Invoice / SEZ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Check if this is an export invoice'),
            value: _isExport,
            onChanged: (value) {
              setState(() {
                _isExport = value ?? false;
              });
              _updateData();
            },
          ),
          
          if (_isExport) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Export Type
                  DropdownButtonFormField<String>(
                    value: _exportType,
                    decoration: const InputDecoration(
                      labelText: 'Export Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: DocumentConstants.exportTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _exportType = value;
                      });
                      _updateData();
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Shipping Bill Number & Date
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _shippingBillNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Shipping Bill Number',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _updateData(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Shipping Bill Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _shippingBillDate != null
                                  ? DateFormat('dd MMM yyyy').format(_shippingBillDate!)
                                  : 'Select date',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Port Code
                  TextFormField(
                    controller: _portCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Port Code',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., INNSA1',
                    ),
                    onChanged: (_) => _updateData(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Country of Supply
                  DropdownButtonFormField<String>(
                    value: _countryOfSupply,
                    decoration: const InputDecoration(
                      labelText: 'Country of Supply *',
                      border: OutlineInputBorder(),
                    ),
                    items: DocumentConstants.countries.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _countryOfSupply = value;
                      });
                      _updateData();
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Currency & Conversion Rate
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _currency,
                          decoration: const InputDecoration(
                            labelText: 'Currency *',
                            border: OutlineInputBorder(),
                          ),
                          items: DocumentConstants.currencies.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _currency = value;
                            });
                            _updateData();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _conversionRateController,
                          decoration: const InputDecoration(
                            labelText: 'Conversion Rate',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateData(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

