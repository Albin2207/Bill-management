import 'package:equatable/equatable.dart';

enum PartyType {
  customer,
  vendor,
  both,
}

class PartyEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? gstin;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final PartyType partyType;
  final double openingBalance;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PartyEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.phoneNumber,
    this.email,
    this.gstin,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.country,
    required this.partyType,
    this.openingBalance = 0.0,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        phoneNumber,
        email,
        gstin,
        address,
        city,
        state,
        pincode,
        country,
        partyType,
        openingBalance,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}

