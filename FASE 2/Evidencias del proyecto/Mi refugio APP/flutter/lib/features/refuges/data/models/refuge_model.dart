import 'package:equatable/equatable.dart';

class RefugeModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String address;
  final String? phone;
  final String? email;
  final String? website;
  final int capacity;
  final int occupied;
  final String region;
  final String? commune;
  final double? latitude;
  final double? longitude;
  final List<String> services;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RefugeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.phone,
    this.email,
    this.website,
    required this.capacity,
    required this.occupied,
    required this.region,
    this.commune,
    this.latitude,
    this.longitude,
    required this.services,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RefugeModel.fromJson(Map<String, dynamic> json) {
    return RefugeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      capacity: json['capacity'] as int? ?? 0,
      occupied: json['occupied'] as int? ?? 0,
      region: json['region'] as String,
      commune: json['commune'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'capacity': capacity,
      'occupied': occupied,
      'region': region,
      'commune': commune,
      'latitude': latitude,
      'longitude': longitude,
      'services': services,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get occupancyRate {
    if (capacity == 0) return 0.0;
    return (occupied / capacity).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        phone,
        email,
        website,
        capacity,
        occupied,
        region,
        commune,
        latitude,
        longitude,
        services,
        imageUrl,
        isActive,
        createdAt,
        updatedAt,
      ];
}
