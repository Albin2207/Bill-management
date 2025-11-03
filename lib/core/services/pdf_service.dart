import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import '../../features/invoice/domain/entities/invoice_entity.dart';
import '../../features/settings/domain/entities/document_settings_entity.dart';
import '../utils/language_helper.dart';
import 'pdf_templates.dart';

class PDFService {
  // Helper to get translated label
  static String _t(String key, DocumentSettingsEntity? settings) {
    final lang = settings?.language ?? DocumentLanguage.english;
    final translations = LanguageHelper.getTranslations(lang);
    return translations[key] ?? key;
  }

  static Future<File> generateInvoicePDF(
    InvoiceEntity invoice, {
    DocumentSettingsEntity? settings,
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
            // Custom Header (if set)
            if (settings?.customHeader != null && settings!.customHeader!.isNotEmpty) ...[
              pw.Text(
                settings.customHeader!,
                style: pw.TextStyle(fontSize: baseFontSize + 2, fontStyle: pw.FontStyle.italic),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),
            ],
            
            // Template-based Header
            ...PDFTemplates.getTemplateHeader(invoice, settings, primaryColor, baseFontSize),
            pw.SizedBox(height: 20),
            
            // Company Details (if enabled and available)
            if (settings?.showCompanyDetails ?? true)
              _buildCompanyDetails(settings, baseFontSize),
            if (settings?.showCompanyDetails ?? true)
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
              _buildBankDetails(settings, baseFontSize),
            if (settings?.showBankDetails ?? true)
              pw.SizedBox(height: 20),
            
            // Notes & Terms
            if (_hasNotesOrTerms(invoice, settings))
              _buildNotesAndTerms(invoice, settings, baseFontSize),
            
            if (_hasNotesOrTerms(invoice, settings))
              pw.SizedBox(height: 20),
            
            // Signature (if enabled)
            if (settings?.showSignature ?? true)
              _buildSignature(settings, baseFontSize),
            
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

  static pw.Widget _buildHeader(InvoiceEntity invoice, DocumentSettingsEntity? settings, PdfColor primaryColor, double baseFontSize) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'TAX INVOICE',
              style: pw.TextStyle(
                fontSize: baseFontSize + 16,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              invoice.invoiceNumber,
              style: pw.TextStyle(
                fontSize: baseFontSize + 4,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: pw.BoxDecoration(
            color: _getStatusPdfColor(invoice.paymentStatus),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            invoice.paymentStatus.name.toUpperCase(),
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: baseFontSize,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCompanyDetails(DocumentSettingsEntity? settings, double baseFontSize) {
    if (settings == null) return pw.SizedBox();
    
    final hasDetails = settings.companyName != null || 
                       settings.companyGSTIN != null || 
                       settings.companyAddress != null;
    
    if (!hasDetails) return pw.SizedBox();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (settings.companyName != null && settings.companyName!.isNotEmpty) ...[
            pw.Text(
              settings.companyName!,
              style: pw.TextStyle(
                fontSize: baseFontSize + 4,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
          ],
          if (settings.companyGSTIN != null && settings.companyGSTIN!.isNotEmpty)
            pw.Text('GSTIN: ${settings.companyGSTIN}', style: pw.TextStyle(fontSize: baseFontSize)),
          if (settings.companyAddress != null && settings.companyAddress!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(settings.companyAddress!, style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (settings.companyPhone != null && settings.companyPhone!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('Phone: ${settings.companyPhone}', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (settings.companyEmail != null && settings.companyEmail!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('Email: ${settings.companyEmail}', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (settings.companyWebsite != null && settings.companyWebsite!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('Website: ${settings.companyWebsite}', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceDetails(InvoiceEntity invoice, DocumentSettingsEntity? settings, double baseFontSize) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildDetailRow(_t('invoiceDate', settings), DateFormat('dd MMM yyyy').format(invoice.invoiceDate), baseFontSize),
            if (invoice.dueDate != null)
              _buildDetailRow(_t('dueDate', settings), DateFormat('dd MMM yyyy').format(invoice.dueDate!), baseFontSize),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPartyDetails(InvoiceEntity invoice, DocumentSettingsEntity? settings, double baseFontSize) {
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
            '${_t('billTo', settings)}:',
            style: pw.TextStyle(
              fontSize: baseFontSize,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            invoice.partyName,
            style: pw.TextStyle(
              fontSize: baseFontSize + 4,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (invoice.partyGstin != null) ...[
            pw.SizedBox(height: 4),
            pw.Text('${_t('gstin', settings)}: ${invoice.partyGstin}', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (invoice.partyAddress != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(invoice.partyAddress!, style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (invoice.partyCity != null || invoice.partyState != null) ...[
            pw.SizedBox(height: 4),
            pw.Text('${invoice.partyCity ?? ''} ${invoice.partyState ?? ''}', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (invoice.partyPhone != null) ...[
            pw.SizedBox(height: 4),
            pw.Text('${_t('phone', settings)}: ${invoice.partyPhone}', style: pw.TextStyle(fontSize: baseFontSize)),
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
            _buildTableCell(_t('item', settings), isHeader: true, baseFontSize: baseFontSize),
            if (showHSN) _buildTableCell(_t('hsn', settings), isHeader: true, baseFontSize: baseFontSize),
            _buildTableCell(_t('qty', settings), isHeader: true, align: pw.TextAlign.center, baseFontSize: baseFontSize),
            _buildTableCell(_t('rate', settings), isHeader: true, align: pw.TextAlign.right, baseFontSize: baseFontSize),
            if (showTax) _buildTableCell(_t('gst', settings), isHeader: true, align: pw.TextAlign.center, baseFontSize: baseFontSize),
            _buildTableCell(_t('amount', settings), isHeader: true, align: pw.TextAlign.right, baseFontSize: baseFontSize),
          ],
        ),
        // Items
        ...invoice.items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item.productName, baseFontSize: baseFontSize),
              if (showHSN) _buildTableCell(item.hsnCode, baseFontSize: baseFontSize),
              _buildTableCell('${item.quantity.toStringAsFixed(0)} ${item.unit}', align: pw.TextAlign.center, baseFontSize: baseFontSize),
              _buildTableCell('₹${item.rate.toStringAsFixed(2)}', align: pw.TextAlign.right, baseFontSize: baseFontSize),
              if (showTax) _buildTableCell('${item.gstRate}%', align: pw.TextAlign.center, baseFontSize: baseFontSize),
              _buildTableCell('₹${item.totalAmount.toStringAsFixed(2)}', align: pw.TextAlign.right, baseFontSize: baseFontSize),
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
            _buildTotalRow(_t('subtotal', settings), invoice.subtotal, baseFontSize: baseFontSize, settings: settings),
            if (invoice.totalDiscount > 0)
              _buildTotalRow(_t('discount', settings), invoice.totalDiscount, isNegative: true, baseFontSize: baseFontSize, settings: settings),
            _buildTotalRow(_t('taxableAmount', settings), invoice.taxableAmount, baseFontSize: baseFontSize, settings: settings),
            pw.SizedBox(height: 8),
            if (invoice.cgst > 0) ...[
              _buildTotalRow(_t('cgst', settings), invoice.cgst, baseFontSize: baseFontSize, settings: settings),
              _buildTotalRow(_t('sgst', settings), invoice.sgst, baseFontSize: baseFontSize, settings: settings),
            ],
            if (invoice.igst > 0)
              _buildTotalRow(_t('igst', settings), invoice.igst, baseFontSize: baseFontSize, settings: settings),
            pw.Divider(thickness: 2, color: primaryColor),
            pw.SizedBox(height: 4),
            _buildTotalRow(_t('grandTotal', settings), grandTotal, isBold: true, baseFontSize: baseFontSize + 2, settings: settings),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildBankDetails(DocumentSettingsEntity? settings, double baseFontSize) {
    if (settings == null) return pw.SizedBox();
    
    final hasDetails = settings.bankName != null || 
                       settings.accountNumber != null || 
                       settings.ifscCode != null ||
                       settings.upiId != null;
    
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
            '${_t('bankDetails', settings)}:',
            style: pw.TextStyle(
              fontSize: baseFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          if (settings.bankName != null && settings.bankName!.isNotEmpty)
            pw.Text('${_t('bank', settings)}: ${settings.bankName}', style: pw.TextStyle(fontSize: baseFontSize)),
          if (settings.accountNumber != null && settings.accountNumber!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('${_t('accountNumber', settings)}: ${settings.accountNumber}', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (settings.ifscCode != null && settings.ifscCode!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('${_t('ifscCode', settings)}: ${settings.ifscCode}', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (settings.branchName != null && settings.branchName!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('${_t('branch', settings)}: ${settings.branchName}', style: pw.TextStyle(fontSize: baseFontSize)),
          ],
          if (settings.upiId != null && settings.upiId!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('${_t('upi', settings)}: ${settings.upiId}', style: pw.TextStyle(fontSize: baseFontSize)),
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
            '${_t('notes', settings)}:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: baseFontSize),
          ),
          pw.SizedBox(height: 4),
          pw.Text(invoice.notes!, style: pw.TextStyle(fontSize: baseFontSize)),
          pw.SizedBox(height: 12),
        ],
        if ((invoice.termsAndConditions != null && invoice.termsAndConditions!.isNotEmpty) ||
            (settings?.defaultTerms != null && settings!.defaultTerms!.isNotEmpty)) ...[
          pw.Text(
            '${_t('termsAndConditions', settings)}:',
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

  static pw.Widget _buildSignature(DocumentSettingsEntity? settings, double baseFontSize) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            _t('authorizedSignatory', settings),
            style: pw.TextStyle(
              fontSize: baseFontSize,
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
              settings?.authorizedSignatory ?? _t('signature', settings),
              style: pw.TextStyle(fontSize: baseFontSize),
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
            '${isNegative ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}',
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

  static PdfColor _getStatusPdfColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return PdfColors.green700;
      case PaymentStatus.unpaid:
      case PaymentStatus.pending:
        return PdfColors.red700;
      case PaymentStatus.partial:
        return PdfColors.orange700;
      case PaymentStatus.cancelled:
        return PdfColors.grey700;
    }
  }
}
