import 'package:equatable/equatable.dart';

enum DocumentTemplate {
  classic,
  modern,
  minimal,
  professional,
  colorful,
  elegant,
}

enum DocumentOrientation {
  portrait,
  landscape,
}

enum FontStyle {
  roboto,
  openSans,
  lato,
  montserrat,
  poppins,
}

class DocumentSettingsEntity extends Equatable {
  final String id;
  final String userId;
  
  // Template & Style
  final DocumentTemplate template;
  final String primaryColor; // Hex color
  final String secondaryColor;
  final FontStyle fontStyle;
  final double fontSize;
  
  // Layout
  final DocumentOrientation orientation;
  final bool showLogo;
  final bool showCompanyDetails;
  final bool showBankDetails;
  final bool showSignature;
  final bool showTerms;
  final bool showQRCode;
  
  // Content
  final String? customHeader;
  final String? customFooter;
  final String? defaultTerms;
  final String? defaultNotes;
  
  // Company Details
  final String? companyName;
  final String? companyGSTIN;
  final String? companyAddress;
  final String? companyPhone;
  final String? companyEmail;
  final String? companyWebsite;
  final String? companyLogo;
  
  // Bank Details
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branchName;
  final String? upiId;
  
  // Signature
  final String? signatureUrl;
  final String? authorizedSignatory;
  
  // Advanced
  final bool autoNumbering;
  final bool includeHSNColumn;
  final bool includeTaxColumn;
  final bool showItemImages;
  final bool roundOffTotal;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentSettingsEntity({
    required this.id,
    required this.userId,
    this.template = DocumentTemplate.classic,
    this.primaryColor = '#2196F3',
    this.secondaryColor = '#FFC107',
    this.fontStyle = FontStyle.roboto,
    this.fontSize = 12.0,
    this.orientation = DocumentOrientation.portrait,
    this.showLogo = true,
    this.showCompanyDetails = true,
    this.showBankDetails = true,
    this.showSignature = true,
    this.showTerms = true,
    this.showQRCode = true,
    this.customHeader,
    this.customFooter,
    this.defaultTerms,
    this.defaultNotes,
    this.companyName,
    this.companyGSTIN,
    this.companyAddress,
    this.companyPhone,
    this.companyEmail,
    this.companyWebsite,
    this.companyLogo,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branchName,
    this.upiId,
    this.signatureUrl,
    this.authorizedSignatory,
    this.autoNumbering = true,
    this.includeHSNColumn = true,
    this.includeTaxColumn = true,
    this.showItemImages = false,
    this.roundOffTotal = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        template,
        primaryColor,
        secondaryColor,
        fontStyle,
        fontSize,
        orientation,
        showLogo,
        showCompanyDetails,
        showBankDetails,
        showSignature,
        showTerms,
        showQRCode,
        customHeader,
        customFooter,
        defaultTerms,
        defaultNotes,
        companyName,
        companyGSTIN,
        companyAddress,
        companyPhone,
        companyEmail,
        companyWebsite,
        companyLogo,
        bankName,
        accountNumber,
        ifscCode,
        branchName,
        upiId,
        signatureUrl,
        authorizedSignatory,
        autoNumbering,
        includeHSNColumn,
        includeTaxColumn,
        showItemImages,
        roundOffTotal,
        createdAt,
        updatedAt,
      ];
}

