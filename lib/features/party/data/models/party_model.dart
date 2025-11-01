import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/party_entity.dart';

class PartyModel extends PartyEntity {
  const PartyModel({
    required super.id,
    required super.userId,
    required super.name,
    super.phoneNumber,
    super.email,
    super.gstin,
    super.address,
    super.city,
    super.state,
    super.pincode,
    super.country,
    required super.partyType,
    super.openingBalance,
    super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      gstin: json['gstin'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      country: json['country'] as String?,
      partyType: PartyType.values.firstWhere(
        (e) => e.name == json['partyType'],
        orElse: () => PartyType.customer,
      ),
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'gstin': gstin,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'partyType': partyType.name,
      'openingBalance': openingBalance,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PartyModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phoneNumber,
    String? email,
    String? gstin,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? country,
    PartyType? partyType,
    double? openingBalance,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      partyType: partyType ?? this.partyType,
      openingBalance: openingBalance ?? this.openingBalance,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

