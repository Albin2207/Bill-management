import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import '../../features/invoice/domain/entities/invoice_entity.dart';
import '../../features/settings/domain/entities/document_settings_entity.dart';
import '../../features/business/domain/entities/business_entity.dart';
import 'pdf_templates.dart';
import '../utils/upi_qr_generator.dart';

class PDFService {

  static Future<File> generateInvoicePDF(
    InvoiceEntity invoice, {
    DocumentSettingsEntity? settings,
    BusinessEntity? business,
    bool isPreview = false, // Add preview flag
  }) async {
    final pdf = pw.Document();

    // Determine page format based on settings
    final pageFormat = settings?.orientation == DocumentOrientation.landscape
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;
    
    // Get primary color from settings
    final primaryColor = _getPdfColor(settings?.primaryColor ?? '#2196F3');
    final baseFontSize = settings?.fontSize ?? 12.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Template-based Header (Classic, Modern, Minimal, etc.)
            ...PDFTemplates.getTemplateHeader(invoice, settings, primaryColor, baseFontSize),
            pw.SizedBox(height: 20),
            
            // Company Details (if template doesn't include them)
            if (settings?.showCompanyDetails ?? true)
              _buildCompanyInfo(invoice, settings, business, baseFontSize),
            pw.SizedBox(height: 20),
            
            // Invoice Details
            _buildInvoiceDetails(invoice, settings, baseFontSize),
            pw.SizedBox(height: 20),
            
            // Party Details
            _buildPartyDetails(invoice, settings, baseFontSize),
            pw.SizedBox(height: 30),
            
            // Items Table
            _buildItemsTable(invoice, settings, primaryColor, baseFontSize),
            pw.SizedBox(height: 30),
            
            // Totals
            _buildTotals(invoice, settings, primaryColor, baseFontSize),
            pw.SizedBox(height: 30),
            
            // Bank Details (if enabled and available)
            if (settings?.showBankDetails ?? true)
              _buildBankDetails(settings, business, baseFontSize),
            if (settings?.showBankDetails ?? true)
              pw.SizedBox(height: 20),
            
            // Notes & Terms
            if (_hasNotesOrTerms(invoice, settings))
              _buildNotesAndTerms(invoice, settings, baseFontSize),
            
            if (_hasNotesOrTerms(invoice, settings))
              pw.SizedBox(height: 20),
            
            // Signature (if enabled)
            if (settings?.showSignature ?? true)
              _buildSignature(settings, business, baseFontSize),
            
            // QR Code (if enabled and UPI ID available)
            if (settings?.showQRCode ?? true)
              _buildPaymentQRCode(invoice, settings, business, baseFontSize),
            
            // Custom Footer (if set)
            if (settings?.customFooter != null && settings!.customFooter!.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text(
                settings.customFooter!,
                style: pw.TextStyle(fontSize: baseFontSize - 2, fontStyle: pw.FontStyle.italic),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ];
        },
      ),
    );

    // Save to appropriate folder based on preview flag
    Directory? directory;
    
    if (isPreview) {
      // For preview, use temporary/cache directory (won't clutter Downloads)
      directory = await getTemporaryDirectory();
      final fileName = 'Preview_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file;
    } else {
      // For actual invoices, save to Downloads folder
      if (Platform.isAndroid) {
        // Request storage permission
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          final manageStatus = await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            throw Exception('Storage permission denied');
          }
        }
        
        // Use Downloads folder
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        // For iOS/other platforms
        directory = await getApplicationDocumentsDirectory();
      }
      
      final fileName = 'Invoice_${invoice.invoiceNumber.replaceAll('/', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory!.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      return file;
    }
  }
  
  static Future<void> openPDF(File file) async {
    await OpenFile.open(file.path);
  }

  static bool _hasNotesOrTerms(InvoiceEntity invoice, DocumentSettingsEntity? settings) {
    return (invoice.notes != null && invoice.notes!.isNotEmpty) ||
           (invoice.termsAndConditions != null && invoice.termsAndConditions!.isNotEmpty) ||
           (settings?.defaultTerms != null && settings!.defaultTerms!.isNotEmpty);
  }


  static pw.Widget _buildCompanyInfo(
    InvoiceEntity invoice,
    DocumentSettingsEntity? settings,
    BusinessEntity? business,
    double baseFontSize,
  ) {
    final companyName = business?.businessName ?? settings?.companyName ?? 'Company Name';
    final gstin = business?.gstin ?? settings?.companyGSTIN ?? '';
    final address = business?.address ?? settings?.companyAddress ?? '';
    final phone = business?.phone ?? settings?.companyPhone ?? '';
    final email = business?.email ?? settings?.companyEmail;
    
    // Simple company info box (template header already shows title)
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            companyName,
            style: pw.TextStyle(
              fontSize: baseFontSize + 4,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (gstin.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('GSTIN: $gstin', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (address.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(address, style: pw.TextStyle(fontSize: baseFontSize - 1)),
          ],
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              if (phone.isNotEmpty)
                pw.Text('Phone: $phone', style: pw.TextStyle(fontSize: baseFontSize - 1)),
              if (phone.isNotEmpty && email != null && email.isNotEmpty)
                pw.SizedBox(width: 20),
              if (email != null && email.isNotEmpty)
                pw.Text('Email: $email', style: pw.TextStyle(fontSize: baseFontSize - 1)),
            ],
          ),
        ],
      ),
    );
  }

  static String _getInvoiceTypeName(InvoiceType type) {
    switch (type) {
      case InvoiceType.invoice:
        return 'Tax Invoice';
      case InvoiceType.bill:
        return 'Purchase Bill';
      case InvoiceType.salesOrder:
        return 'Sales Order';
      case InvoiceType.purchaseOrder:
        return 'Purchase Order';
      case InvoiceType.creditNote:
        return 'Credit Note';
      case InvoiceType.debitNote:
        return 'Debit Note';
      case InvoiceType.proFormaInvoice:
        return 'Proforma Invoice';
      case InvoiceType.quotation:
        return 'Quotation';
      case InvoiceType.deliveryChalan:
        return 'Delivery Challan';
      case InvoiceType.expense:
        return 'Expense';
      case InvoiceType.indirectIncome:
        return 'Income Receipt';
    }
  }


  static pw.Widget _buildInvoiceDetails(InvoiceEntity invoice, DocumentSettingsEntity? settings, double baseFontSize) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Invoice Date:', DateFormat('dd MMM yyyy').format(invoice.invoiceDate), baseFontSize),
              pw.SizedBox(height: 6),
              if (invoice.dueDate != null)
                _buildDetailRow('Due Date:', DateFormat('dd MMM yyyy').format(invoice.dueDate!), baseFontSize),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _buildDetailRow('State:', invoice.partyState ?? 'N/A', baseFontSize),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPartyDetails(InvoiceEntity invoice, DocumentSettingsEntity? settings, double baseFontSize) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BILL TO:',
            style: pw.TextStyle(
              fontSize: baseFontSize - 1,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            invoice.partyName,
            style: pw.TextStyle(
              fontSize: baseFontSize + 3,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (invoice.partyGstin != null && invoice.partyGstin!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('GSTIN: ${invoice.partyGstin}', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (invoice.partyAddress != null && invoice.partyAddress!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(invoice.partyAddress!, style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (invoice.partyCity != null || invoice.partyState != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              '${invoice.partyCity ?? ''} ${invoice.partyState ?? ''}'.trim(),
              style: pw.TextStyle(fontSize: baseFontSize),
            ),
          ],
          if (invoice.partyPhone != null && invoice.partyPhone!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('Phone: ${invoice.partyPhone}', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(InvoiceEntity invoice, DocumentSettingsEntity? settings, PdfColor primaryColor, double baseFontSize) {
    final showHSN = settings?.includeHSNColumn ?? true;
    final showTax = settings?.includeTaxColumn ?? true;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primaryColor.flatten()),
          children: [
            _buildTableCell('ITEM', isHeader: true, baseFontSize: baseFontSize),
            if (showHSN) _buildTableCell('HSN', isHeader: true, baseFontSize: baseFontSize),
            _buildTableCell('QTY', isHeader: true, align: pw.TextAlign.center, baseFontSize: baseFontSize),
            _buildTableCell('RATE', isHeader: true, align: pw.TextAlign.right, baseFontSize: baseFontSize),
            if (showTax) _buildTableCell('GST%', isHeader: true, align: pw.TextAlign.center, baseFontSize: baseFontSize),
            _buildTableCell('AMOUNT', isHeader: true, align: pw.TextAlign.right, baseFontSize: baseFontSize),
          ],
        ),
        // Items
        ...invoice.items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item.productName, baseFontSize: baseFontSize),
              if (showHSN) _buildTableCell(item.hsnCode, baseFontSize: baseFontSize),
              _buildTableCell('${item.quantity.toStringAsFixed(0)} ${item.unit}', align: pw.TextAlign.center, baseFontSize: baseFontSize),
              _buildTableCell('Rs. ${item.rate.toStringAsFixed(2)}', align: pw.TextAlign.right, baseFontSize: baseFontSize),
              if (showTax) _buildTableCell('${item.gstRate}%', align: pw.TextAlign.center, baseFontSize: baseFontSize),
              _buildTableCell('Rs. ${item.totalAmount.toStringAsFixed(2)}', align: pw.TextAlign.right, baseFontSize: baseFontSize),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTotals(InvoiceEntity invoice, DocumentSettingsEntity? settings, PdfColor primaryColor, double baseFontSize) {
    final roundOff = settings?.roundOffTotal ?? false;
    final grandTotal = roundOff ? invoice.grandTotal.roundToDouble() : invoice.grandTotal;

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            _buildTotalRow('Subtotal', invoice.subtotal, baseFontSize: baseFontSize, settings: settings),
            if (invoice.totalDiscount > 0)
              _buildTotalRow('Discount', invoice.totalDiscount, isNegative: true, baseFontSize: baseFontSize, settings: settings),
            _buildTotalRow('Taxable Amount', invoice.taxableAmount, baseFontSize: baseFontSize, settings: settings),
            pw.SizedBox(height: 8),
            if (invoice.cgst > 0) ...[
              _buildTotalRow('CGST (${(invoice.cgst / invoice.taxableAmount * 100).toStringAsFixed(1)}%)', invoice.cgst, baseFontSize: baseFontSize, settings: settings),
              _buildTotalRow('SGST (${(invoice.sgst / invoice.taxableAmount * 100).toStringAsFixed(1)}%)', invoice.sgst, baseFontSize: baseFontSize, settings: settings),
            ],
            if (invoice.igst > 0)
              _buildTotalRow('IGST (${(invoice.igst / invoice.taxableAmount * 100).toStringAsFixed(1)}%)', invoice.igst, baseFontSize: baseFontSize, settings: settings),
            pw.Divider(thickness: 2, color: primaryColor),
            pw.SizedBox(height: 4),
            _buildTotalRow('GRAND TOTAL', grandTotal, isBold: true, baseFontSize: baseFontSize + 2, settings: settings),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildBankDetails(
    DocumentSettingsEntity? settings,
    BusinessEntity? business,
    double baseFontSize,
  ) {
    // Use business bank account (primary) as primary source
    final primaryBank = business?.bankAccounts.isNotEmpty == true
        ? business!.bankAccounts.firstWhere((b) => b.isPrimary, orElse: () => business.bankAccounts.first)
        : null;
    
    // Merge business and settings data
    final bankName = primaryBank?.bankName ?? settings?.bankName;
    final accountNumber = primaryBank?.accountNumber ?? settings?.accountNumber;
    final ifscCode = primaryBank?.ifscCode ?? settings?.ifscCode;
    final branchName = primaryBank?.branchName ?? settings?.branchName;
    final upiId = business?.upiId ?? settings?.upiId;
    
    final hasDetails = bankName != null || 
                       accountNumber != null || 
                       ifscCode != null ||
                       upiId != null;
    
    if (!hasDetails) return pw.SizedBox();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BANK DETAILS:',
            style: pw.TextStyle(
              fontSize: baseFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          if (bankName != null && bankName.isNotEmpty)
            pw.Text('Bank: $bankName', style: pw.TextStyle(fontSize: baseFontSize)),
          if (accountNumber != null && accountNumber.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('A/c No: $accountNumber', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (ifscCode != null && ifscCode.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('IFSC: $ifscCode', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (branchName != null && branchName.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('Branch: $branchName', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (upiId != null && upiId.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('UPI: $upiId', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildNotesAndTerms(InvoiceEntity invoice, DocumentSettingsEntity? settings, double baseFontSize) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
          pw.Text(
            'NOTES:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: baseFontSize),
          ),
          pw.SizedBox(height: 4),
          pw.Text(invoice.notes!, style: pw.TextStyle(fontSize: baseFontSize)),
          pw.SizedBox(height: 12),
        ],
        if ((invoice.termsAndConditions != null && invoice.termsAndConditions!.isNotEmpty) ||
            (settings?.defaultTerms != null && settings!.defaultTerms!.isNotEmpty)) ...[
          pw.Text(
            'TERMS & CONDITIONS:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: baseFontSize),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            invoice.termsAndConditions ?? settings?.defaultTerms ?? '',
            style: pw.TextStyle(fontSize: baseFontSize),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildSignature(
    DocumentSettingsEntity? settings,
    BusinessEntity? business,
    double baseFontSize,
  ) {
    // Use business signature URL or settings signature URL
    // TODO: Implement signature image in future enhancement
    // final signatureUrl = business?.signatureUrl ?? settings?.signatureUrl;
    final signatory = settings?.authorizedSignatory ?? business?.businessName;
    
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            signatory ?? '',
            style: pw.TextStyle(
              fontSize: baseFontSize - 1,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 40),
          pw.Container(
            width: 200,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'Authorized Signatory',
              style: pw.TextStyle(fontSize: baseFontSize - 1),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailRow(String label, String value, double baseFontSize) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(
              fontSize: baseFontSize - 2,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: baseFontSize - 2,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    required double baseFontSize,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? baseFontSize - 1 : baseFontSize - 2,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    bool isNegative = false,
    required double baseFontSize,
    DocumentSettingsEntity? settings,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: baseFontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            '${isNegative ? '-' : ''}Rs. ${amount.abs().toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: baseFontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static PdfColor _getPdfColor(String hexColor) {
    // Remove # if present
    final hex = hexColor.replaceAll('#', '');
    
    // Parse hex to RGB
    final r = int.parse(hex.substring(0, 2), radix: 16) / 255;
    final g = int.parse(hex.substring(2, 4), radix: 16) / 255;
    final b = int.parse(hex.substring(4, 6), radix: 16) / 255;
    
    return PdfColor(r, g, b);
  }

  static pw.Widget _buildPaymentQRCode(
    InvoiceEntity invoice,
    DocumentSettingsEntity? settings,
    BusinessEntity? business,
    double baseFontSize,
  ) {
    // Get UPI ID from business profile or settings
    final upiId = business?.upiId ?? settings?.upiId;
    
    // Debug print
    print('🔍 PDF QR Code Debug:');
    print('  UPI ID: $upiId');
    print('  Business: ${business?.businessName}');
    print('  Show QR Setting: ${settings?.showQRCode}');
    
    // If no UPI ID, don't show QR code
    if (upiId == null || upiId.isEmpty) {
      print('  ❌ No UPI ID found');
      return pw.SizedBox();
    }

    // Validate UPI ID format
    if (!UpiQrGenerator.isValidUpiId(upiId)) {
      print('  ❌ Invalid UPI ID format');
      return pw.SizedBox();
    }

    try {
      // Generate UPI payment link
      final businessName = business?.businessName ?? settings?.companyName ?? 'Business';
      final upiLink = UpiQrGenerator.generateInvoicePaymentLink(
        upiId: upiId,
        businessName: businessName,
        amount: invoice.grandTotal,
        invoiceNumber: invoice.invoiceNumber,
      );

      print('  ✅ UPI Link generated: $upiLink');

      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 20),
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left side: QR Code
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 2),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: upiLink,
                    width: 100,
                    height: 100,
                    drawText: false,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Scan to Pay',
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 2,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // Right side: Payment details
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'UPI Payment',
                      style: pw.TextStyle(
                        fontSize: baseFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'UPI ID: $upiId',
                      style: pw.TextStyle(fontSize: baseFontSize - 2),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Amount: Rs. ${invoice.grandTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: baseFontSize - 2,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Ref: ${invoice.invoiceNumber}',
                      style: pw.TextStyle(fontSize: baseFontSize - 3),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Open any UPI app (GPay, PhonePe, Paytm, etc.) and scan to pay',
                      style: pw.TextStyle(
                        fontSize: baseFontSize - 3,
                        color: PdfColors.grey700,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // If QR generation fails, log and return empty widget
      print('  ❌ Error generating QR: $e');
      return pw.SizedBox();
    }
  }

}
