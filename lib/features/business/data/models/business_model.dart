import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/business_entity.dart';

class BankAccountModel {
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String accountHolderName;
  final String? branchName;
  final bool isPrimary;

  BankAccountModel({
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountHolderName,
    this.branchName,
    this.isPrimary = false,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      ifscCode: json['ifscCode'] as String,
      accountHolderName: json['accountHolderName'] as String,
      branchName: json['branchName'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'accountHolderName': accountHolderName,
      'branchName': branchName,
      'isPrimary': isPrimary,
    };
  }

  BankAccount toEntity() {
    return BankAccount(
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      accountHolderName: accountHolderName,
      branchName: branchName,
      isPrimary: isPrimary,
    );
  }

  factory BankAccountModel.fromEntity(BankAccount entity) {
    return BankAccountModel(
      bankName: entity.bankName,
      accountNumber: entity.accountNumber,
      ifscCode: entity.ifscCode,
      accountHolderName: entity.accountHolderName,
      branchName: entity.branchName,
      isPrimary: entity.isPrimary,
    );
  }
}

class BusinessModel extends BusinessEntity {
  const BusinessModel({
    required super.id,
    required super.userId,
    required super.businessName,
    super.tradeName,
    required super.businessType,
    required super.gstin,
    super.pan,
    super.tan,
    required super.phone,
    super.email,
    super.website,
    required super.address,
    super.city,
    super.state,
    super.pincode,
    super.country,
    super.bankAccounts,
    super.logoUrl,
    super.signatureUrl,
    super.termsAndConditions,
    super.paymentTerms,
    super.upiId,
    super.registrationNumber,
    super.establishedDate,
    super.isOnboardingComplete,
    required super.createdAt,
    super.updatedAt,
  });

  factory BusinessModel.fromEntity(BusinessEntity entity) {
    return BusinessModel(
      id: entity.id,
      userId: entity.userId,
      businessName: entity.businessName,
      tradeName: entity.tradeName,
      businessType: entity.businessType,
      gstin: entity.gstin,
      pan: entity.pan,
      tan: entity.tan,
      phone: entity.phone,
      email: entity.email,
      website: entity.website,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      pincode: entity.pincode,
      country: entity.country,
      bankAccounts: entity.bankAccounts,
      logoUrl: entity.logoUrl,
      signatureUrl: entity.signatureUrl,
      termsAndConditions: entity.termsAndConditions,
      paymentTerms: entity.paymentTerms,
      upiId: entity.upiId,
      registrationNumber: entity.registrationNumber,
      establishedDate: entity.establishedDate,
      isOnboardingComplete: entity.isOnboardingComplete,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      businessName: json['businessName'] as String,
      tradeName: json['tradeName'] as String?,
      businessType: BusinessType.values.firstWhere(
        (e) => e.toString() == 'BusinessType.${json['businessType']}',
        orElse: () => BusinessType.soleProprietor,
      ),
      gstin: json['gstin'] as String,
      pan: json['pan'] as String?,
      tan: json['tan'] as String?,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      country: json['country'] as String?,
      bankAccounts: (json['bankAccounts'] as List<dynamic>?)
              ?.map((e) => BankAccountModel.fromJson(e as Map<String, dynamic>).toEntity())
              .toList() ??
          [],
      logoUrl: json['logoUrl'] as String?,
      signatureUrl: json['signatureUrl'] as String?,
      termsAndConditions: json['termsAndConditions'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
      upiId: json['upiId'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      establishedDate: json['establishedDate'] != null
          ? (json['establishedDate'] as Timestamp).toDate()
          : null,
      isOnboardingComplete: json['isOnboardingComplete'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessName': businessName,
      'tradeName': tradeName,
      'businessType': businessType.toString().split('.').last,
      'gstin': gstin,
      'pan': pan,
      'tan': tan,
      'phone': phone,
      'email': email,
      'website': website,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'bankAccounts': bankAccounts
          .map((e) => BankAccountModel.fromEntity(e).toJson())
          .toList(),
      'logoUrl': logoUrl,
      'signatureUrl': signatureUrl,
      'termsAndConditions': termsAndConditions,
      'paymentTerms': paymentTerms,
      'upiId': upiId,
      'registrationNumber': registrationNumber,
      'establishedDate': establishedDate != null
          ? Timestamp.fromDate(establishedDate!)
          : null,
      'isOnboardingComplete': isOnboardingComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}

