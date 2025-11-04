import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../features/invoice/domain/entities/invoice_entity.dart';
import '../../features/settings/domain/entities/document_settings_entity.dart';

class PDFTemplates {

  static PdfColor _getPdfColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    final r = int.parse(hex.substring(0, 2), radix: 16) / 255;
    final g = int.parse(hex.substring(2, 4), radix: 16) / 255;
    final b = int.parse(hex.substring(4, 6), radix: 16) / 255;
    return PdfColor(r, g, b);
  }

  // CLASSIC TEMPLATE - Traditional layout with borders
  static List<pw.Widget> buildClassicTemplate(
    InvoiceEntity invoice,
    DocumentSettingsEntity? settings,
    PdfColor primaryColor,
    double baseFontSize,
  ) {
    return [
      // Header with border
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: primaryColor, width: 2),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        padding: const pw.EdgeInsets.all(16),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'TAX INVOICE',
              style: pw.TextStyle(
                fontSize: baseFontSize + 20,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.Text(
              invoice.invoiceNumber,
              style: pw.TextStyle(
                fontSize: baseFontSize + 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // MODERN TEMPLATE - Clean with accent colors
  static List<pw.Widget> buildModernTemplate(
    InvoiceEntity invoice,
    DocumentSettingsEntity? settings,
    PdfColor primaryColor,
    double baseFontSize,
  ) {
    return [
      // Large colored header block
      pw.Container(
        color: primaryColor,
        padding: const pw.EdgeInsets.all(24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'TAX INVOICE',
              style: pw.TextStyle(
                fontSize: baseFontSize + 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              invoice.invoiceNumber,
              style: pw.TextStyle(
                fontSize: baseFontSize + 6,
                color: PdfColors.white,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // MINIMAL TEMPLATE - Simple and clean
  static List<pw.Widget> buildMinimalTemplate(
    InvoiceEntity invoice,
    DocumentSettingsEntity? settings,
    PdfColor primaryColor,
    double baseFontSize,
  ) {
    return [
      // Simple text header
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TAX INVOICE',
            style: pw.TextStyle(
              fontSize: baseFontSize + 18,
              fontWeight: pw.FontWeight.normal,
              color: PdfColors.black,
            ),
          ),
          pw.Container(
            height: 3,
            width: 100,
            color: primaryColor,
            margin: const pw.EdgeInsets.symmetric(vertical: 8),
          ),
          pw.Text(
            invoice.invoiceNumber,
            style: pw.TextStyle(
              fontSize: baseFontSize + 4,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    ];
  }

  // PROFESSIONAL TEMPLATE - Corporate style
  static List<pw.Widget> buildProfessionalTemplate(
    InvoiceEntity invoice,
    DocumentSettingsEntity? settings,
    PdfColor primaryColor,
    double baseFontSize,
  ) {
    return [
      // Dark header with gradient effect
      pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.grey900,
          border: pw.Border(
            bottom: pw.BorderSide(color: primaryColor, width: 4),
          ),
        ),
        padding: const pw.EdgeInsets.all(20),
        child: pw.Row(
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
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: primaryColor,
                  child: pw.Text(
                    invoice.invoiceNumber,
                    style: pw.TextStyle(
                      fontSize: baseFontSize + 2,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primaryColor, width: 2),
              ),
              child: pw.Text(
                DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                style: pw.TextStyle(
                  fontSize: baseFontSize,
                  color: PdfColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // COLORFUL TEMPLATE - Vibrant with multiple colors
  static List<pw.Widget> buildColorfulTemplate(
    InvoiceEntity invoice,
    DocumentSettingsEntity? settings,
    PdfColor primaryColor,
    double baseFontSize,
  ) {
    return [
      // Colorful header with shapes
      pw.Stack(
        children: [
          pw.Container(
            height: 120,
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [primaryColor, primaryColor.flatten()],
              ),
            ),
          ),
          pw.Positioned(
            top: 20,
            left: 20,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    'TAX INVOICE',
                    style: pw.TextStyle(
                      fontSize: baseFontSize + 14,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  invoice.invoiceNumber,
                  style: pw.TextStyle(
                    fontSize: baseFontSize + 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // ELEGANT TEMPLATE - Sophisticated design
  static List<pw.Widget> buildElegantTemplate(
    InvoiceEntity invoice,
    DocumentSettingsEntity? settings,
    PdfColor primaryColor,
    double baseFontSize,
  ) {
    return [
      // Elegant header with decorative elements
      pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: primaryColor, width: 3),
            bottom: pw.BorderSide(color: primaryColor, width: 3),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TAX INVOICE',
                  style: pw.TextStyle(
                    fontSize: baseFontSize + 22,
                    fontWeight: pw.FontWeight.normal,
                    color: primaryColor,
                    letterSpacing: 2,
                  ),
                ),
                pw.Container(
                  height: 1,
                  width: 80,
                  color: primaryColor,
                  margin: const pw.EdgeInsets.symmetric(vertical: 8),
                ),
                pw.Text(
                  invoice.invoiceNumber,
                  style: pw.TextStyle(
                    fontSize: baseFontSize + 4,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                border: pw.Border.all(color: primaryColor, width: 3),
              ),
              child: pw.Center(
                child: pw.Text(
                  DateFormat('dd').format(invoice.invoiceDate),
                  style: pw.TextStyle(
                    fontSize: baseFontSize + 8,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // Get template based on settings
  static List<pw.Widget> getTemplateHeader(
    InvoiceEntity invoice,
    DocumentSettingsEntity? settings,
    PdfColor primaryColor,
    double baseFontSize,
  ) {
    final template = settings?.template ?? DocumentTemplate.classic;

    switch (template) {
      case DocumentTemplate.classic:
        return buildClassicTemplate(invoice, settings, primaryColor, baseFontSize);
      case DocumentTemplate.modern:
        return buildModernTemplate(invoice, settings, primaryColor, baseFontSize);
      case DocumentTemplate.minimal:
        return buildMinimalTemplate(invoice, settings, primaryColor, baseFontSize);
      case DocumentTemplate.professional:
        return buildProfessionalTemplate(invoice, settings, primaryColor, baseFontSize);
      case DocumentTemplate.colorful:
        return buildColorfulTemplate(invoice, settings, primaryColor, baseFontSize);
      case DocumentTemplate.elegant:
        return buildElegantTemplate(invoice, settings, primaryColor, baseFontSize);
    }
  }
}

