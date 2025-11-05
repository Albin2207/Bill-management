import 'package:equatable/equatable.dart';

enum BusinessType {
  soleProprietor,
  partnership,
  llp,
  privateLimited,
  publicLimited,
  other,
}

class BankAccount extends Equatable {
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String accountHolderName;
  final String? branchName;
  final bool isPrimary;

  const BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountHolderName,
    this.branchName,
    this.isPrimary = false,
  });

  BankAccount copyWith({
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? accountHolderName,
    String? branchName,
    bool? isPrimary,
  }) {
    return BankAccount(
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      branchName: branchName ?? this.branchName,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  List<Object?> get props => [
        bankName,
        accountNumber,
        ifscCode,
        accountHolderName,
        branchName,
        isPrimary,
      ];
}

class BusinessEntity extends Equatable {
  final String id;
  final String userId;
  final String businessName;
  final String? tradeName;
  final BusinessType businessType;
  
  // GST & Tax Details
  final String gstin;
  final String? pan;
  final String? tan;
  
  // Contact Information
  final String phone;
  final String? email;
  final String? website;
  
  // Address
  final String address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  
  // Bank Accounts
  final List<BankAccount> bankAccounts;
  
  // Branding
  final String? logoUrl;
  final String? signatureUrl;
  
  // Terms & Conditions
  final String? termsAndConditions;
  final String? paymentTerms;
  
  // Other Details
  final String? upiId;
  final String? registrationNumber;
  final DateTime? establishedDate;
  
  final bool isOnboardingComplete;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BusinessEntity({
    required this.id,
    required this.userId,
    required this.businessName,
    this.tradeName,
    required this.businessType,
    required this.gstin,
    this.pan,
    this.tan,
    required this.phone,
    this.email,
    this.website,
    required this.address,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.bankAccounts = const [],
    this.logoUrl,
    this.signatureUrl,
    this.termsAndConditions,
    this.paymentTerms,
    this.upiId,
    this.registrationNumber,
    this.establishedDate,
    this.isOnboardingComplete = false,
    required this.createdAt,
    this.updatedAt,
  });

  BusinessEntity copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? tradeName,
    BusinessType? businessType,
    String? gstin,
    String? pan,
    String? tan,
    String? phone,
    String? email,
    String? website,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? country,
    List<BankAccount>? bankAccounts,
    String? logoUrl,
    String? signatureUrl,
    String? termsAndConditions,
    String? paymentTerms,
    String? upiId,
    String? registrationNumber,
    DateTime? establishedDate,
    bool? isOnboardingComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      tradeName: tradeName ?? this.tradeName,
      businessType: businessType ?? this.businessType,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      tan: tan ?? this.tan,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      logoUrl: logoUrl ?? this.logoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      upiId: upiId ?? this.upiId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      establishedDate: establishedDate ?? this.establishedDate,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        businessName,
        tradeName,
        businessType,
        gstin,
        pan,
        tan,
        phone,
        email,
        website,
        address,
        city,
        state,
        pincode,
        country,
        bankAccounts,
        logoUrl,
        signatureUrl,
        termsAndConditions,
        paymentTerms,
        upiId,
        registrationNumber,
        establishedDate,
        isOnboardingComplete,
        createdAt,
        updatedAt,
      ];
}

